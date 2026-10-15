import cv2
import numpy as np
import matplotlib.pyplot as plt
from pathlib import Path


IMAGE_DIR = Path("Fruitset")
MASK_DIR = Path("dataset/segmentation/masks")
OUTPUT_DIR = Path("results/13_color_distribution")

OUTPUT_DIR.mkdir(parents=True, exist_ok=True)


for image_path in sorted(IMAGE_DIR.glob("*.png")):

    mask_path = MASK_DIR / f"{image_path.stem}_mask_manual.png"

    if not mask_path.exists():
        continue

    image = cv2.imread(str(image_path))
    mask = cv2.imread(str(mask_path), cv2.IMREAD_GRAYSCALE)

    tbs = mask > 127

    hsv = cv2.cvtColor(image, cv2.COLOR_BGR2HSV)

    H = hsv[:, :, 0][tbs]
    S = hsv[:, :, 1][tbs]
    V = hsv[:, :, 2][tbs]

    fig, axes = plt.subplots(3, 1, figsize=(8, 10))

    axes[0].hist(H, bins=30)
    axes[0].set_title("Distribusi Hue (H)")
    axes[0].set_xlabel("Hue")
    axes[0].set_ylabel("Jumlah Pixel")

    axes[1].hist(S, bins=30)
    axes[1].set_title("Distribusi Saturation (S)")
    axes[1].set_xlabel("Saturation")
    axes[1].set_ylabel("Jumlah Pixel")

    axes[2].hist(V, bins=30)
    axes[2].set_title("Distribusi Value (V)")
    axes[2].set_xlabel("Value")
    axes[2].set_ylabel("Jumlah Pixel")

    plt.suptitle(image_path.stem)
    plt.tight_layout()

    output_file = OUTPUT_DIR / f"{image_path.stem}_HSV_histogram.png"
    plt.savefig(output_file, dpi=150)
    plt.close()

    print(f"Selesai: {output_file}")

print("\nSemua histogram selesai dibuat.")