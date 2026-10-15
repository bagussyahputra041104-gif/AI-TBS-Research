import cv2
import numpy as np
import pandas as pd
from pathlib import Path


IMAGE_DIR = Path("Fruitset")
MASK_DIR = Path("dataset/segmentation/masks")
OUTPUT_DIR = Path("results/13_color_distribution")

OUTPUT_DIR.mkdir(parents=True, exist_ok=True)


rows = []

for image_path in sorted(IMAGE_DIR.glob("*.png")):

    mask_path = MASK_DIR / f"{image_path.stem}_mask_manual.png"

    if not mask_path.exists():
        print(f"Mask tidak ditemukan: {mask_path}")
        continue

    image = cv2.imread(str(image_path))
    mask = cv2.imread(str(mask_path), cv2.IMREAD_GRAYSCALE)

    tbs = mask > 127

    hsv = cv2.cvtColor(image, cv2.COLOR_BGR2HSV)
    lab = cv2.cvtColor(image, cv2.COLOR_BGR2LAB)

    channels = {
        "H": hsv[:, :, 0][tbs],
        "S": hsv[:, :, 1][tbs],
        "V": hsv[:, :, 2][tbs],
        "L": lab[:, :, 0][tbs],
        "a": lab[:, :, 1][tbs],
        "b": lab[:, :, 2][tbs],
    }

    row = {
        "image": image_path.name,
        "TBS_pixels": int(tbs.sum()),
    }

    for name, values in channels.items():
        row[f"{name}_p10"] = np.percentile(values, 10)
        row[f"{name}_p25"] = np.percentile(values, 25)
        row[f"{name}_p50"] = np.percentile(values, 50)
        row[f"{name}_p75"] = np.percentile(values, 75)
        row[f"{name}_p90"] = np.percentile(values, 90)

    rows.append(row)


df = pd.DataFrame(rows)

output_file = OUTPUT_DIR / "color_distribution_statistics.csv"
df.to_csv(output_file, index=False)

print("\n=== HASIL DISTRIBUSI WARNA ===")
print(df.to_string(index=False))

print(f"\nHasil disimpan di:")
print(output_file)