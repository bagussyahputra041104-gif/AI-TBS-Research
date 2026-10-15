from pathlib import Path

import cv2
import numpy as np
import torch
import torch.nn as nn
from torch.utils.data import Dataset, DataLoader


# =========================================================
# CONFIG
# =========================================================

BASE_DIR = Path("dataset/segmentation/split")

TRAIN_DIR = BASE_DIR / "train"
VAL_DIR = BASE_DIR / "validation"

MODEL_DIR = Path("models/experiments/baseline_segmentation")
MODEL_DIR.mkdir(parents=True, exist_ok=True)

IMAGE_SIZE = 256
BATCH_SIZE = 1
EPOCHS = 20
LEARNING_RATE = 1e-3

DEVICE = torch.device("cuda" if torch.cuda.is_available() else "cpu")


# =========================================================
# DATASET
# =========================================================

class SegmentationDataset(Dataset):

    def __init__(self, image_dir, mask_dir):
        self.image_dir = Path(image_dir)
        self.mask_dir = Path(mask_dir)

        self.images = sorted(self.image_dir.glob("*.png"))

    def __len__(self):
        return len(self.images)

    def __getitem__(self, idx):

        image_path = self.images[idx]
        mask_path = self.mask_dir / f"{image_path.stem}_mask_manual.png"

        image = cv2.imread(str(image_path))
        image = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)

        mask = cv2.imread(str(mask_path), cv2.IMREAD_GRAYSCALE)

        image = cv2.resize(
            image,
            (IMAGE_SIZE, IMAGE_SIZE)
        )

        mask = cv2.resize(
            mask,
            (IMAGE_SIZE, IMAGE_SIZE),
            interpolation=cv2.INTER_NEAREST
        )

        image = image.astype(np.float32) / 255.0
        mask = (mask > 127).astype(np.float32)

        image = torch.from_numpy(image).permute(2, 0, 1)
        mask = torch.from_numpy(mask).unsqueeze(0)

        return image, mask


# =========================================================
# U-NET
# =========================================================

class DoubleConv(nn.Module):

    def __init__(self, in_channels, out_channels):

        super().__init__()

        self.block = nn.Sequential(
            nn.Conv2d(
                in_channels,
                out_channels,
                kernel_size=3,
                padding=1
            ),
            nn.ReLU(inplace=True),

            nn.Conv2d(
                out_channels,
                out_channels,
                kernel_size=3,
                padding=1
            ),
            nn.ReLU(inplace=True)
        )

    def forward(self, x):
        return self.block(x)


class UNetSmall(nn.Module):

    def __init__(self):

        super().__init__()

        self.enc1 = DoubleConv(3, 16)
        self.pool1 = nn.MaxPool2d(2)

        self.enc2 = DoubleConv(16, 32)
        self.pool2 = nn.MaxPool2d(2)

        self.bottleneck = DoubleConv(32, 64)

        self.up2 = nn.ConvTranspose2d(
            64,
            32,
            kernel_size=2,
            stride=2
        )

        self.dec2 = DoubleConv(64, 32)

        self.up1 = nn.ConvTranspose2d(
            32,
            16,
            kernel_size=2,
            stride=2
        )

        self.dec1 = DoubleConv(32, 16)

        self.out = nn.Conv2d(
            16,
            1,
            kernel_size=1
        )

    def forward(self, x):

        e1 = self.enc1(x)
        e2 = self.enc2(self.pool1(e1))

        b = self.bottleneck(self.pool2(e2))

        d2 = self.up2(b)
        d2 = torch.cat([d2, e2], dim=1)
        d2 = self.dec2(d2)

        d1 = self.up1(d2)
        d1 = torch.cat([d1, e1], dim=1)
        d1 = self.dec1(d1)

        return self.out(d1)


# =========================================================
# DICE
# =========================================================

def dice_score(pred, target):

    pred = torch.sigmoid(pred)

    pred = (pred > 0.5).float()

    intersection = (pred * target).sum()

    dice = (
        (2 * intersection + 1e-6)
        /
        (pred.sum() + target.sum() + 1e-6)
    )

    return dice.item()


# =========================================================
# TRAINING
# =========================================================

def main():

    print("================================")
    print("U-NET SEGMENTATION TRAINING")
    print("================================")

    print(f"Device: {DEVICE}")
    print()

    train_dataset = SegmentationDataset(
        TRAIN_DIR / "images",
        TRAIN_DIR / "masks"
    )

    val_dataset = SegmentationDataset(
        VAL_DIR / "images",
        VAL_DIR / "masks"
    )

    print(f"Training images   : {len(train_dataset)}")
    print(f"Validation images : {len(val_dataset)}")
    print()

    train_loader = DataLoader(
        train_dataset,
        batch_size=BATCH_SIZE,
        shuffle=True
    )

    val_loader = DataLoader(
        val_dataset,
        batch_size=BATCH_SIZE,
        shuffle=False
    )

    model = UNetSmall().to(DEVICE)

    criterion = nn.BCEWithLogitsLoss()

    optimizer = torch.optim.Adam(
        model.parameters(),
        lr=LEARNING_RATE
    )

    for epoch in range(EPOCHS):

        # -----------------------------
        # TRAIN
        # -----------------------------

        model.train()

        train_loss = 0.0
        train_dice = 0.0

        for images, masks in train_loader:

            images = images.to(DEVICE)
            masks = masks.to(DEVICE)

            optimizer.zero_grad()

            outputs = model(images)

            loss = criterion(outputs, masks)

            loss.backward()

            optimizer.step()

            train_loss += loss.item()
            train_dice += dice_score(
                outputs.detach(),
                masks
            )

        train_loss /= len(train_loader)
        train_dice /= len(train_loader)

        # -----------------------------
        # VALIDATION
        # -----------------------------

        model.eval()

        val_dice = 0.0

        with torch.no_grad():

            for images, masks in val_loader:

                images = images.to(DEVICE)
                masks = masks.to(DEVICE)

                outputs = model(images)

                val_dice += dice_score(
                    outputs,
                    masks
                )

        val_dice /= len(val_loader)

        print(
            f"Epoch {epoch + 1:02d}/{EPOCHS} "
            f"| Loss {train_loss:.4f} "
            f"| Train Dice {train_dice:.4f} "
            f"| Val Dice {val_dice:.4f}"
        )

    # =====================================================
    # SAVE MODEL
    # =====================================================

    model_path = (
        MODEL_DIR /
        "unet_small_split_baseline.pth"
    )

    torch.save(
        model.state_dict(),
        model_path
    )

    print()
    print("================================")
    print("Training selesai.")
    print(f"Model: {model_path}")
    print("================================")


if __name__ == "__main__":
    main()