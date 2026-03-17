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

#Hiperparametry domyślne
DEFAULTS = {
    "latent_dim": 128,       
    "batch_size": 128,          
    "lr": 2e-4,                
    "epochs": 500,             
    "weight_decay": 1e-6,      
    "kl_beta_max": 1.0,
    "kl_beta_init": 0.0,
    "kl_anneal_epochs": 100,
    "w_rec": 1.0,
    "w_nonneg": 1e-3,
    "w_bohm": 5e-4,
    "w_div": 3e-3,
    "grad_clip": 5.0,
    "save_dir": "./checkpoints",
    "nx": 104,
    "ny": 50,
    "ns": 10,
    "device": "cuda" if torch.cuda.is_available() else "cpu",
    "seed": 1234,
    "patience": 25,
    "save_every": 50,
}

m_deuterium = 3.344e-27  # kg
k_B = 1.380649e-23       # J/K

#dataset
class TokamakDataset(Dataset):
    def __init__(self, data_dir: str, split: str = "train", norm_stats=None):
        root = Path(data_dir) / split
        if not root.exists():
            print(f"Warning: Data dir {root} not found. Creating dummy data for test.")
            self._create_dummy_data(root)
            
        self.X = np.load(root / "X_tmp.npy").astype(np.float32)
        self.te = np.load(root / "te_tmp.npy").astype(np.float32)
        self.ti = np.load(root / "ti_tmp.npy").astype(np.float32)
        self.na = np.load(root / "na_tmp.npy").astype(np.float32)
        self.ua = np.load(root / "ua_tmp.npy").astype(np.float32)
        
        self.norm_path = Path(data_dir) / "norm_stats.npz"
        if norm_stats is not None:
            self._load_norm_stats(norm_stats)
        elif split == "train":
            self._compute_normalization()
            np.savez(self.norm_path, **self._get_norm_dict())
        else:
            if self.norm_path.exists():
                self._load_norm_stats(np.load(self.norm_path))
            else:
                 # dla pierwszego uruchomienia bez wytrenowanego modelu
                self._compute_normalization()

    def _create_dummy_data(self, root):
        root.mkdir(parents=True, exist_ok=True)
        N = 100
        np.save(root / "X_tmp.npy", np.random.randn(N, 8))
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
        self.na_mean = np.mean(na_log, axis=(0,1,2))
        self.na_std = np.std(na_log, axis=(0,1,2)) + 1e-8
        self.ua_mean = np.mean(self.ua, axis=(0,1,2))
        self.ua_std = np.std(self.ua, axis=(0,1,2)) + 1e-8
        self.X_mean = self.X.mean(axis=0)
        self.X_std = self.X.std(axis=0) + 1e-8

    def _get_norm_dict(self):
        return dict(te_mean=self.te_mean, te_std=self.te_std,
                    ti_mean=self.ti_mean, ti_std=self.ti_std,
                    na_mean=self.na_mean, na_std=self.na_std,
                    ua_mean=self.ua_mean, ua_std=self.ua_std,
                    X_mean=self.X_mean, X_std=self.X_std)

    def _load_norm_stats(self, stats):
        for k in stats:
            val = stats[k]
            if isinstance(val, np.ndarray):
                setattr(self, k, val.astype(np.float32))
            else:
                setattr(self, k, float(val))

    def __len__(self): return self.X.shape[0]

    def __getitem__(self, idx):
        x = self.X[idx].astype(np.float32)
        te, ti, na, ua = self.te[idx], self.ti[idx], self.na[idx], self.ua[idx]

        te_n = (np.log1p(np.clip(te, 0, None)) - self.te_mean) / self.te_std
        ti_n = (np.log1p(np.clip(ti, 0, None)) - self.ti_mean) / self.ti_std
        na_n = (np.log1p(np.clip(na, 0, None)) - self.na_mean[np.newaxis, np.newaxis, :]) / self.na_std[np.newaxis, np.newaxis, :]
        ua_n = (ua - self.ua_mean[np.newaxis, np.newaxis, :]) / self.ua_std[np.newaxis, np.newaxis, :]

        channels = [te_n[np.newaxis, ...], ti_n[np.newaxis, ...]]
        channels += [na_n[..., i][np.newaxis, ...] for i in range(na_n.shape[-1])]
        channels += [ua_n[..., i][np.newaxis, ...] for i in range(ua_n.shape[-1])]
        x_field = np.concatenate(channels, axis=0).astype(np.float32)
        x_cond = (x - self.X_mean) / self.X_std

        return {"x_cond": x_cond, "field": x_field}

class HybridEncoder(nn.Module):
    """
    Encoder combining CNN for local features and Transformer for global dependencies.
    """
    def __init__(self, in_channels, latent_dim):
        super().__init__()
        # 1. Local feature extraction (CNN)
        self.features = nn.Sequential(
            nn.Conv2d(in_channels, 64, 3, padding=1), nn.GroupNorm(8, 64), nn.ReLU(),
            nn.Conv2d(64, 128, 3, stride=2, padding=1), nn.GroupNorm(8, 128), nn.ReLU(),
            nn.Conv2d(128, 256, 3, stride=2, padding=1), nn.GroupNorm(8, 256), nn.ReLU(),
            nn.Conv2d(256, 512, 3, stride=2, padding=1), nn.GroupNorm(16, 512), nn.ReLU()
        ) # Output: 512 x H/8 x W/8
        
        # 2. Global context (Transformer)
        # Flatten spatial dimensions into sequence: (Batch, Channels, H*W) -> (Batch, H*W, Channels)
        self.transformer_layer = nn.TransformerEncoderLayer(d_model=512, nhead=4, batch_first=True)
        self.transformer = nn.TransformerEncoder(self.transformer_layer, num_layers=2)
        
        self.pool = nn.AdaptiveAvgPool1d(1) # Pooling over sequence
        self.fc_mu = nn.Linear(512, latent_dim)
        self.fc_logvar = nn.Linear(512, latent_dim)

    def forward(self, x):
        # x: [B, C, H, W]
        h = self.features(x) 
        B, C, H, W = h.shape
        
        # Reshape for transformer: [B, H*W, C]
        h_seq = h.view(B, C, -1).permute(0, 2, 1) 
        
        # Apply Transformer
        h_trans = self.transformer(h_seq) # [B, Seq, C]
        
        # Pool: [B, C, Seq] -> [B, C, 1]
        h_pooled = self.pool(h_trans.permute(0, 2, 1)).view(B, -1)
        
        return self.fc_mu(h_pooled), self.fc_logvar(h_pooled)

class ResBlock(nn.Module):
    """
    Residual Block for Decoder stability.
    """
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

class ResidualDecoder(nn.Module):
    def __init__(self, latent_dim, cond_dim, out_channels, nx, ny):
        super().__init__()
        self.nx, self.ny = nx, ny
        self.h_w, self.h_h = math.ceil(nx/8), math.ceil(ny/8)
        
        self.fc = nn.Sequential(
            nn.Linear(latent_dim + cond_dim, 512), nn.ReLU(),
            nn.Linear(512, 512 * self.h_w * self.h_h), nn.ReLU()
        )
        
        # Transposed Conv + ResBlocks structure
        self.deconv = nn.Sequential(
            nn.ConvTranspose2d(512, 256, 4, 2, 1), # Upsample
            nn.GroupNorm(16, 256), nn.ReLU(),
            ResBlock(256), # Residual Block
            
            nn.ConvTranspose2d(256, 128, 4, 2, 1), # Upsample
            nn.GroupNorm(8, 128), nn.ReLU(),
            ResBlock(128), # Residual Block
            
            nn.ConvTranspose2d(128, 64, 4, 2, 1),  # Upsample
            nn.GroupNorm(8, 64), nn.ReLU(),
            ResBlock(64), # Residual Block
            
            nn.Conv2d(64, out_channels, 3, padding=1)
        )

    def forward(self, z, c):
        x = torch.cat([z, c], dim=1)
        h = self.fc(x).view(x.size(0), 512, self.h_w, self.h_h)
        out = self.deconv(h)
        return F.interpolate(out, size=(self.nx, self.ny), mode='bilinear', align_corners=False)

class PriorNet(nn.Module):
    # Conditional Prior Network (Standard CVAE)
    def __init__(self, cond_dim, latent_dim):
        super().__init__()
        self.net = nn.Sequential(nn.Linear(cond_dim, 128), nn.ReLU(),
                                 nn.Linear(128, 128), nn.ReLU())
        self.fc_mu, self.fc_logvar = nn.Linear(128, latent_dim), nn.Linear(128, latent_dim)
    def forward(self, c):
        h = self.net(c)
        return self.fc_mu(h), self.fc_logvar(h)

class CVAE(nn.Module):
    def __init__(self, in_channels, cond_dim, latent_dim, nx, ny):
        super().__init__()
        self.encoder = HybridEncoder(in_channels, latent_dim) # Now using Transformer
        self.prior = PriorNet(cond_dim, latent_dim)
        self.decoder = ResidualDecoder(latent_dim, cond_dim, in_channels, nx, ny) # Now using ResBlocks
        self.latent_dim = latent_dim

    def reparameterize(self, mu, logvar):
        std, eps = torch.exp(0.5*logvar), torch.randn_like(logvar)
        return mu + eps*std

    def forward(self, x_field, c):
        q_mu, q_logvar = self.encoder(x_field)
        z = self.reparameterize(q_mu, q_logvar)
        p_mu, p_logvar = self.prior(c)
        x_rec = self.decoder(z, c)
        return {"x_rec": x_rec, "q_mu": q_mu, "q_logvar": q_logvar, "p_mu": p_mu, "p_logvar": p_logvar}

# strary fizyczne 
def nonneg_penalty_phys(x_rec, channels_info, stats):
    device = x_rec.device
    penalties = []
    # Ograniczenie wartości przed exp, aby uniknąć inf (Numerical Stability), bo wyskakiwało czasem
    te = torch.exp(torch.clamp(x_rec[:, channels_info["te_idx"]] * stats["te_std"] + stats["te_mean"], max=15)) - 1
    ti = torch.exp(torch.clamp(x_rec[:, channels_info["ti_idx"]] * stats["ti_std"] + stats["ti_mean"], max=15)) - 1
    penalties += [F.relu(-te).mean(), F.relu(-ti).mean()]
    for i, ch in enumerate(channels_info["na_indices"]):
        na = torch.exp(torch.clamp(x_rec[:, ch]*stats["na_std"][i] + stats["na_mean"][i], max=15)) - 1
        penalties.append(F.relu(-na).mean())
    return torch.stack(penalties).sum().to(device)

def bohm_penalty_phys_improved(x_rec, channels_info, stats):
    """
    Penalize |u| > cs in the bulk plasma (SOL flows shouldn't randomly exceed sound speed).
    """
    te = torch.exp(torch.clamp(x_rec[:, channels_info["te_idx"]] * stats["te_std"] + stats["te_mean"], max=15)) - 1
    ti = torch.exp(torch.clamp(x_rec[:, channels_info["ti_idx"]] * stats["ti_std"] + stats["ti_mean"], max=15)) - 1
    
    # Calculate sound speed
    cs = torch.sqrt(torch.clamp((te + ti) / m_deuterium, min=1e-8))
    
    # Get velocity
    ua = x_rec[:, channels_info["ua_indices"][channels_info.get("D1_pos_in_ua", 0)]] * \
         stats["ua_std"][0] + stats["ua_mean"][0]
    
    # Penalty: if |ua| > cs (supersonic in bulk is generally penalized unless near target)
    # Using Softplus or ReLU for gradient flow
    excess_velocity = F.relu(torch.abs(ua) - cs)
    
    return (excess_velocity ** 2).mean()

def divergence_penalty_robust(x_rec, channels_info):
    """
    Calculates Divergence using Central Differences with Padding.
    Prevents loss of boundary information and provides smoother gradients.
    Approximation: div(n*u) = d(nu)/dx + d(nu)/dy
    """
    penalties = []
    for (n_idx, u_idx) in channels_info["species_pairs"]:
        n = x_rec[:, n_idx] # Shape: [B, H, W]
        u = x_rec[:, u_idx]
        flux = n * u        # Flux Gamma = n*u
        
        # 1. Pad tensor to handle boundaries (Replicate padding approximates Neumann BC)
        flux_padded = F.pad(flux, (1, 1, 1, 1), mode='replicate')
        
        # 2. Central differences: (f(x+1) - f(x-1)) / 2
        # df/dx (along last dim W)
        df_dx = (flux_padded[:, 1:-1, 2:] - flux_padded[:, 1:-1, :-2]) / 2.0
        
        # df/dy (along second to last dim H)
        df_dy = (flux_padded[:, 2:, 1:-1] - flux_padded[:, :-2, 1:-1]) / 2.0
        
        div = df_dx + df_dy
        penalties.append((div ** 2).mean())
        
    return torch.stack(penalties).sum()

def kl_divergence(mu_q, logvar_q, mu_p, logvar_p):
    var_q, var_p = torch.exp(logvar_q), torch.exp(logvar_p)
    term = (var_q + (mu_q - mu_p)**2) / (var_p + 1e-12)
    return 0.5 * torch.sum((logvar_p - logvar_q) + term - 1, dim=1).mean()

def get_kl_beta(epoch, init, maxv, anneal_epochs):
    return maxv if epoch >= anneal_epochs else init + (maxv - init) * epoch / max(1, anneal_epochs)

# pętla treningowa
def set_seed(seed):
    random.seed(seed); np.random.seed(seed)
    torch.manual_seed(seed); torch.cuda.manual_seed_all(seed)

def train(args):
    set_seed(args.seed)
    ds_train = TokamakDataset(args.data_dir, "train")
    # Ładowanie 
    stats_path = Path(args.data_dir)/"norm_stats.npz"
    test_stats = np.load(stats_path) if stats_path.exists() else None
    ds_test = TokamakDataset(args.data_dir, "test", norm_stats=test_stats)
    
    pin_mem = "cuda" in args.device
    train_loader = DataLoader(ds_train, batch_size=args.batch_size, shuffle=True, pin_memory=pin_mem)
    test_loader = DataLoader(ds_test, batch_size=args.batch_size, shuffle=False, pin_memory=pin_mem)

    in_channels = 2 + args.ns + args.ns
    model = CVAE(in_channels, 8, args.latent_dim, args.nx, args.ny).to(args.device)
    optim = torch.optim.Adam(model.parameters(), lr=args.lr, weight_decay=args.weight_decay)
    scheduler = torch.optim.lr_scheduler.ReduceLROnPlateau(optim, factor=0.5, patience=10)
    scaler = torch.cuda.amp.GradScaler(enabled="cuda" in args.device)

    na_indices = [2+i for i in range(args.ns)]
    ua_indices = [2+args.ns+i for i in range(args.ns)]
    channels_info = {
        "te_idx": 0, "ti_idx": 1, "na_indices": na_indices,
        "ua_indices": ua_indices, "species_pairs": [(2+j, 2+args.ns+j) for j in range(args.ns)],
        "D1_pos_in_ua": 0
    }

    stats = {k: torch.tensor(v, device=args.device, dtype=torch.float32)
             for k, v in ds_train._get_norm_dict().items()}

    best_val, epochs_no_improve = float("inf"), 0
    os.makedirs(args.save_dir, exist_ok=True)

    print(f"Starting training on {args.device} with Hybrid Transformer Encoder...")

    for epoch in range(1, args.epochs+1):
        model.train(); train_loss=0; n=0
        
        # Progress bar
        pbar = tqdm(train_loader, desc=f"Epoch {epoch}/{args.epochs}")
        for batch in pbar:
            x_cond, x_field = batch["x_cond"].to(args.device), batch["field"].to(args.device)
            optim.zero_grad()
            with torch.cuda.amp.autocast(enabled="cuda" in args.device):
                out = model(x_field, x_cond)
                rec_loss = F.mse_loss(out["x_rec"], x_field)
                kld = kl_divergence(out["q_mu"], out["q_logvar"], out["p_mu"], out["p_logvar"])
                
                # Physics Losses
                nonneg = nonneg_penalty_phys(out["x_rec"], channels_info, stats)
                divpen = divergence_penalty_robust(out["x_rec"], channels_info) 
                bohm = bohm_penalty_phys_improved(out["x_rec"], channels_info, stats) 
                
                klb = get_kl_beta(epoch, args.kl_beta_init, args.kl_beta_max, args.kl_anneal_epochs)
                loss = args.w_rec*rec_loss + klb*kld + args.w_nonneg*nonneg + args.w_div*divpen + args.w_bohm*bohm
            
            scaler.scale(loss).backward()
            torch.nn.utils.clip_grad_norm_(model.parameters(), args.grad_clip)
            scaler.step(optim); scaler.update()
            
            train_loss += loss.item()*x_field.size(0); n += x_field.size(0)
            pbar.set_postfix({"Loss": loss.item()})
            
        train_loss /= n

        # Validation
        model.eval(); val_loss=0; n=0
        with torch.no_grad(), torch.cuda.amp.autocast(enabled="cuda" in args.device):
            for batch in test_loader:
                x_cond, x_field = batch["x_cond"].to(args.device), batch["field"].to(args.device)
                out = model(x_field, x_cond)
                rec_loss = F.mse_loss(out["x_rec"], x_field)
                kld = kl_divergence(out["q_mu"], out["q_logvar"], out["p_mu"], out["p_logvar"])
                nonneg = nonneg_penalty_phys(out["x_rec"], channels_info, stats)
                divpen = divergence_penalty_robust(out["x_rec"], channels_info)
                bohm = bohm_penalty_phys_improved(out["x_rec"], channels_info, stats)
                klb = get_kl_beta(epoch, args.kl_beta_init, args.kl_beta_max, args.kl_anneal_epochs)
                loss = args.w_rec*rec_loss + klb*kld + args.w_nonneg*nonneg + args.w_div*divpen + args.w_bohm*bohm
                val_loss += loss.item()*x_field.size(0); n += x_field.size(0)
        val_loss /= n
        scheduler.step(val_loss)

        print(f"Epoch {epoch}: train={train_loss:.6f} val={val_loss:.6f}")

        if val_loss < best_val - 1e-8:
            best_val = val_loss
            torch.save(model.state_dict(), os.path.join(args.save_dir, f"cvae_best.pth"))
            epochs_no_improve = 0
        else:
            epochs_no_improve += 1
   
        if epochs_no_improve >= args.patience:
            print("Early stopping."); break

    print("Training complete.")

# start
def parse_args():
    p = argparse.ArgumentParser()
    for k,v in DEFAULTS.items(): p.add_argument(f"--{k}", type=type(v), default=v)
    p.add_argument("--data_dir", type=str, default="./")
    return p.parse_args()

if __name__ == "__main__":
    args = parse_args()
    train(args)