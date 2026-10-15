from pathlib import Path

import cv2
import numpy as np

BASE_DIR = Path(__file__).resolve().parent.parent
IMAGE_PATH = BASE_DIR / "Fruitset" / "Pic_20260923152205302.png"
MASK_PATH = BASE_DIR / "results" / "04_visualization" / "tbs_mask_grabcut.png"
OUTPUT_PATH = BASE_DIR / "results" / "04_visualization" / "tbs_boundary_check.png"

image = cv2.imread(str(IMAGE_PATH))
mask = cv2.imread(str(MASK_PATH), cv2.IMREAD_GRAYSCALE)

if image is None:
    raise FileNotFoundError(f"Gambar tidak ditemukan: {IMAGE_PATH}")

if mask is None:
    raise FileNotFoundError(f"Mask tidak ditemukan: {MASK_PATH}")

if image.shape[:2] != mask.shape[:2]:
    raise ValueError("Ukuran gambar dan mask berbeda.")

binary = (mask > 0).astype(np.uint8) * 255

contours, _ = cv2.findContours(
    binary,
    cv2.RETR_EXTERNAL,
    cv2.CHAIN_APPROX_SIMPLE,
)

result = image.copy()
cv2.drawContours(result, contours, -1, (0, 0, 255), 2)

OUTPUT_PATH.parent.mkdir(parents=True, exist_ok=True)
cv2.imwrite(str(OUTPUT_PATH), result)

print("Pemeriksaan batas selesai.")
print(f"Hasil: {OUTPUT_PATH}")
