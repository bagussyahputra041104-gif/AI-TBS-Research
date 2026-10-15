from pathlib import Path

import cv2
import numpy as np

BASE_DIR = Path(__file__).resolve().parent.parent
IMAGE_PATH = BASE_DIR / "Fruitset" / "Pic_20260923152205302.png"

OUTPUT_DIR = BASE_DIR / "results" / "04_visualization"
OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

image = cv2.imread(str(IMAGE_PATH))

if image is None:
    raise FileNotFoundError(f"Gambar tidak ditemukan: {IMAGE_PATH}")

height, width = image.shape[:2]

# Perkiraan kotak yang mencakup seluruh tandan,
# termasuk tangkai dan serabut yang tampak.
rect = (
    int(width * 0.10),
    int(height * 0.01),
    int(width * 0.80),
    int(height * 0.98),
)

mask = np.zeros((height, width), dtype=np.uint8)
bg_model = np.zeros((1, 65), dtype=np.float64)
fg_model = np.zeros((1, 65), dtype=np.float64)

# GrabCut memperkirakan foreground dan background
cv2.grabCut(
    image,
    mask,
    rect,
    bg_model,
    fg_model,
    7,
    cv2.GC_INIT_WITH_RECT,
)

# Gabungkan piksel foreground pasti dan perkiraan foreground
result_mask = np.where(
    (mask == cv2.GC_FGD) | (mask == cv2.GC_PR_FGD),
    255,
    0,
).astype(np.uint8)

# Simpan mask hitam-putih
mask_path = OUTPUT_DIR / "tbs_mask_grabcut.png"
cv2.imwrite(str(mask_path), result_mask)

# Buat overlay hijau untuk pemeriksaan visual
overlay = image.copy()
green = np.zeros_like(image)
green[:] = (0, 255, 0)

colored = cv2.addWeighted(image, 0.65, green, 0.35, 0)
overlay[result_mask > 0] = colored[result_mask > 0]

overlay_path = OUTPUT_DIR / "tbs_overlay_grabcut.png"
cv2.imwrite(str(overlay_path), overlay)

# Simpan juga TBS dengan latar transparan
rgba = cv2.cvtColor(image, cv2.COLOR_BGR2BGRA)
rgba[:, :, 3] = result_mask

cutout_path = OUTPUT_DIR / "tbs_transparan_grabcut.png"
cv2.imwrite(str(cutout_path), rgba)

print("GrabCut selesai.")
print(f"Mask: {mask_path}")
print(f"Overlay: {overlay_path}")
print(f"Transparan: {cutout_path}")
