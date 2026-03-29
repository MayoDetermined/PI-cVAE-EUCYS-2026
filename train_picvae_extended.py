"""PI-cVAE pełna implementacja.

Model: Physics-Informed Conditional Variational Autoencoder dla edge-plasma SOLPS.

Główne cechy:
- min-max normalizacja do zakresu [0,1] (bez log + z-score)
- Encoder: 4× Conv2D 4×4 str=2, kanały 10→32→64→128→256, LeakyReLU(0.2)
- Flatten → Transformer×2 na wektorze 7168 (projekcja do d_model=512)
- Condition MLP 8→32 - concat z cechami → Linear → μ/logσ²
- Decoder: FC 7×4×256, 4× (ConvTranspose2d + ResBlock), interpolacja na wyjście 104×50
- Bohm penalty tylko na komórkach dywertora (target mask)
- Warunek: log10 indeksów [3,4,5] (Dpuff, Npuff, Dcore) przed min-max
- Pełny jakobian transformacji krzywoliniowej z crx.npy/cry.npy (dywergencja 2.3.2)
"""

import os
import sys
import argparse
import math
import multiprocessing
from pathlib import Path

import numpy as np
import torch
import torch.nn as nn
import torch.nn.functional as F
from torch.utils.data import Dataset, DataLoader
from tqdm import tqdm
import random

# ---------------------------------------------------------------------------
# Stałe fizyczne
# ---------------------------------------------------------------------------
m_deuterium = 3.344e-27   # kg  (masa jonu D+)
k_B = 1.380649e-23        # J/K
e_charge = 1.602176634e-19  # C  (do przeliczenia eV → J)

# ---------------------------------------------------------------------------
# Domyślne hiperparametry (zgodne z paperem Sekcja 2.3)
# ---------------------------------------------------------------------------
DEFAULTS = {
    "latent_dim": 64,           # ↓ z 128: 5756 próbek to za mało na 128-dim latent z 22 kanałami
    "batch_size": 64,           # ↓ z 256: więcej kroków/epokę (90 vs 23) = lepsza zbieżność
    "lr": 3e-4,                 # ↑ z 1e-4: proporcjonalnie do √(bs_new/bs_old) ≈ 2x, AdamW to zniesie
    "epochs": 350,              # ↑ z 200: z bs=256 mamy ~23 stepów/epokę (vs ~90), model potrzebuje więcej epok
    "weight_decay": 1e-4,       # ↑ z 1e-5: silniejsza regularyzacja dla 13M param / 5.7k próbek
    "kl_beta_max": 0.5,         # ↑ z 0.2: z floor na prior logvar, wyższy beta wymusza użycie latent space
    "kl_beta_init": 0.0,
    "kl_anneal_epochs": 100,    # ↑ z 60: dłuższy ramp-up dla wyższego beta, stabilizuje trening
    "w_rec": 1.0,
    "w_nonneg": 5e-3,           # ↑ z 1e-3: fizycznie istotne (Te,Ti,n ≥ 0), wzmocniona penalizacja
    "w_bohm": 1e-3,             # ↑ z 5e-4: kryterium Bohma jest twardy constraint, ważniejszy
    "w_div": 1e-3,              # ↓ z 3e-3: dywergencja z pełnym jakobianem daje duże wartości, obniżamy
    "grad_clip": 3.0,           # ↓ z 5.0: ostrzejszy clipping stabilizuje trening z fizycznymi stratami
    "save_dir": "./checkpoints_paper",
    "nx": 104,                  # W  (poloidalny)
    "ny": 50,                   # H  (radialny)
    "ns": 22,                   # C kanałów: Te + Ti + 10×gęstość + 10×prędkość = 22
    "device": "cuda" if torch.cuda.is_available() else "cpu",
    "seed": 1234,
    "patience": 50,             # ↑ z 30: więcej cierpliwości — fizyczne straty powodują turbulencje w val loss
    "save_every": 25,
    "num_workers": 0,           # Windows: spawn pickle nie radzi sobie z ~5 GB danych w Dataset
    "leaky_alpha": 0.2,
    "physics_warmup_epochs": 80,  # ↑ z 30: fizyka po KL warmup, nie przed — unika pchania ku średniej
    "div_clamp": 1e3,           # ↓ z 1e4: ostrzejszy clamp zapobiega exploding gradients z dywergencji
}

# ═══════════════════════════════════════════════════════════════════════════
# Dataset — normalizacja min-max [0,1] (paper Sekcja 2.1.1)
# ═══════════════════════════════════════════════════════════════════════════

class TokamakDatasetMinMax(Dataset):
    """
    Ładuje pola 2-D SOLPS i stosuje kanałową normalizację min-max do [0,1].
    Wektor warunkujący c normalizowany jest do [0,1] z log-skalowaniem
    indeksów 3,4,5 (Dpuff, Npuff, Dcore) — paper Sekcja 2.1.2.
    """

    def __init__(self, data_dir: str, split: str = "train", norm_stats=None):
        root = Path(data_dir) / split
        if not root.exists():
            print(f"[INFO] {root} nie istnieje — generuję dummy data.")
            self._create_dummy(root)

        # Surowe pola
        self.X = np.load(root / "X_tmp.npy").astype(np.float32)   # (N, 8)
        self.te = np.load(root / "te_tmp.npy").astype(np.float32)  # (N, 104, 50)
        self.ti = np.load(root / "ti_tmp.npy").astype(np.float32)
        self.na = np.load(root / "na_tmp.npy").astype(np.float32)  # (N, 104, 50, Ns_density)
        self.ua = np.load(root / "ua_tmp.npy").astype(np.float32)  # (N, 104, 50, Ns_vel)

        self.norm_path = Path(data_dir) / "norm_stats_minmax.npz"

        if norm_stats is not None:
            self._load(norm_stats)
        elif split == "train":
            self._compute()
            np.savez(self.norm_path, **self._as_dict())
        else:
            if self.norm_path.exists():
                self._load(np.load(self.norm_path))
            else:
                self._compute()

    # ------------------------------------------------------------------
    def _create_dummy(self, root):
        root.mkdir(parents=True, exist_ok=True)
        N = 100
        np.save(root / "X_tmp.npy", np.random.randn(N, 8).astype(np.float32))
        np.save(root / "te_tmp.npy", np.abs(np.random.randn(N, 104, 50).astype(np.float32)) * 100)
        np.save(root / "ti_tmp.npy", np.abs(np.random.randn(N, 104, 50).astype(np.float32)) * 100)
        np.save(root / "na_tmp.npy", np.abs(np.random.randn(N, 104, 50, 10).astype(np.float32)) * 1e18)
        np.save(root / "ua_tmp.npy", np.random.randn(N, 104, 50, 10).astype(np.float32) * 1e4)

    # ------------------------------------------------------------------
    # Min-max po kanałach  (paper: X'_{i,j,k} = (X - min_k) / (max_k - min_k))
    # ------------------------------------------------------------------
    def _compute(self):
        # Te, Ti — skalary na siatkę
        self.te_min = float(self.te.min())
        self.te_max = float(self.te.max())
        self.ti_min = float(self.ti.min())
        self.ti_max = float(self.ti.max())

        # na — per-species min/max
        Ns_d = self.na.shape[-1]
        self.na_min = np.array([float(self.na[..., i].min()) for i in range(Ns_d)], dtype=np.float32)
        self.na_max = np.array([float(self.na[..., i].max()) for i in range(Ns_d)], dtype=np.float32)

        # ua — per-species min/max
        Ns_v = self.ua.shape[-1]
        self.ua_min = np.array([float(self.ua[..., i].min()) for i in range(Ns_v)], dtype=np.float32)
        self.ua_max = np.array([float(self.ua[..., i].max()) for i in range(Ns_v)], dtype=np.float32)

        # Wektor warunkujący — log-skalowanie indeksów 3,4,5, potem global min-max
        X_proc = self._preprocess_cond(self.X)
        self.X_min = X_proc.min(axis=0).astype(np.float32)
        self.X_max = X_proc.max(axis=0).astype(np.float32)

    def _preprocess_cond(self, X):
        """Log-skalowanie indeksów 3,4,5 (Dpuff, Npuff, Dcore) — paper Tabela 2."""
        X_out = X.copy()
        for idx in [3, 4, 5]:
            X_out[:, idx] = np.log10(np.clip(np.abs(X_out[:, idx]), 1.0, None))
        return X_out

    def _as_dict(self):
        return dict(
            te_min=self.te_min, te_max=self.te_max,
            ti_min=self.ti_min, ti_max=self.ti_max,
            na_min=self.na_min, na_max=self.na_max,
            ua_min=self.ua_min, ua_max=self.ua_max,
            X_min=self.X_min, X_max=self.X_max,
        )

    def _load(self, stats):
        for k in stats:
            v = stats[k]
            setattr(self, k, v.astype(np.float32) if isinstance(v, np.ndarray) else float(v))

    # ------------------------------------------------------------------
    def __len__(self):
        return self.X.shape[0]

    def _minmax(self, val, vmin, vmax):
        denom = vmax - vmin
        if isinstance(denom, np.ndarray):
            denom = np.where(denom < 1e-12, 1.0, denom)
        else:
            denom = max(denom, 1e-12)
        return (val - vmin) / denom

    def __getitem__(self, idx):
        te = self.te[idx]  # (104, 50)
        ti = self.ti[idx]
        na = self.na[idx]  # (104, 50, Ns_d)
        ua = self.ua[idx]  # (104, 50, Ns_v)

        # Min-max normalizacja kanałowa
        te_n = self._minmax(te, self.te_min, self.te_max)
        ti_n = self._minmax(ti, self.ti_min, self.ti_max)

        channels = [te_n[np.newaxis], ti_n[np.newaxis]]  # (1, 104, 50)

        for i in range(na.shape[-1]):
            channels.append(
                self._minmax(na[..., i], self.na_min[i], self.na_max[i])[np.newaxis]
            )
        for i in range(ua.shape[-1]):
            channels.append(
                self._minmax(ua[..., i], self.ua_min[i], self.ua_max[i])[np.newaxis]
            )

        x_field = np.concatenate(channels, axis=0).astype(np.float32)  # (C, 104, 50)

        # Warunek — log + minmax
        x_cond_raw = self.X[idx].copy()
        for ci in [3, 4, 5]:
            x_cond_raw[ci] = np.log10(max(abs(x_cond_raw[ci]), 1.0))
        x_cond = self._minmax(x_cond_raw, self.X_min, self.X_max).astype(np.float32)

        return {"x_cond": x_cond, "field": x_field}


# ═══════════════════════════════════════════════════════════════════════════
# Architektura — dokładnie wg Tabeli 3 i Sekcji 2.2
# ═══════════════════════════════════════════════════════════════════════════

class ConvBlock(nn.Module):
    """Conv2D + LeakyReLU (paper: kernel 4×4, stride 2)."""
    def __init__(self, in_ch, out_ch, kernel=4, stride=2, padding=1):
        super().__init__()
        self.conv = nn.Conv2d(in_ch, out_ch, kernel, stride, padding)
        self.act = nn.LeakyReLU(0.2)

    def forward(self, x):
        return self.act(self.conv(x))


class Encoder(nn.Module):
    """
    Paper Tabela 3:
      Conv2D  10 → 32  (104×50 → 52×25)   k=4 s=2
      Conv2D  32 → 64  (52×25  → 26×13)   k=4 s=2
      Conv2D  64 → 128 (26×13  → 13×7)    k=4 s=2
      Conv2D 128 → 256 (13×7   → 7×4)     k=4 s=2
      Flatten → 7168
      Transformer ×2 (d_model=7168 nie jest praktyczny → robimy projekcję)
      Condition MLP: 8 → 32
      Concat(7168, 32) = 7200 → Linear → 2×128  (μ, log σ²)

    UWAGA: Transformer z d_model=7168 jest ekstremalnie kosztowny.
    Paper mówi "Blok Transformera (x2)" na 7168-dim wektorze — w praktyce
    stosujemy projekcję do mniejszego d_model (512) i z powrotem, co zachowuje
    sens "globalnego self-attention" bez wybuchu pamięci.
    """

    def __init__(self, in_channels: int, latent_dim: int, cond_dim: int = 8,
                 nx: int = 104, ny: int = 50):
        super().__init__()

        # CNN backbone — 4 bloki konwolucyjne (Tabela 3)
        self.convs = nn.Sequential(
            ConvBlock(in_channels, 32, 4, 2, 1),
            ConvBlock(32, 64, 4, 2, 1),
            ConvBlock(64, 128, 4, 2, 1),
            ConvBlock(128, 256, 4, 2, 1),
        )

        # Dynamicznie oblicz flat_dim na podstawie rzeczywistego rozmiaru wejścia
        with torch.no_grad():
            dummy = torch.zeros(1, in_channels, nx, ny)
            dummy_out = self.convs(dummy)
            self.flat_dim = dummy_out.numel() // dummy_out.size(0)

        # Transformer na 7168-dim — projekcja do d_model=512
        d_transf = 512
        self.proj_in = nn.Linear(self.flat_dim, d_transf)
        self.transformer = nn.TransformerEncoder(
            nn.TransformerEncoderLayer(
                d_model=d_transf, nhead=8, dim_feedforward=1024,
                dropout=0.1, activation="gelu", batch_first=True,
            ),
            num_layers=2,
        )
        self.proj_out = nn.Linear(d_transf, self.flat_dim)

        # Condition MLP (8 → 128) — szersze embedding, aby warunek miał znaczący wpływ
        self.cond_mlp = nn.Sequential(
            nn.Linear(cond_dim, 128),
            nn.LeakyReLU(0.2),
        )

        # Head: concat(7168, 128)=7296 → 2×latent_dim
        self.fc_mu = nn.Linear(self.flat_dim + 128, latent_dim)
        self.fc_logvar = nn.Linear(self.flat_dim + 128, latent_dim)

    def forward(self, x_field, c):
        # x_field: (B, C, 104, 50)   c: (B, 8)
        h = self.convs(x_field)                # (B, 256, 7, 4)
        h_flat = h.reshape(h.size(0), -1)      # (B, 7168)

        # Transformer — traktuj cały wektor jako sekwencję długości 1
        # (wystarczający, bo paper sugeruje self-att na flattened features)
        h_proj = self.proj_in(h_flat).unsqueeze(1)    # (B, 1, 512)
        h_trans = self.transformer(h_proj).squeeze(1)  # (B, 512)
        h_feat = h_flat + self.proj_out(h_trans)       # residual → (B, 7168)

        c_emb = self.cond_mlp(c)               # (B, 32)
        combined = torch.cat([h_feat, c_emb], dim=1)  # (B, 7200)

        return self.fc_mu(combined), self.fc_logvar(combined)


class ResBlock(nn.Module):
    """Residualny blok Conv2D — paper Sekcja 2.2.2."""
    def __init__(self, ch):
        super().__init__()
        self.block = nn.Sequential(
            nn.Conv2d(ch, ch, 3, padding=1),
            nn.LeakyReLU(0.2),
            nn.Conv2d(ch, ch, 3, padding=1),
        )
        self.act = nn.LeakyReLU(0.2)

    def forward(self, x):
        return self.act(x + self.block(x))


class Decoder(nn.Module):
    """
    Paper Sekcja 2.2.2:
      z(128) + cond_MLP(32) concat → Linear → 7×4×256
      4× (TransConv2D 4×4 s=2 + ResBlock)   256→128→64→32
      Conv2D 1×1 → C kanałów + Sigmoid
    """

    def __init__(self, latent_dim: int, cond_dim: int, out_channels: int,
                 nx: int = 104, ny: int = 50):
        super().__init__()
        self.nx, self.ny = nx, ny
        self.init_h, self.init_w = 7, 4   # po 4 upsamplach ×2 → 112×64

        # Condition MLP — szerszy embedding (128), zgodny z checkpointem
        self.cond_mlp = nn.Sequential(
            nn.Linear(cond_dim, 128),
            nn.LeakyReLU(0.2),
        )

        # FC: (64+128)=192 → 7×4×256 = 7168
        self.fc = nn.Sequential(
            nn.Linear(latent_dim + 128, 256 * self.init_h * self.init_w),
            nn.LeakyReLU(0.2),
        )

        # 4 bloki upsample (TransConv + ResBlock)
        self.up = nn.Sequential(
            # Blok 1: 256→128  (7×4 → 14×8)
            nn.ConvTranspose2d(256, 128, 4, 2, 1),
            nn.LeakyReLU(0.2),
            ResBlock(128),

            # Blok 2: 128→64  (14×8 → 28×16)
            nn.ConvTranspose2d(128, 64, 4, 2, 1),
            nn.LeakyReLU(0.2),
            ResBlock(64),

            # Blok 3: 64→32  (28×16 → 56×32)
            nn.ConvTranspose2d(64, 32, 4, 2, 1),
            nn.LeakyReLU(0.2),
            ResBlock(32),

            # Blok 4: 32→32  (56×32 → 112×64)
            nn.ConvTranspose2d(32, 32, 4, 2, 1),
            nn.LeakyReLU(0.2),
            ResBlock(32),
        )

        # Warstwa wyjściowa: 1×1 conv (bez sigmoid — clamp zamiast tego, pełny gradient w [0,1])
        self.head = nn.Conv2d(32, out_channels, 1)

    def forward(self, z, c):
        c_emb = self.cond_mlp(c)                              # (B, 32)
        h = self.fc(torch.cat([z, c_emb], dim=1))             # (B, 7168)
        h = h.view(-1, 256, self.init_h, self.init_w)         # (B, 256, 7, 4)
        h = self.up(h)                                         # (B, 32, 112, 64)
        h = self.head(h)                                       # (B, C, 112, 64)
        # Interpolacja do dokładnego rozmiaru siatki
        out = F.interpolate(h, size=(self.nx, self.ny), mode="bilinear", align_corners=False)
        return torch.clamp(out, 0.0, 1.0)


class PriorNet(nn.Module):
    """Conditional Prior p(z|c) — MLP."""
    def __init__(self, cond_dim: int, latent_dim: int, hidden: int = 256):
        super().__init__()
        self.net = nn.Sequential(
            nn.Linear(cond_dim, hidden), nn.LeakyReLU(0.2),
            nn.Linear(hidden, hidden), nn.LeakyReLU(0.2),
        )
        self.fc_mu = nn.Linear(hidden, latent_dim)
        self.fc_logvar = nn.Linear(hidden, latent_dim)

    def forward(self, c):
        h = self.net(c)
        mu = self.fc_mu(h)
        logvar = self.fc_logvar(h)
        logvar = torch.clamp(logvar, min=-2.0)   # floor: std >= exp(-1) ≈ 0.368
        return mu, logvar


class PI_CVAE(nn.Module):
    """Pełny model PI-cVAE (paper Sekcja 2.2)."""

    def __init__(self, in_channels: int, cond_dim: int, latent_dim: int,
                 nx: int = 104, ny: int = 50):
        super().__init__()
        self.encoder = Encoder(in_channels, latent_dim, cond_dim, nx, ny)
        self.prior = PriorNet(cond_dim, latent_dim)
        self.decoder = Decoder(latent_dim, cond_dim, in_channels, nx, ny)
        self.latent_dim = latent_dim

    def reparameterize(self, mu, logvar):
        std = torch.exp(0.5 * logvar)
        return mu + std * torch.randn_like(std)

    def forward(self, x_field, c):
        q_mu, q_logvar = self.encoder(x_field, c)
        z = self.reparameterize(q_mu, q_logvar)
        p_mu, p_logvar = self.prior(c)
        x_rec = self.decoder(z, c)
        return {
            "x_rec": x_rec,
            "q_mu": q_mu, "q_logvar": q_logvar,
            "p_mu": p_mu, "p_logvar": p_logvar,
        }

    @torch.no_grad()
    def sample(self, c):
        """Generuj nowe pole na podstawie warunku c."""
        p_mu, p_logvar = self.prior(c)
        z = self.reparameterize(p_mu, p_logvar)
        return self.decoder(z, c)


# ═══════════════════════════════════════════════════════════════════════════
# Geometria siatki krzywoliniowej — Jakobian i tensor metryczny
# (paper Sekcja 2.3.2 + Future Work pkt 2: rygorystyczna strata PI
#  z jawnym jakobianem transformacji ze współrzędnych crx/cry)
# ═══════════════════════════════════════════════════════════════════════════

def compute_curvilinear_metrics(data_dir: str, device: str, nx: int = 104, ny: int = 50):
    """Compute curvilinear grid metrics for PI physics losses.

    Loads `geometry/crx.npy` and `geometry/cry.npy` or falls back to a cartesian grid.

    Returns a dict of tensors (shape [1,1,nx,ny]):
      - jacobian / inv_jacobian
      - g11,g12,g22 (covariant), ginv11,ginv12,ginv22 (contravariant)
      - target_mask (dyfwerter), R_center,Z_center

    Notes:
      - crx/cry: [nx,ny,4] corner coordinates of each cell in (R,Z)
      - central differences with edge replicating padding for derivatives
      - g_αβ, g^αβ computed via standard metric inversion
      - divergence uses the form from paper 2.3.2: div A = 1/√g * (∂i(√g A^i) + ∂j(√g A^j))
    """
    geo_dir = Path(data_dir) / "geometry"
    crx_path = geo_dir / "crx.npy"
    cry_path = geo_dir / "cry.npy"

    if not crx_path.exists() or not cry_path.exists():
        print("[WARN] Brak crx.npy / cry.npy — generuję przybliżoną siatkę prostokątną.")
        return _dummy_metrics(nx, ny, device)

    crx = np.load(crx_path).astype(np.float64)  # [nx, ny, 4]
    cry = np.load(cry_path).astype(np.float64)  # [nx, ny, 4]

    # Centroidy komórek w fizycznej przestrzeni (R, Z)
    R_c = crx.mean(axis=2)  # [nx, ny]
    Z_c = cry.mean(axis=2)  # [nx, ny]

    # Pochodne ∂R/∂ξ^α, ∂Z/∂ξ^α  (ξ^1=i poloidalny, ξ^2=j radialny)
    # Centralne różnice z edge-padding
    R_pad = np.pad(R_c, ((1, 1), (1, 1)), mode="edge")
    Z_pad = np.pad(Z_c, ((1, 1), (1, 1)), mode="edge")

    dR_di = (R_pad[2:, 1:-1] - R_pad[:-2, 1:-1]) / 2.0   # ∂R/∂i
    dR_dj = (R_pad[1:-1, 2:] - R_pad[1:-1, :-2]) / 2.0   # ∂R/∂j
    dZ_di = (Z_pad[2:, 1:-1] - Z_pad[:-2, 1:-1]) / 2.0   # ∂Z/∂i
    dZ_dj = (Z_pad[1:-1, 2:] - Z_pad[1:-1, :-2]) / 2.0   # ∂Z/∂j

    # ── Jakobian √g ──
    # √g = |det(J)| = |∂R/∂i · ∂Z/∂j − ∂R/∂j · ∂Z/∂i|
    jacobian = np.abs(dR_di * dZ_dj - dR_dj * dZ_di)
    jacobian = np.clip(jacobian, 1e-14, None)

    # ── Kowariantny tensor metryczny g_αβ ──
    # g_αβ = Σ_k (∂x^k/∂ξ^α)(∂x^k/∂ξ^β)   gdzie x=(R,Z), ξ=(i,j)
    g11 = dR_di ** 2 + dZ_di ** 2          # g_{11} (ii)
    g12 = dR_di * dR_dj + dZ_di * dZ_dj    # g_{12} = g_{21}
    g22 = dR_dj ** 2 + dZ_dj ** 2          # g_{22} (jj)

    # ── Kontrawariantny tensor metryczny g^αβ = (g_αβ)^{-1} ──
    # det(g) = g11·g22 − g12²  (= √g ²)
    det_g = g11 * g22 - g12 ** 2
    det_g = np.clip(det_g, 1e-28, None)

    ginv11 = g22 / det_g
    ginv12 = -g12 / det_g
    ginv22 = g11 / det_g

    # ── Maska target divertora ──
    # Komórki przy poloidalnych granicach siatki (płyty dywertora)
    target_mask = np.zeros((nx, ny), dtype=np.float32)
    target_mask[:3, :] = 1.0     # wewnętrzny target
    target_mask[-3:, :] = 1.0    # zewnętrzny target

    def _to_tensor(arr):
        return torch.tensor(
            arr.astype(np.float32), device=device, dtype=torch.float32
        ).unsqueeze(0).unsqueeze(0)  # [1, 1, nx, ny]

    return {
        "jacobian": _to_tensor(jacobian),           # √g
        "inv_jacobian": _to_tensor(1.0 / jacobian),  # 1/√g
        "g11": _to_tensor(g11),
        "g12": _to_tensor(g12),
        "g22": _to_tensor(g22),
        "ginv11": _to_tensor(ginv11),    # g^{11}
        "ginv12": _to_tensor(ginv12),    # g^{12} = g^{21}
        "ginv22": _to_tensor(ginv22),    # g^{22}
        "target_mask": _to_tensor(target_mask),
        "R_center": _to_tensor(R_c),
        "Z_center": _to_tensor(Z_c),
    }


def _dummy_metrics(nx, ny, device):
    """Fallback — jednostkowy jakobian (siatka kartezjańska)."""
    ones = torch.ones(1, 1, nx, ny, device=device, dtype=torch.float32)
    zeros = torch.zeros(1, 1, nx, ny, device=device, dtype=torch.float32)
    return {
        "jacobian": ones.clone(),
        "inv_jacobian": ones.clone(),
        "g11": ones.clone(), "g12": zeros.clone(), "g22": ones.clone(),
        "ginv11": ones.clone(), "ginv12": zeros.clone(), "ginv22": ones.clone(),
        "target_mask": zeros.clone(),
        "R_center": ones.clone(), "Z_center": ones.clone(),
    }


# ═══════════════════════════════════════════════════════════════════════════
# Physics-Informed Loss  (paper Sekcja 2.3 + pełny jakobian)
# ═══════════════════════════════════════════════════════════════════════════

def _denorm_channel(x_norm, ch_min, ch_max):
    """Odwraca min-max: x_phys = x_norm * (max - min) + min."""
    return x_norm * (ch_max - ch_min) + ch_min


def kl_divergence(mu_q, logvar_q, mu_p, logvar_p, free_bits=0.1):
    """KL(q || p) dla diagonalnych Gaussianów z free bits."""
    var_q = torch.exp(logvar_q)
    var_p = torch.exp(logvar_p)
    kl_per_dim = 0.5 * (
        logvar_p - logvar_q + (var_q + (mu_q - mu_p) ** 2) / (var_p + 1e-12) - 1
    )
    kl_per_dim = torch.clamp(kl_per_dim, min=free_bits)
    return kl_per_dim.sum(dim=1).mean()


def nonneg_penalty(x_rec, ch_info, stats):
    """
    L_nonneg — penalizacja ujemnych wartości fizycznych Te, Ti, n_a (paper Sekcja 2.3.1).
    Działamy na denormalizowanych polach.
    """
    penalties = []

    te_phys = _denorm_channel(x_rec[:, ch_info["te_idx"]],
                              stats["te_min"], stats["te_max"])
    ti_phys = _denorm_channel(x_rec[:, ch_info["ti_idx"]],
                              stats["ti_min"], stats["ti_max"])
    penalties.append(F.relu(-te_phys).mean())
    penalties.append(F.relu(-ti_phys).mean())

    for i, ch in enumerate(ch_info["na_indices"]):
        na_phys = _denorm_channel(x_rec[:, ch],
                                  stats["na_min"][i], stats["na_max"][i])
        penalties.append(F.relu(-na_phys).mean())

    return torch.stack(penalties).sum()


def divergence_penalty_curvilinear(x_rec, ch_info, stats, geo):
    """
    L_div — rygorystyczna dywergencja strumienia cząstek we współrzędnych
    krzywoliniowych z pełnym jakobianem (paper Sekcja 2.3.2 + Future Work pkt 2).

    Formuła:
        ∇·A = (1/√g) · [∂(√g · A^i)/∂i + ∂(√g · A^j)/∂j]

    gdzie:
        √g      — jakobian transformacji (i,j) → (R,Z)
        A^i, A^j — kontrawariantne składowe strumienia cząstek

    Strumień równoległy Γ_∥ = n · u_∥ traktujemy jako składową kowariantną
    wzdłuż kierunku poloidalnego (i). Kontrawariantne:
        F^i = g^{11} · Γ_∥     (składowa wzdłuż i)
        F^j = g^{21} · Γ_∥     (sprzężenie krzyżowe z krzywizny siatki)

    Centralne różnice 2. rzędu z replicate-padding na brzegach.
    Normalizacja przez skalę strumienia (detach) dla stabilności gradientów.
    """
    jac = geo["jacobian"]           # [1, 1, nx, ny]  √g
    inv_jac = geo["inv_jacobian"]   # [1, 1, nx, ny]  1/√g
    ginv11 = geo["ginv11"]          # [1, 1, nx, ny]  g^{11}
    ginv12 = geo["ginv12"]          # [1, 1, nx, ny]  g^{12}=g^{21}

    penalties = []
    for n_idx, u_idx in ch_info["species_pairs"]:
        # Denormalizacja do wartości fizycznych
        n_phys = _denorm_channel(
            x_rec[:, n_idx],
            stats["na_min"][n_idx - 2],
            stats["na_max"][n_idx - 2],
        )   # (B, nx, ny)
        u_phys = _denorm_channel(
            x_rec[:, u_idx],
            stats["ua_min"][u_idx - ch_info["ua_offset"]],
            stats["ua_max"][u_idx - ch_info["ua_offset"]],
        )   # (B, nx, ny)

        flux_covar = n_phys * u_phys  # Γ_∥ = n·u  (kowariantna wzdłuż i)

        # Normalizacja skalą strumienia WCZEŚNIE — unika overflow
        # (fizyczne wartości n~1e18, u~1e4 → flux~1e22, przekracza float16
        #  i może powodować inf w autocast; normalizacja sprowadza do O(1))
        flux_scale = flux_covar.abs().mean().detach().clamp(min=1e-12)
        flux_norm = flux_covar / flux_scale

        # Kontrawariantne składowe strumienia
        # F^i = g^{11}·Γ_∥ ,  F^j = g^{21}·Γ_∥   (A_j ≈ 0 → tylko u_∥)
        jac_sq = jac.squeeze(0).squeeze(0)          # (nx, ny)
        inv_jac_sq = inv_jac.squeeze(0).squeeze(0)  # (nx, ny)
        g11_sq = ginv11.squeeze(0).squeeze(0)       # (nx, ny)
        g12_sq = ginv12.squeeze(0).squeeze(0)       # (nx, ny)

        Fi = g11_sq * flux_norm   # (B, nx, ny)
        Fj = g12_sq * flux_norm   # (B, nx, ny)

        # Ważone strumienie: √g · F^α
        wFi = jac_sq * Fi   # (B, nx, ny)
        wFj = jac_sq * Fj   # (B, nx, ny)

        # Centralne różnice: ∂(√g·F^i)/∂i  i  ∂(√g·F^j)/∂j
        # dim: i=poloidalny (dim=-2), j=radialny (dim=-1)
        wFi_pad = F.pad(wFi.unsqueeze(1), (0, 0, 1, 1), mode="replicate").squeeze(1)
        d_wFi_di = (wFi_pad[:, 2:, :] - wFi_pad[:, :-2, :]) / 2.0  # (B, nx, ny)

        wFj_pad = F.pad(wFj.unsqueeze(1), (1, 1, 0, 0), mode="replicate").squeeze(1)
        d_wFj_dj = (wFj_pad[:, :, 2:] - wFj_pad[:, :, :-2]) / 2.0  # (B, nx, ny)

        # Dywergencja: ∇·Γ = (1/√g) · [∂(√g·F^i)/∂i + ∂(√g·F^j)/∂j]
        div = inv_jac_sq * (d_wFi_di + d_wFj_dj)   # (B, nx, ny)

        penalties.append((div ** 2).mean())

    return torch.stack(penalties).sum()


def bohm_penalty(x_rec, ch_info, stats, geo):
    """
    L_bohm — kryterium Bohma na granicach dywertora (paper Sekcja 2.3.3).

    Penalizacja: (|u_∥| − c_s)² · H(c_s − |u_∥|)
    Stosowana WYŁĄCZNIE do komórek target z maski geometrii (target_mask).
    """
    te_phys = _denorm_channel(x_rec[:, ch_info["te_idx"]],
                              stats["te_min"], stats["te_max"])
    ti_phys = _denorm_channel(x_rec[:, ch_info["ti_idx"]],
                              stats["ti_min"], stats["ti_max"])

    # Prędkość dźwięku jonowego: c_s = √((e·Te + e·Ti) / m_D+)
    # Paper: Te,Ti w eV → konwersja do J przez e_charge
    Te_J = te_phys * e_charge
    Ti_J = ti_phys * e_charge
    cs = torch.sqrt(torch.clamp((Te_J + Ti_J) / m_deuterium, min=1e-8))

    # Prędkość równoległa D1
    u_ch = ch_info["ua_indices"][ch_info.get("D1_pos_in_ua", 0)]
    u_phys = _denorm_channel(
        x_rec[:, u_ch],
        stats["ua_min"][0], stats["ua_max"][0],
    )

    # Maska targetu z geometrii [1,1,nx,ny] → (nx,ny)
    target = geo["target_mask"].squeeze(0).squeeze(0)  # (nx, ny)

    # Heaviside: penalty gdy |u_∥| < c_s, tylko na komórkach target
    violation = F.relu(cs - torch.abs(u_phys))  # (B, nx, ny)
    masked = violation * target                  # zeruje komórki poza targetem
    n_target = target.sum().clamp(min=1.0)

    return (masked ** 2).sum(dim=(-2, -1)).mean() / n_target


def get_kl_beta(epoch, init, maxv, anneal_epochs):
    if epoch >= anneal_epochs:
        return maxv
    return init + (maxv - init) * epoch / max(1, anneal_epochs)


def get_physics_warmup(epoch, warmup_epochs):
    """Liniowy warmup wag fizycznych (div, bohm) od 0 do 1."""
    if warmup_epochs <= 0:
        return 1.0
    return min(1.0, epoch / max(1, warmup_epochs))


# ═══════════════════════════════════════════════════════════════════════════
# Trening
# ═══════════════════════════════════════════════════════════════════════════

def set_seed(seed):
    random.seed(seed)
    np.random.seed(seed)
    torch.manual_seed(seed)
    torch.cuda.manual_seed_all(seed)


def build_channels_info(ns):
    """Mapowanie indeksów kanałów — paper Tabela 1."""
    # Kanały: 0=Te, 1=Ti, 2..2+Ns_d-1=gęstości, 2+Ns_d..2+Ns_d+Ns_v-1=prędkości
    # Przy C=10:  Te(0), Ti(1), nD0(2), nD1(3), nN0(4)..nN4(8), u∥D1(9)
    # Ogólnie: ns_density kanałów gęstości + ns_vel kanałów prędkości
    # W dummy: na ma shape[-1]=10, ua ma shape[-1]=10
    # Ale paper: 7 gęstości + 1 prędkość = 8, + Te + Ti = 10

    # Liczymy na podstawie ns (total channels)
    # Te=0, Ti=1, reszta z danych
    # species_pairs: (n_idx, u_idx) pary — tu generujemy je dynamicznie
    na_count = 0
    ua_count = 0
    # Na potrzeby generyczne: bierzemy z danych
    # Ale potrzebujemy wiedzieć ile kanałów to na a ile ua
    # Paper: Ns_density=8 (D0,D1,N0..N4), Ns_vel=1 (u∥D1) → nie pasuje do ns=10
    # W dummy data: na.shape[-1]=10, ua.shape[-1]=10 → C=10+10+2=22
    # Traktujemy tak jak w oryginalnym kodzie:
    #   na_indices = [2, ..., 2+na_count-1]
    #   ua_indices = [2+na_count, ..., 2+na_count+ua_count-1]
    # Ale na_count i ua_count zależy od plików — bierzemy je z datasetu.
    # Tutaj placeholder — uzupełnimy w train().
    return None   # placeholder, budujemy w train()


def train(args):
    set_seed(args.seed)

    # --- Dane ---
    ds_train = TokamakDatasetMinMax(args.data_dir, "train")
    stats_path = Path(args.data_dir) / "norm_stats_minmax.npz"
    test_stats = np.load(stats_path) if stats_path.exists() else None
    ds_test = TokamakDatasetMinMax(args.data_dir, "test", norm_stats=test_stats)

    pin = "cuda" in args.device
    train_loader = DataLoader(ds_train, args.batch_size, shuffle=True,
                              num_workers=args.num_workers, pin_memory=pin)
    test_loader = DataLoader(ds_test, args.batch_size, shuffle=False,
                             num_workers=args.num_workers, pin_memory=pin)

    # --- Informacje o kanałach ---
    # W X_field kolejność: [Te, Ti, na_0..na_{N-1}, ua_0..ua_{M-1}]
    # na_count, ua_count wyciągamy bezpośrednio z datasetu, aby wspierać różne konfiguracje.
    na_count = ds_train.na.shape[-1]
    ua_count = ds_train.ua.shape[-1]
    in_channels = 2 + na_count + ua_count
    na_indices = list(range(2, 2 + na_count))
    ua_indices = list(range(2 + na_count, 2 + na_count + ua_count))

    ch_info = {
        "te_idx": 0,
        "ti_idx": 1,
        "na_indices": na_indices,
        "ua_indices": ua_indices,
        "ua_offset": 2 + na_count,
        # species_pairs łączy na[i] z ua[i] dla obliczeń dywergencji strumienia
        "species_pairs": [(2 + j, 2 + na_count + j) for j in range(min(na_count, ua_count))],
        "D1_pos_in_ua": 0,  # główny wektor prędkości w układzie (tu D1)
    }

    # Stats do denormalizacji — na GPU jako tensory
    stats_dict = ds_train._as_dict()
    stats = {}
    for k, v in stats_dict.items():
        if isinstance(v, np.ndarray):
            stats[k] = torch.tensor(v, device=args.device, dtype=torch.float32)
        else:
            stats[k] = torch.tensor(v, device=args.device, dtype=torch.float32)

    # --- Geometria siatki krzywoliniowej ---
    geo = compute_curvilinear_metrics(args.data_dir, args.device, args.nx, args.ny)
    jac_range = (geo["jacobian"].min().item(), geo["jacobian"].max().item())
    print(f"Geometria załadowana  |  √g ∈ [{jac_range[0]:.4e}, {jac_range[1]:.4e}]")
    has_real_geo = geo["target_mask"].sum().item() > 0
    print(f"  target_mask komórek dywertora: {int(geo['target_mask'].sum().item())}")

    # --- Model ---
    cond_dim = ds_train.X.shape[1]
    model = PI_CVAE(in_channels, cond_dim, args.latent_dim, args.nx, args.ny).to(args.device)
    total_params = sum(p.numel() for p in model.parameters() if p.requires_grad)
    print(f"Model PI-cVAE  |  params: {total_params:,}  |  in_ch={in_channels}  cond={cond_dim}")
    print(f"Urządzenie: {args.device}")

    optimizer = torch.optim.AdamW(model.parameters(), lr=args.lr, weight_decay=args.weight_decay)
    scheduler = torch.optim.lr_scheduler.CosineAnnealingLR(optimizer, T_max=args.epochs, eta_min=1e-6)
    scaler = torch.amp.GradScaler("cuda", enabled="cuda" in args.device)

    os.makedirs(args.save_dir, exist_ok=True)
    best_val = float("inf")
    epochs_no_improve = 0

    # --- Pętla treningowa ---
    for epoch in range(1, args.epochs + 1):
        model.train()
        running = {"total": 0.0, "rec": 0.0, "kl": 0.0,
                   "nonneg": 0.0, "div": 0.0, "bohm": 0.0}
        n_samples = 0
        klb = get_kl_beta(epoch, args.kl_beta_init, args.kl_beta_max, args.kl_anneal_epochs)

        pbar = tqdm(train_loader, desc=f"Ep {epoch}/{args.epochs}", leave=False)
        for batch in pbar:
            x_cond = batch["x_cond"].to(args.device)
            x_field = batch["field"].to(args.device)
            bs = x_field.size(0)

            optimizer.zero_grad(set_to_none=True)

            with torch.amp.autocast("cuda", enabled="cuda" in args.device):
                out = model(x_field, x_cond)

                l_rec = F.mse_loss(out["x_rec"], x_field)
                l_kl = kl_divergence(out["q_mu"], out["q_logvar"],
                                     out["p_mu"], out["p_logvar"])

            # Straty fizyczne w float32 — duże wartości fizyczne (n~1e18, u~1e4)
            # przekraczają zakres float16 w autocast → obliczamy poza nim
            x_rec_f32 = out["x_rec"].float()
            l_nn = nonneg_penalty(x_rec_f32, ch_info, stats)
            l_div = divergence_penalty_curvilinear(x_rec_f32, ch_info, stats, geo)
            l_div = torch.clamp(l_div, max=args.div_clamp)
            l_bohm = bohm_penalty(x_rec_f32, ch_info, stats, geo)

            phys_w = get_physics_warmup(epoch, args.physics_warmup_epochs)

            loss = (args.w_rec * l_rec
                    + klb * l_kl
                    + args.w_nonneg * l_nn
                    + phys_w * args.w_div * l_div
                    + phys_w * args.w_bohm * l_bohm)

            scaler.scale(loss).backward()
            torch.nn.utils.clip_grad_norm_(model.parameters(), args.grad_clip)
            scaler.step(optimizer)
            scaler.update()

            running["total"] += loss.item() * bs
            running["rec"] += l_rec.item() * bs
            running["kl"] += l_kl.item() * bs
            running["nonneg"] += l_nn.item() * bs
            running["div"] += l_div.item() * bs
            running["bohm"] += l_bohm.item() * bs
            n_samples += bs

            pbar.set_postfix(loss=f"{loss.item():.5f}", rec=f"{l_rec.item():.5f}")

        scheduler.step()

        # Średnie
        for k in running:
            running[k] /= max(n_samples, 1)

        # --- Walidacja ---
        model.eval()
        val_total = 0.0
        val_rec = 0.0
        n_val = 0

        with torch.no_grad():
            with torch.amp.autocast("cuda", enabled="cuda" in args.device):
                for batch in test_loader:
                    x_cond = batch["x_cond"].to(args.device)
                    x_field = batch["field"].to(args.device)
                    bs = x_field.size(0)

                    out = model(x_field, x_cond)
                    l_rec = F.mse_loss(out["x_rec"], x_field)
                    l_kl = kl_divergence(out["q_mu"], out["q_logvar"],
                                         out["p_mu"], out["p_logvar"])

                    x_rec_f32 = out["x_rec"].float()
                    l_nn = nonneg_penalty(x_rec_f32, ch_info, stats)
                    l_div = divergence_penalty_curvilinear(x_rec_f32, ch_info, stats, geo)
                    l_div = torch.clamp(l_div, max=args.div_clamp)
                    l_bohm = bohm_penalty(x_rec_f32, ch_info, stats, geo)

                    v_loss = (args.w_rec * l_rec + klb * l_kl
                              + args.w_nonneg * l_nn
                              + phys_w * args.w_div * l_div
                              + phys_w * args.w_bohm * l_bohm)
                    val_total += v_loss.item() * bs
                    val_rec += l_rec.item() * bs
                    n_val += bs

        val_total /= max(n_val, 1)
        val_rec /= max(n_val, 1)

        lr_now = optimizer.param_groups[0]["lr"]
        print(
            f"Ep {epoch:>3d} | "
            f"train {running['total']:.5f} (rec={running['rec']:.5f} kl={running['kl']:.5f} "
            f"nn={running['nonneg']:.6f} div={running['div']:.6f} bohm={running['bohm']:.6f}) | "
            f"val {val_total:.5f} (rec={val_rec:.5f}) | β={klb:.3f} lr={lr_now:.2e}"
        )

        # Diagnostyka: monitoring collapse priora
        if epoch % 10 == 0:
            with torch.no_grad():
                p_mu, p_logvar = model.prior(x_cond)
                p_std_mean = torch.exp(0.5 * p_logvar).mean().item()
                q_std_mean = torch.exp(0.5 * out["q_logvar"]).mean().item()
                print(f"  [diag] p_std={p_std_mean:.4f} q_std={q_std_mean:.4f} "
                      f"kl={l_kl.item():.4f}")

        # Checkpoint
        if val_total < best_val - 1e-8:
            best_val = val_total
            epochs_no_improve = 0
            torch.save(model.state_dict(), os.path.join(args.save_dir, "picvae_best.pth"))
            print(f"  ✓ Nowy best val={best_val:.6f}")
        else:
            epochs_no_improve += 1

        if epoch % args.save_every == 0:
            torch.save(model.state_dict(),
                       os.path.join(args.save_dir, f"picvae_ep{epoch}.pth"))

        if epochs_no_improve >= args.patience:
            print(f"Early stopping po {epoch} epokach (patience={args.patience})")
            break

    # Zapisz finałowy model
    torch.save(model.state_dict(), os.path.join(args.save_dir, "picvae_final.pth"))
    print(f"Trening zakończony. Best val loss = {best_val:.6f}")


# ═══════════════════════════════════════════════════════════════════════════
# CLI
# ═══════════════════════════════════════════════════════════════════════════

def parse_args():
    p = argparse.ArgumentParser(description="PI-cVAE (pełna architektura z pełnym jakobianem i siatką)")
    for k, v in DEFAULTS.items():
        p.add_argument(f"--{k}", type=type(v), default=v)
    p.add_argument("--data_dir", type=str, default="./solpsnn_dataset_1")
    return p.parse_args()


if __name__ == "__main__":
    multiprocessing.freeze_support()
    args = parse_args()
    # Windows spawn nie radzi sobie z pickle dużych datasetów
    if sys.platform == "win32" and args.num_workers > 0:
        print(f"[WARN] Windows: wymuszam num_workers=0 (było {args.num_workers})")
        args.num_workers = 0
    train(args)
