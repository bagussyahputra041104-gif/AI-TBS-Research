import cv2
import numpy as np
from pathlib import Path

INPUT_DIR = Path("Fruitset")
OUTPUT_DIR = Path("results/07_grabcut_v2")

OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

images = sorted(INPUT_DIR.glob("*.png"))

if not images:
    print("Tidak ada gambar PNG.")
    raise SystemExit

for image_path in images:
    print(f"Memproses: {image_path.name}")

    image = cv2.imread(str(image_path))

    if image is None:
        print("  Gagal membaca gambar.")
        continue

    h, w = image.shape[:2]

    # Margin lebih besar daripada GrabCut V1
    # agar area tepi lebih tegas dianggap background.
    margin_x = int(w * 0.12)
    margin_y = int(h * 0.12)

    rect = (
        margin_x,
        margin_y,
        w - 2 * margin_x,
        h - 2 * margin_y
    )

    mask = np.zeros((h, w), np.uint8)

    bgd_model = np.zeros((1, 65), np.float64)
    fgd_model = np.zeros((1, 65), np.float64)

    cv2.grabCut(
        image,
        mask,
        rect,
        bgd_model,
        fgd_model,
        7,
        cv2.GC_INIT_WITH_RECT
    )

    binary_mask = np.where(
        (mask == cv2.GC_FGD) |
        (mask == cv2.GC_PR_FGD),
        255,
        0
    ).astype(np.uint8)

    # Bersihkan noise kecil
    kernel = np.ones((5, 5), np.uint8)

    binary_mask = cv2.morphologyEx(
        binary_mask,
        cv2.MORPH_OPEN,
        kernel
    )

    binary_mask = cv2.morphologyEx(
        binary_mask,
        cv2.MORPH_CLOSE,
        kernel
    )

    stem = image_path.stem

    mask_path = OUTPUT_DIR / f"{stem}_mask.png"
    overlay_path = OUTPUT_DIR / f"{stem}_overlay.png"

    cv2.imwrite(str(mask_path), binary_mask)

    overlay = image.copy()

    green = np.zeros_like(image)
    green[:, :, 1] = 255

    foreground = binary_mask > 0

    overlay[foreground] = cv2.addWeighted(
        image[foreground],
        0.65,
        green[foreground],
        0.35,
        0
    )

    cv2.imwrite(str(overlay_path), overlay)

    print(f"  Mask    : {mask_path}")
    print(f"  Overlay : {overlay_path}")

print("\n=== GRABCUT V2 SELESAI ===")
print(f"Total gambar: {len(images)}")
print(f"Hasil: {OUTPUT_DIR}")