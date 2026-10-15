import cv2
import numpy as np
from pathlib import Path

MASK_DIR = Path("annotations/masks")
GRABCUT_DIR = Path("results/05_grabcut_all")
OUTPUT_DIR = Path("results/06_error_analysis")

OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

manual_masks = sorted(MASK_DIR.glob("*_mask_manual.png"))

if not manual_masks:
    print("Tidak ditemukan mask manual.")
    raise SystemExit

for manual_path in manual_masks:

    name = manual_path.name.replace("_mask_manual.png", "")
    grabcut_path = GRABCUT_DIR / f"{name}_mask.png"
    image_path = Path("Fruitset") / f"{name}.png"

    image = cv2.imread(str(image_path))
    gt = cv2.imread(str(manual_path), cv2.IMREAD_GRAYSCALE)
    pred = cv2.imread(str(grabcut_path), cv2.IMREAD_GRAYSCALE)

    if image is None or gt is None or pred is None:
        print(f"Gagal memproses: {name}")
        continue

    gt = gt > 0
    pred = pred > 0

    # Kondisi:
    # True Positive  = GT dan GrabCut sama-sama foreground
    # False Positive = GrabCut foreground, GT background
    # False Negative = GT foreground, GrabCut background
    true_positive = gt & pred
    false_positive = (~gt) & pred
    false_negative = gt & (~pred)

    result = image.copy()

    # Overlay warna
    result[true_positive] = (
        0.65 * result[true_positive] +
        0.35 * np.array([0, 255, 0])
    ).astype(np.uint8)

    result[false_positive] = (
        0.65 * result[false_positive] +
        0.35 * np.array([0, 0, 255])
    ).astype(np.uint8)

    result[false_negative] = (
        0.65 * result[false_negative] +
        0.35 * np.array([255, 0, 0])
    ).astype(np.uint8)

    output_path = OUTPUT_DIR / f"{name}_error.png"

    cv2.imwrite(str(output_path), result)

    print(f"Selesai: {output_path}")

print("\n=== ANALISIS ERROR SELESAI ===")
print(f"Hasil tersimpan di: {OUTPUT_DIR}")