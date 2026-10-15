import cv2
import numpy as np
import pandas as pd
from pathlib import Path

IMAGE_DIR = Path("Fruitset")
MASK_DIR = Path("dataset/segmentation/masks")
OUTPUT_DIR = Path("results/12_color_hsv_lab")

OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

rows = []

for image_path in sorted(IMAGE_DIR.glob("*.png")):

    mask_path = MASK_DIR / f"{image_path.stem}_mask_manual.png"

    if not mask_path.exists():
        print(f"[SKIP] Mask tidak ditemukan: {image_path.name}")
        continue

    image = cv2.imread(str(image_path))

    # RGB
    rgb = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)

    # HSV
    hsv = cv2.cvtColor(image, cv2.COLOR_BGR2HSV)

    # Lab
    lab = cv2.cvtColor(image, cv2.COLOR_BGR2LAB)

    mask = cv2.imread(str(mask_path), cv2.IMREAD_GRAYSCALE)
    mask_bool = mask > 127

    # Ambil hanya pixel TBS
    rgb_pixels = rgb[mask_bool]
    hsv_pixels = hsv[mask_bool]
    lab_pixels = lab[mask_bool]

    # Statistik RGB
    r_mean, g_mean, b_mean = rgb_pixels.mean(axis=0)

    # Statistik HSV
    h_mean, s_mean, v_mean = hsv_pixels.mean(axis=0)

    # Statistik Lab
    l_mean, a_mean, b_lab_mean = lab_pixels.mean(axis=0)

    rows.append({
        "image": image_path.name,

        "R_mean": r_mean,
        "G_mean": g_mean,
        "B_mean": b_mean,

        "H_mean": h_mean,
        "S_mean": s_mean,
        "V_mean": v_mean,

        "L_mean": l_mean,
        "a_mean": a_mean,
        "b_mean": b_lab_mean,

        "TBS_pixels": int(mask_bool.sum())
    })

    print(f"[OK] {image_path.name}")

df = pd.DataFrame(rows)

output_file = OUTPUT_DIR / "color_hsv_lab_statistics.csv"
df.to_csv(output_file, index=False)

print("\n================================")
print("ANALISIS WARNA HSV + LAB")
print("================================")

print(df.to_string(index=False))

print("\nHasil disimpan:")
print(output_file)