from pathlib import Path
import cv2
import csv


# =========================================================
# PATH
# =========================================================

MASK_DIR = Path("dataset/segmentation/masks")
OUTPUT_DIR = Path("annotations/detection")
OUTPUT_CSV = OUTPUT_DIR / "tbs_detection_boxes.csv"


# =========================================================
# SETUP
# =========================================================

OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

rows = []


# =========================================================
# PROSES SEMUA MASK
# =========================================================

for mask_path in sorted(MASK_DIR.glob("*_mask_manual.png")):

    mask = cv2.imread(str(mask_path), cv2.IMREAD_GRAYSCALE)

    if mask is None:
        print(f"[SKIP] Gagal membaca: {mask_path.name}")
        continue

    # Pastikan menjadi binary
    _, binary = cv2.threshold(
        mask,
        127,
        255,
        cv2.THRESH_BINARY
    )

    # Cari kontur
    contours, _ = cv2.findContours(
        binary,
        cv2.RETR_EXTERNAL,
        cv2.CHAIN_APPROX_SIMPLE
    )

    if not contours:
        print(f"[SKIP] Tidak ada objek: {mask_path.name}")
        continue

    # Ambil kontur terbesar = TBS
    largest_contour = max(
        contours,
        key=cv2.contourArea
    )

    # Bounding box
    x, y, w, h = cv2.boundingRect(
        largest_contour
    )

    # Nama image
    image_name = mask_path.name.replace(
        "_mask_manual.png",
        ".png"
    )

    rows.append([
        image_name,
        x,
        y,
        w,
        h,
        "TBS"
    ])

    print(
        f"[OK] {image_name} "
        f"-> x={x}, y={y}, w={w}, h={h}"
    )


# =========================================================
# SIMPAN CSV
# =========================================================

with open(
    OUTPUT_CSV,
    "w",
    newline="",
    encoding="utf-8"
) as f:

    writer = csv.writer(f)

    writer.writerow([
        "image",
        "x",
        "y",
        "width",
        "height",
        "class"
    ])

    writer.writerows(rows)


print()
print("========================================")
print("SELESAI")
print("========================================")
print(f"Jumlah gambar : {len(rows)}")
print(f"Output        : {OUTPUT_CSV}")
print("========================================")