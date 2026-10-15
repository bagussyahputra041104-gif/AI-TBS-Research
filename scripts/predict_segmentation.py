from pathlib import Path

import cv2
import numpy as np
import torch
import torch.nn as nn


# =========================
# PATH
# =========================
IMAGE_DIR = Path("dataset/segmentation/images")
MODEL_PATH = Path(
    "models/experiments/baseline_segmentation/unet_small_baseline.pth"
)
OUTPUT_DIR = Path("results/08_baseline_prediction")

IMAGE_SIZE = 256
THRESHOLD = 0.5


# =========================
# MODEL
# =========================
class DoubleConv(nn.Module):
    def __init__(self, in_channels, out_channels):
        super().__init__()

        self.block = nn.Sequential(
            nn.Conv2d(in_channels, out_channels, 3, padding=1),
            nn.ReLU(inplace=True),

            nn.Conv2d(out_channels, out_channels, 3, padding=1),
            nn.ReLU(inplace=True),
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
            64, 32, 2, stride=2
        )
        self.dec2 = DoubleConv(64, 32)

        self.up1 = nn.ConvTranspose2d(
            32, 16, 2, stride=2
        )
        self.dec1 = DoubleConv(32, 16)

        self.output = nn.Conv2d(16, 1, 1)

    def forward(self, x):
        e1 = self.enc1(x)

        e2 = self.enc2(
            self.pool1(e1)
        )

        b = self.bottleneck(
            self.pool2(e2)
        )

        d2 = self.up2(b)

        d2 = torch.cat(
            [d2, e2],
            dim=1
        )

        d2 = self.dec2(d2)

        d1 = self.up1(d2)

        d1 = torch.cat(
            [d1, e1],
            dim=1
        )

        d1 = self.dec1(d1)

        return self.output(d1)


# =========================
# MAIN
# =========================
def main():

    OUTPUT_DIR.mkdir(
        parents=True,
        exist_ok=True
    )

    device = torch.device("cpu")

    print("Device:", device)
    print("Model :", MODEL_PATH)
    print()

    # Load model
    model = UNetSmall().to(device)

    model.load_state_dict(
        torch.load(
            MODEL_PATH,
            map_location=device
        )
    )

    model.eval()

    # Ambil semua gambar
    images = sorted(
        IMAGE_DIR.glob("*.png")
    )

    print("Jumlah gambar:", len(images))
    print()

    for image_path in images:

        print(
            "Memproses:",
            image_path.name
        )

        # Baca gambar
        image = cv2.imread(
            str(image_path)
        )

        if image is None:
            print("  Gagal membaca gambar.")
            continue

        original_h, original_w = image.shape[:2]

        # BGR -> RGB
        rgb = cv2.cvtColor(
            image,
            cv2.COLOR_BGR2RGB
        )

        # Resize untuk model
        resized = cv2.resize(
            rgb,
            (IMAGE_SIZE, IMAGE_SIZE),
            interpolation=cv2.INTER_AREA
        )

        # Normalisasi
        resized = (
            resized.astype(np.float32)
            / 255.0
        )

        # HWC -> CHW
        tensor = torch.from_numpy(
            resized
        ).permute(2, 0, 1)

        # Tambahkan batch dimension
        tensor = tensor.unsqueeze(0)

        # Prediksi
        with torch.no_grad():

            output = model(
                tensor.to(device)
            )

            probability = torch.sigmoid(
                output
            )

        # Threshold
        mask = (
            probability[0, 0]
            .cpu()
            .numpy()
            > THRESHOLD
        ).astype(np.uint8) * 255

        # Kembalikan ke ukuran asli
        mask = cv2.resize(
            mask,
            (original_w, original_h),
            interpolation=cv2.INTER_NEAREST
        )

        # =========================
        # SIMPAN MASK
        # =========================
        mask_path = (
            OUTPUT_DIR
            / f"{image_path.stem}_prediction_mask.png"
        )

        cv2.imwrite(
            str(mask_path),
            mask
        )

        # =========================
        # BUAT OVERLAY
        # =========================
        overlay = image.copy()

        # Warna putih transparan pada area TBS
        color = np.zeros_like(image)
        color[:, :] = (0, 255, 0)

        alpha = 0.35

        foreground = mask > 0

        overlay[foreground] = (
            overlay[foreground] * (1 - alpha)
            + color[foreground] * alpha
        ).astype(np.uint8)

        overlay_path = (
            OUTPUT_DIR
            / f"{image_path.stem}_overlay.png"
        )

        cv2.imwrite(
            str(overlay_path),
            overlay
        )

        print(
            "  Mask   :", mask_path
        )

        print(
            "  Overlay:", overlay_path
        )

        print()

    print("==============================")
    print("Prediksi selesai.")
    print("Hasil disimpan di:")
    print(OUTPUT_DIR)
    print("==============================")


if __name__ == "__main__":
    main()