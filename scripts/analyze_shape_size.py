from pathlib import Path
import cv2
import csv

# ==============================
# PATH
# ==============================

MASK_DIR = Path("dataset/segmentation/masks")
OUTPUT_DIR = Path("results/11_shape_size")

OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

OUTPUT_CSV = OUTPUT_DIR / "shape_size_analysis.csv"


# ==============================
# ANALISIS
# ==============================

rows = []

mask_files = sorted(MASK_DIR.glob("*_mask_manual.png"))

print("================================")
print("ANALISIS BENTUK & UKURAN TBS")
print("================================")
print(f"Jumlah mask: {len(mask_files)}")
print()

for mask_path in mask_files:

    mask = cv2.imread(str(mask_path), cv2.IMREAD_GRAYSCALE)

    if mask is None:
        print(f"[ERROR] Tidak dapat membaca: {mask_path.name}")
        continue

    # Binary mask
    binary = (mask > 127).astype("uint8") * 255

    # Cari contour
    contours, _ = cv2.findContours(
        binary,
        cv2.RETR_EXTERNAL,
        cv2.CHAIN_APPROX_SIMPLE
    )

    if not contours:
        print(f"[WARNING] Tidak ada objek: {mask_path.name}")
        continue

    # Ambil contour terbesar
    contour = max(contours, key=cv2.contourArea)

    # Luas objek dalam piksel
    area = cv2.contourArea(contour)

    # Bounding box
    x, y, width, height = cv2.boundingRect(contour)

    # Aspect ratio
    aspect_ratio = width / height if height > 0 else 0

    # Perimeter
    perimeter = cv2.arcLength(contour, True)

    # Circularity
    if perimeter > 0:
        circularity = (4 * 3.141592653589793 * area) / (perimeter ** 2)
    else:
        circularity = 0

    # Persentase area TBS terhadap gambar
    image_area = mask.shape[0] * mask.shape[1]
    area_percentage = (area / image_area) * 100

    rows.append({
        "image": mask_path.name.replace("_mask_manual.png", ".png"),
        "area_pixels": round(area, 2),
        "width_pixels": width,
        "height_pixels": height,
        "aspect_ratio": round(aspect_ratio, 4),
        "perimeter_pixels": round(perimeter, 2),
        "circularity": round(circularity, 4),
        "area_percentage": round(area_percentage, 4)
    })

    print(f"[OK] {mask_path.name}")
    print(f"     Area          : {area:.2f} px")
    print(f"     Width         : {width} px")
    print(f"     Height        : {height} px")
    print(f"     Aspect Ratio  : {aspect_ratio:.4f}")
    print(f"     Circularity   : {circularity:.4f}")
    print(f"     Area gambar   : {area_percentage:.2f}%")
    print()


# ==============================
# SIMPAN CSV
# ==============================

if rows:

    fieldnames = [
        "image",
        "area_pixels",
        "width_pixels",
        "height_pixels",
        "aspect_ratio",
        "perimeter_pixels",
        "circularity",
        "area_percentage"
    ]

    with open(
        OUTPUT_CSV,
        "w",
        newline="",
        encoding="utf-8"
    ) as f:

        writer = csv.DictWriter(
            f,
            fieldnames=fieldnames
        )

        writer.writeheader()
        writer.writerows(rows)

    print("================================")
    print("SELESAI")
    print("================================")
    print(f"Hasil disimpan:")
    print(OUTPUT_CSV)

else:

    print("Tidak ada data yang berhasil dianalisis.")