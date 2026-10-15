import cv2
import numpy as np
import os
import glob

# =========================
# FOLDER
# =========================
IMAGE_DIR = "Fruitset"
MASK_DIR = "dataset/segmentation/masks"
OUTPUT_DIR = "results/14_fruitlet_test"

os.makedirs(OUTPUT_DIR, exist_ok=True)

# =========================
# CARI SEMUA GAMBAR
# =========================
images = glob.glob(
    os.path.join(IMAGE_DIR, "*.png")
)

print("=" * 55)
print("UJI DETEKSI FRUITLET - V1")
print("=" * 55)

# =========================
# PROSES SEMUA GAMBAR
# =========================
for image_path in images:

    name = os.path.splitext(
        os.path.basename(image_path)
    )[0]

    mask_path = os.path.join(
        MASK_DIR,
        name + "_mask_manual.png"
    )

    # Load
    img = cv2.imread(image_path)
    mask = cv2.imread(
        mask_path,
        cv2.IMREAD_GRAYSCALE
    )

    if img is None:
        print(f"{name}: gambar gagal dibaca")
        continue

    if mask is None:
        print(f"{name}: mask tidak ditemukan")
        continue

    # Samakan ukuran mask
    mask = cv2.resize(
        mask,
        (img.shape[1], img.shape[0])
    )

    # =========================
    # AMBIL AREA TBS SAJA
    # =========================
    tbs = cv2.bitwise_and(
        img,
        img,
        mask=mask
    )

    # =========================
    # GRAYSCALE
    # =========================
    gray = cv2.cvtColor(
        tbs,
        cv2.COLOR_BGR2GRAY
    )

    gray = cv2.GaussianBlur(
        gray,
        (9, 9),
        2
    )

    # =========================
    # HOUGH CIRCLE V1
    # =========================
    circles = cv2.HoughCircles(
        gray,
        cv2.HOUGH_GRADIENT,
        dp=1.2,
        minDist=18,
        param1=80,
        param2=28,
        minRadius=8,
        maxRadius=45
    )

    output = img.copy()

    count = 0

    # =========================
    # GAMBAR HASIL DETEKSI
    # =========================
    if circles is not None:

        circles = np.round(
            circles[0]
        ).astype(int)

        for x, y, r in circles:

            # Pastikan koordinat valid
            if not (
                0 <= x < mask.shape[1]
                and 0 <= y < mask.shape[0]
            ):
                continue

            # Hanya kandidat di area TBS
            if mask[y, x] > 0:

                cv2.circle(
                    output,
                    (x, y),
                    r,
                    (0, 0, 255),
                    2
                )

                cv2.circle(
                    output,
                    (x, y),
                    2,
                    (0, 255, 0),
                    -1
                )

                count += 1

    # =========================
    # TULIS JUMLAH KANDIDAT
    # =========================
    cv2.putText(
        output,
        f"Kandidat: {count}",
        (30, 50),
        cv2.FONT_HERSHEY_SIMPLEX,
        1.2,
        (0, 255, 255),
        3
    )

    # =========================
    # SIMPAN
    # =========================
    output_path = os.path.join(
        OUTPUT_DIR,
        name + "_fruitlet_test.png"
    )

    cv2.imwrite(
        output_path,
        output
    )

    print(
        f"{name}: {count} kandidat"
    )

print("=" * 55)
print("SEMUA GAMBAR SELESAI.")
print(f"Hasil disimpan di: {OUTPUT_DIR}")
print("=" * 55)