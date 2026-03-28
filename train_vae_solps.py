import os
import argparse
from pathlib import Path
import math
import numpy as np
import torch
import torch.nn as nn
import torch.nn.functional as F
from torch.utils.data import Dataset, DataLoader
from tqdm import tqdm
import random

# Hiperparametry domyslne (bez PI i conditional)
DEFAULTS = {
    "latent_dim": 128,
    "batch_size": 64,
    "lr": 1e-4,
    "epochs": 600,
    "weight_decay": 1e-5,
    "kl_beta_max": 0.15,
    "kl_beta_init": 0.0,
    "kl_anneal_epochs": 100,
    "w_rec": 1.0,
    "grad_clip": 1.0,
    "save_dir": "./checkpoints_vae",
    "nx": 104,
    "ny": 50,
    "ns": 10,
    "device": "cuda" if torch.cuda.is_available() else "cpu",
    "seed": 1234,
    "patience": 50,
    "save_every": 50,
}

# Dataset
class TokamakDataset(Dataset):
    def __init__(self, data_dir: str, split: str = "train", norm_stats=None):
        root = Path(data_dir) / split
        if not root.exists():
            print(f"Warning: Data dir {root} not found. Creating dummy data for test.")
            self._create_dummy_data(root)

        self.te = np.load(root / "te_tmp.npy").astype(np.float32)
        self.ti = np.load(root / "ti_tmp.npy").astype(np.float32)
        self.na = np.load(root / "na_tmp.npy").astype(np.float32)
        self.ua = np.load(root / "ua_tmp.npy").astype(np.float32)

        self.norm_path = Path(data_dir) / "norm_stats_vae.npz"
        if norm_stats is not None:
            self._load_norm_stats(norm_stats)
        elif split == "train":
            self._compute_normalization()
            np.savez(self.norm_path, **self._get_norm_dict())
        else:
            if self.norm_path.exists():
                self._load_norm_stats(np.load(self.norm_path))
            else:
                self._compute_normalization()

    def _create_dummy_data(self, root):
        root.mkdir(parents=True, exist_ok=True)
        N = 100
        np.save(root / "te_tmp.npy", np.abs(np.random.randn(N, 104, 50)))
        np.save(root / "ti_tmp.npy", np.abs(np.random.randn(N, 104, 50)))
        np.save(root / "na_tmp.npy", np.abs(np.random.randn(N, 104, 50, 10)))
        np.save(root / "ua_tmp.npy", np.random.randn(N, 104, 50, 10))

    def _compute_normalization(self):
        te_log = np.log1p(np.clip(self.te, 0, None))
        ti_log = np.log1p(np.clip(self.ti, 0, None))
        na_log = np.log1p(np.clip(self.na, 0, None))
        self.te_mean, self.te_std = float(te_log.mean()), float(te_log.std() + 1e-8)
        self.ti_mean, self.ti_std = float(ti_log.mean()), float(ti_log.std() + 1e-8)
        self.na_mean = np.mean(na_log, axis=(0, 1, 2))
        self.na_std = np.std(na_log, axis=(0, 1, 2)) + 1e-8
        self.ua_mean = np.mean(self.ua, axis=(0, 1, 2))
        self.ua_std = np.std(self.ua, axis=(0, 1, 2)) + 1e-8

    def _get_norm_dict(self):
        return dict(te_mean=self.te_mean, te_std=self.te_std,
                    ti_mean=self.ti_mean, ti_std=self.ti_std,
                    na_mean=self.na_mean, na_std=self.na_std,
                    ua_mean=self.ua_mean, ua_std=self.ua_std)

    def _load_norm_stats(self, stats):
        for k in stats:
            val = stats[k]
            if isinstance(val, np.ndarray):
                setattr(self, k, val.astype(np.float32))
            else:
                setattr(self, k, float(val))

    def __len__(self): return self.te.shape[0]

    def __getitem__(self, idx):
        te, ti, na, ua = self.te[idx], self.ti[idx], self.na[idx], self.ua[idx]

        te_n = (np.log1p(np.clip(te, 0, None)) - self.te_mean) / self.te_std
        ti_n = (np.log1p(np.clip(ti, 0, None)) - self.ti_mean) / self.ti_std
        na_n = (np.log1p(np.clip(na, 0, None)) - self.na_mean[np.newaxis, np.newaxis, :]) / self.na_std[np.newaxis, np.newaxis, :]
        ua_n = (ua - self.ua_mean[np.newaxis, np.newaxis, :]) / self.ua_std[np.newaxis, np.newaxis, :]

        channels = [te_n[np.newaxis, ...], ti_n[np.newaxis, ...]]
        channels += [na_n[..., i][np.newaxis, ...] for i in range(na_n.shape[-1])]
        channels += [ua_n[..., i][np.newaxis, ...] for i in range(ua_n.shape[-1])]
        x_field = np.concatenate(channels, axis=0).astype(np.float32)

        return {"field": x_field}


class HybridEncoder(nn.Module):
    """
    Encoder combining CNN for local features and Transformer for global dependencies.
    """
    def __init__(self, in_channels, latent_dim):
        super().__init__()
        self.features = nn.Sequential(
            nn.Conv2d(in_channels, 64, 3, padding=1), nn.GroupNorm(8, 64), nn.ReLU(),
            nn.Conv2d(64, 128, 3, stride=2, padding=1), nn.GroupNorm(8, 128), nn.ReLU(),
            nn.Conv2d(128, 256, 3, stride=2, padding=1), nn.GroupNorm(8, 256), nn.ReLU(),
            nn.Conv2d(256, 512, 3, stride=2, padding=1), nn.GroupNorm(16, 512), nn.ReLU()
        )

        self.transformer_layer = nn.TransformerEncoderLayer(d_model=512, nhead=4, batch_first=True)
        self.transformer = nn.TransformerEncoder(self.transformer_layer, num_layers=2)

        self.pool = nn.AdaptiveAvgPool1d(1)
        self.fc_mu = nn.Linear(512, latent_dim)
        self.fc_logvar = nn.Linear(512, latent_dim)

    def forward(self, x):
        h = self.features(x)
        B, C, H, W = h.shape
        h_seq = h.view(B, C, -1).permute(0, 2, 1)
        h_trans = self.transformer(h_seq)
        h_pooled = self.pool(h_trans.permute(0, 2, 1)).view(B, -1)
        return self.fc_mu(h_pooled), self.fc_logvar(h_pooled)


class ResBlock(nn.Module):
    def __init__(self, channels):
        super().__init__()
        self.block = nn.Sequential(
            nn.Conv2d(channels, channels, 3, padding=1),
            nn.GroupNorm(8, channels),
            nn.ReLU(),
            nn.Conv2d(channels, channels, 3, padding=1),
            nn.GroupNorm(8, channels)
        )
        self.relu = nn.ReLU()

    def forward(self, x):
        return self.relu(x + self.block(x))


class Decoder(nn.Module):
    """Decoder bez warunku - przyjmuje tylko wektor latentny z."""
    def __init__(self, latent_dim, out_channels, nx, ny):
        super().__init__()
        self.nx, self.ny = nx, ny
        self.h_w, self.h_h = math.ceil(nx / 8), math.ceil(ny / 8)

        self.fc = nn.Sequential(
            nn.Linear(latent_dim, 512), nn.ReLU(),
            nn.Linear(512, 512 * self.h_w * self.h_h), nn.ReLU()
        )

        self.deconv = nn.Sequential(
            nn.ConvTranspose2d(512, 256, 4, 2, 1),
            nn.GroupNorm(16, 256), nn.ReLU(),
            ResBlock(256),

            nn.ConvTranspose2d(256, 128, 4, 2, 1),
            nn.GroupNorm(8, 128), nn.ReLU(),
            ResBlock(128),

            nn.ConvTranspose2d(128, 64, 4, 2, 1),
            nn.GroupNorm(8, 64), nn.ReLU(),
            ResBlock(64),

            nn.Conv2d(64, out_channels, 3, padding=1)
        )

    def forward(self, z):
        h = self.fc(z).view(z.size(0), 512, self.h_w, self.h_h)
        out = self.deconv(h)
        return F.interpolate(out, size=(self.nx, self.ny), mode='bilinear', align_corners=False)


class VAE(nn.Module):
    """Vanilla VAE - bez warunku (conditional) i bez prior network."""
    def __init__(self, in_channels, latent_dim, nx, ny):
        super().__init__()
        self.encoder = HybridEncoder(in_channels, latent_dim)
        self.decoder = Decoder(latent_dim, in_channels, nx, ny)
        self.latent_dim = latent_dim

    def reparameterize(self, mu, logvar):
        std = torch.exp(0.5 * logvar)
        eps = torch.randn_like(logvar)
        return mu + eps * std

    def forward(self, x_field):
        q_mu, q_logvar = self.encoder(x_field)
        z = self.reparameterize(q_mu, q_logvar)
        x_rec = self.decoder(z)
        return {"x_rec": x_rec, "q_mu": q_mu, "q_logvar": q_logvar}


# KL divergence vs standard normal N(0,1)
def kl_divergence_standard(mu, logvar):
    return -0.5 * torch.sum(1 + logvar - mu.pow(2) - logvar.exp(), dim=1).mean()


def get_kl_beta(epoch, init, maxv, anneal_epochs):
    return maxv if epoch >= anneal_epochs else init + (maxv - init) * epoch / max(1, anneal_epochs)


def nonneg_penalty_phys(x_rec, ns, stats):
    """Penalizacja ujemnych Te, Ti i gęstości na (po denormalizacji log1p+z-score)."""
    penalties = []
    te_phys = torch.exp(torch.clamp(x_rec[:, 0] * stats["te_std"] + stats["te_mean"], max=15)) - 1
    ti_phys = torch.exp(torch.clamp(x_rec[:, 1] * stats["ti_std"] + stats["ti_mean"], max=15)) - 1
    penalties.append(F.relu(-te_phys).mean())
    penalties.append(F.relu(-ti_phys).mean())
    for i in range(ns):
        na_phys = torch.exp(torch.clamp(
            x_rec[:, 2 + i] * stats["na_std"][i] + stats["na_mean"][i], max=15)) - 1
        penalties.append(F.relu(-na_phys).mean())
    return torch.stack(penalties).sum()


# Petla treningowa
def set_seed(seed):
    random.seed(seed); np.random.seed(seed)
    torch.manual_seed(seed); torch.cuda.manual_seed_all(seed)


def train(args):
    set_seed(args.seed)
    ds_train = TokamakDataset(args.data_dir, "train")
    stats_path = Path(args.data_dir) / "norm_stats_vae.npz"
    test_stats = np.load(stats_path) if stats_path.exists() else None
    ds_test = TokamakDataset(args.data_dir, "test", norm_stats=test_stats)

    pin_mem = "cuda" in args.device
    train_loader = DataLoader(ds_train, batch_size=args.batch_size, shuffle=True, pin_memory=pin_mem)
    test_loader = DataLoader(ds_test, batch_size=args.batch_size, shuffle=False, pin_memory=pin_mem)

    in_channels = 2 + args.ns + args.ns
    model = VAE(in_channels, args.latent_dim, args.nx, args.ny).to(args.device)
    optim = torch.optim.Adam(model.parameters(), lr=args.lr, weight_decay=args.weight_decay)
    scheduler = torch.optim.lr_scheduler.CosineAnnealingLR(optim, T_max=args.epochs, eta_min=1e-6)
    scaler = torch.cuda.amp.GradScaler(enabled="cuda" in args.device)

    best_val, epochs_no_improve = float("inf"), 0
    os.makedirs(args.save_dir, exist_ok=True)

    # Przygotuj statystyki normalizacji jako tensory do nonneg_penalty
    norm_dict = ds_train._get_norm_dict()
    phys_stats = {}
    for k, v in norm_dict.items():
        t = torch.tensor(v, dtype=torch.float32, device=args.device)
        phys_stats[k] = t

    print(f"Starting VAE training on {args.device} (no PI, no conditional)...")

    for epoch in range(1, args.epochs + 1):
        model.train(); train_loss = 0; n = 0

        pbar = tqdm(train_loader, desc=f"Epoch {epoch}/{args.epochs}")
        for batch in pbar:
            x_field = batch["field"].to(args.device)
            optim.zero_grad()
            with torch.cuda.amp.autocast(enabled="cuda" in args.device):
                out = model(x_field)
                rec_loss = F.mse_loss(out["x_rec"], x_field)
                kld = kl_divergence_standard(out["q_mu"], out["q_logvar"])

                klb = get_kl_beta(epoch, args.kl_beta_init, args.kl_beta_max, args.kl_anneal_epochs)
                nonneg = nonneg_penalty_phys(out["x_rec"], args.ns, phys_stats)
                loss = args.w_rec * rec_loss + klb * kld + 5e-3 * nonneg

            scaler.scale(loss).backward()
            torch.nn.utils.clip_grad_norm_(model.parameters(), args.grad_clip)
            scaler.step(optim); scaler.update()

            train_loss += loss.item() * x_field.size(0); n += x_field.size(0)
            pbar.set_postfix({"Loss": loss.item()})

        train_loss /= n

        # Validation
        model.eval(); val_loss = 0; n = 0
        with torch.no_grad(), torch.cuda.amp.autocast(enabled="cuda" in args.device):
            for batch in test_loader:
                x_field = batch["field"].to(args.device)
                out = model(x_field)
                rec_loss = F.mse_loss(out["x_rec"], x_field)
                kld = kl_divergence_standard(out["q_mu"], out["q_logvar"])
                klb = get_kl_beta(epoch, args.kl_beta_init, args.kl_beta_max, args.kl_anneal_epochs)
                nonneg = nonneg_penalty_phys(out["x_rec"], args.ns, phys_stats)
                loss = args.w_rec * rec_loss + klb * kld + 5e-3 * nonneg
                val_loss += loss.item() * x_field.size(0); n += x_field.size(0)
        val_loss /= n
        scheduler.step()

        print(f"Epoch {epoch}: train={train_loss:.6f} val={val_loss:.6f}")

        if val_loss < best_val - 1e-8:
            best_val = val_loss
            torch.save(model.state_dict(), os.path.join(args.save_dir, "vae_best.pth"))
            epochs_no_improve = 0
        else:
            epochs_no_improve += 1

        if epochs_no_improve >= args.patience:
            print("Early stopping."); break

    print("Training complete.")


def parse_args():
    p = argparse.ArgumentParser()
    for k, v in DEFAULTS.items(): p.add_argument(f"--{k}", type=type(v), default=v)
    p.add_argument("--data_dir", type=str, default="./")
    return p.parse_args()


if __name__ == "__main__":
    args = parse_args()
    train(args)
