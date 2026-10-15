import cv2
import numpy as np
from pathlib import Path

INPUT_DIR = Path("Fruitset")
OUTPUT_DIR = Path("results/06_grabcut_refined")

OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

images = sorted(INPUT_DIR.glob("*.png"))

if not images:
    print("Tidak ada gambar PNG di folder Fruitset.")
    raise SystemExit


for image_path in images:

    print(f"\nMemproses: {image_path.name}")

    image = cv2.imread(str(image_path))

    if image is None:
        print("  Gagal membaca gambar.")
        continue

    h, w = image.shape[:2]

    # =========================================================
    # 1. RECTANGLE LEBIH KETAT
    # =========================================================

    margin_x = int(w * 0.10)
    margin_y = int(h * 0.10)

    rect = (
        margin_x,
        margin_y,
        w - 2 * margin_x,
        h - 2 * margin_y
    )

    # =========================================================
    # 2. GRABCUT
    # =========================================================

    mask = np.zeros((h, w), np.uint8)

    bgd_model = np.zeros((1, 65), np.float64)
    fgd_model = np.zeros((1, 65), np.float64)

    cv2.grabCut(
        image,
        mask,
        rect,
        bgd_model,
        fgd_model,
        8,
        cv2.GC_INIT_WITH_RECT
    )

    # =========================================================
    # 3. AMBIL FOREGROUND
    # =========================================================

    binary_mask = np.where(
        (mask == cv2.GC_FGD) |
        (mask == cv2.GC_PR_FGD),
        255,
        0
    ).astype(np.uint8)

    # =========================================================
    # 4. MORPHOLOGICAL CLEANING
    # =========================================================

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

    # =========================================================
    # 5. AMBIL KOMPONEN TERBESAR
    # =========================================================

    num_labels, labels, stats, _ = cv2.connectedComponentsWithStats(
        binary_mask,
        connectivity=8
    )

    if num_labels > 1:

        largest_label = 1 + np.argmax(
            stats[1:, cv2.CC_STAT_AREA]
        )

        cleaned_mask = np.zeros_like(binary_mask)

        cleaned_mask[labels == largest_label] = 255

        binary_mask = cleaned_mask

    # =========================================================
    # 6. SIMPAN MASK
    # =========================================================

    stem = image_path.stem

    mask_path = OUTPUT_DIR / f"{stem}_mask.png"

    cv2.imwrite(
        str(mask_path),
        binary_mask
    )

    # =========================================================
    # 7. BUAT OVERLAY
    # =========================================================

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

    overlay_path = OUTPUT_DIR / f"{stem}_overlay.png"

    cv2.imwrite(
        str(overlay_path),
        overlay
    )

    print(f"  Mask    : {mask_path}")
    print(f"  Overlay : {overlay_path}")


print("\n===================================")
print("SELESAI")
print(f"Total gambar : {len(images)}")
print(f"Hasil       : {OUTPUT_DIR}")
print("===================================")