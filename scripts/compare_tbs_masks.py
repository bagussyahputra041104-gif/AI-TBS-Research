from pathlib import Path

import cv2
import numpy as np

BASE_DIR = Path(__file__).resolve().parent.parent
RESULT_DIR = BASE_DIR / "results" / "04_visualization"
IMAGE_PATH = BASE_DIR / "Fruitset" / "Pic_20260923152205302.png"

MASKS = [
    ("Mask Awal", RESULT_DIR / "tbs_mask_awal.png"),
    ("Mask GrabCut", RESULT_DIR / "tbs_mask_grabcut.png"),
    ("Mask Komponen Utama", RESULT_DIR / "tbs_mask_component_awal.png"),
]

image = cv2.imread(str(IMAGE_PATH))
if image is None:
    raise FileNotFoundError(f"Gambar asli tidak ditemukan: {IMAGE_PATH}")

panels = []
target_width = 800
target_height = 600

# Panel gambar asli
original = cv2.resize(image, (target_width, target_height))
cv2.rectangle(original, (0, 0), (target_width, 45), (30, 30, 30), -1)
cv2.putText(
    original, "Gambar Asli", (15, 30),
    cv2.FONT_HERSHEY_SIMPLEX, 0.8, (255, 255, 255), 2
)
panels.append(original)

for name, path in MASKS:
    mask = cv2.imread(str(path), cv2.IMREAD_GRAYSCALE)
    if mask is None:
        raise FileNotFoundError(f"Mask tidak ditemukan: {path}")

    # Pastikan mask biner
    binary = (mask > 0).astype(np.uint8) * 255
    white_pct = np.count_nonzero(binary) / binary.size * 100

    print(f"{name}: {white_pct:.2f}% piksel terpilih")

    panel = cv2.resize(
        binary, (target_width, target_height),
        interpolation=cv2.INTER_NEAREST
    )
    panel = cv2.cvtColor(panel, cv2.COLOR_GRAY2BGR)

    cv2.rectangle(panel, (0, 0), (target_width, 45), (30, 30, 30), -1)
    cv2.putText(
        panel, name, (15, 30),
        cv2.FONT_HERSHEY_SIMPLEX, 0.8, (255, 255, 255), 2
    )
    panels.append(panel)

# Susun menjadi grid 2 x 2
top = np.hstack((panels[0], panels[1]))
bottom = np.hstack((panels[2], panels[3]))
comparison = np.vstack((top, bottom))

output_path = RESULT_DIR / "perbandingan_mask_tbs.png"
cv2.imwrite(str(output_path), comparison)

print("\nPerbandingan selesai.")
print(f"Gambar disimpan: {output_path}")
print("Persentase piksel bukan ukuran akurasi.")
