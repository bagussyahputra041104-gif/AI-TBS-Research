from pathlib import Path

import cv2
import numpy as np

# Lokasi proyek
BASE_DIR = Path(__file__).resolve().parent.parent
IMAGE_PATH = BASE_DIR / "Fruitset" / "Pic_20260923152205302.png"

OUTPUT_DIR = BASE_DIR / "results" / "04_visualization"
OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

# Baca gambar
image = cv2.imread(str(IMAGE_PATH))

if image is None:
    raise FileNotFoundError(
        f"Gambar tidak ditemukan: {IMAGE_PATH}"
    )

# Deteksi perkiraan latar belakang biru
hsv = cv2.cvtColor(image, cv2.COLOR_BGR2HSV)

lower_blue = np.array([90, 50, 25], dtype=np.uint8)
upper_blue = np.array([140, 255, 255], dtype=np.uint8)

blue_mask = cv2.inRange(hsv, lower_blue, upper_blue)

# Area bukan biru dianggap sebagai kandidat TBS
tbs_mask = cv2.bitwise_not(blue_mask)

kernel = np.ones((5, 5), np.uint8)
tbs_mask = cv2.morphologyEx(
    tbs_mask, cv2.MORPH_OPEN, kernel
)

# Buat overlay hijau untuk memeriksa hasil
green = np.zeros_like(image)
green[:] = (0, 255, 0)

colored = cv2.addWeighted(image, 0.65, green, 0.35, 0)

overlay = image.copy()
overlay[tbs_mask > 0] = colored[tbs_mask > 0]

# Simpan hasil
mask_path = OUTPUT_DIR / "tbs_mask_awal.png"
overlay_path = OUTPUT_DIR / "tbs_overlay_awal.png"

cv2.imwrite(str(mask_path), tbs_mask)
cv2.imwrite(str(overlay_path), overlay)

print("Segmentasi awal selesai!")
print(f"Mask: {mask_path}")
print(f"Overlay: {overlay_path}")
