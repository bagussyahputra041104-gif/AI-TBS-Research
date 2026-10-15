import cv2
import numpy as np
from pathlib import Path

INPUT_DIR = Path("Fruitset")
OUTPUT_DIR = Path("results/05_grabcut_all")

OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

images = sorted(INPUT_DIR.glob("*.png"))

if not images:
    print("Tidak ada gambar PNG di folder Fruitset.")
    raise SystemExit

for image_path in images:
    print(f"Memproses: {image_path.name}")

    image = cv2.imread(str(image_path))

    if image is None:
        print("  Gagal membaca gambar.")
        continue

    h, w = image.shape[:2]

    # Area awal: hampir seluruh gambar,
    # tetapi menyisakan sedikit margin dari tepi.
    margin_x = int(w * 0.05)
    margin_y = int(h * 0.05)

    rect = (
        margin_x,
        margin_y,
        w - 2 * margin_x,
        h - 2 * margin_y
    )

    # Inisialisasi GrabCut
    mask = np.zeros((h, w), np.uint8)

    bgd_model = np.zeros((1, 65), np.float64)
    fgd_model = np.zeros((1, 65), np.float64)

    cv2.grabCut(
        image,
        mask,
        rect,
        bgd_model,
        fgd_model,
        5,
        cv2.GC_INIT_WITH_RECT
    )

    # Foreground + probable foreground
    binary_mask = np.where(
        (mask == cv2.GC_FGD) | (mask == cv2.GC_PR_FGD),
        255,
        0
    ).astype(np.uint8)

    # Simpan mask
    stem = image_path.stem

    mask_path = OUTPUT_DIR / f"{stem}_mask.png"
    overlay_path = OUTPUT_DIR / f"{stem}_overlay.png"

    cv2.imwrite(str(mask_path), binary_mask)

    # Overlay untuk pemeriksaan visual
    overlay = image.copy()

    green = np.zeros_like(image)
    green[:, :, 1] = 255

    alpha = 0.35

    foreground = binary_mask > 0

    overlay[foreground] = cv2.addWeighted(
        image[foreground],
        1 - alpha,
        green[foreground],
        alpha,
        0
    )

    cv2.imwrite(str(overlay_path), overlay)

    print(f"  Mask    : {mask_path}")
    print(f"  Overlay : {overlay_path}")

print("\n=== SELESAI ===")
print(f"Total gambar diproses: {len(images)}")
print(f"Hasil tersimpan di: {OUTPUT_DIR}")