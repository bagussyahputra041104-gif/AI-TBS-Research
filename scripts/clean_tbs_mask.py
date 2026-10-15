from pathlib import Path

import cv2
import numpy as np

BASE_DIR = Path(__file__).resolve().parent.parent
MASK_PATH = BASE_DIR / "results" / "04_visualization" / "tbs_mask_grabcut.png"
OUTPUT_DIR = BASE_DIR / "results" / "04_visualization"

mask = cv2.imread(str(MASK_PATH), cv2.IMREAD_GRAYSCALE)

if mask is None:
    raise FileNotFoundError(f"Mask tidak ditemukan: {MASK_PATH}")

binary = (mask > 0).astype(np.uint8)

# Temukan komponen-komponen objek yang terhubung
count, labels, stats, centroids = cv2.connectedComponentsWithStats(
    binary, connectivity=8
)

if count <= 1:
    raise RuntimeError("Tidak ditemukan komponen foreground.")

# Cari komponen terbesar sebagai badan utama TBS
largest_label = 1 + np.argmax(stats[1:, cv2.CC_STAT_AREA])

cleaned = np.zeros_like(binary)
cleaned[labels == largest_label] = 255

output_path = OUTPUT_DIR / "tbs_mask_component_awal.png"
cv2.imwrite(str(output_path), cleaned)

print(f"Jumlah komponen foreground: {count - 1}")
print(f"Mask komponen utama disimpan: {output_path}")
print("Perhatian: serabut yang terpisah dapat ikut terhapus.")
