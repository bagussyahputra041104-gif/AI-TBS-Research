from pathlib import Path
import cv2
import csv
import shutil


# =========================================================
# PATH
# =========================================================

IMAGE_DIR = Path("Fruitset")
CSV_PATH = Path("annotations/detection/tbs_detection_boxes.csv")

OUTPUT_DIR = Path("dataset/detection")

TRAIN_IMAGES = OUTPUT_DIR / "train" / "images"
TRAIN_LABELS = OUTPUT_DIR / "train" / "labels"

VAL_IMAGES = OUTPUT_DIR / "val" / "images"
VAL_LABELS = OUTPUT_DIR / "val" / "labels"

TEST_IMAGES = OUTPUT_DIR / "test" / "images"
TEST_LABELS = OUTPUT_DIR / "test" / "labels"


# =========================================================
# BUAT FOLDER
# =========================================================

for folder in [
    TRAIN_IMAGES,
    TRAIN_LABELS,
    VAL_IMAGES,
    VAL_LABELS,
    TEST_IMAGES,
    TEST_LABELS
]:
    folder.mkdir(parents=True, exist_ok=True)


# =========================================================
# SPLIT
# =========================================================
# Karena dataset hanya 4 gambar:
#
# TRAIN = 2
# VAL   = 1
# TEST  = 1
#
# Sama seperti eksperimen segmentation sebelumnya.

split = {
    "Pic_20260923152205302.png": "train",
    "Pic_20260923152208549.png": "train",

    "Pic_20260923152226022.png": "val",

    "Pic_20260923152234998.png": "test",
}


# =========================================================
# BACA CSV
# =========================================================

with open(CSV_PATH, "r", encoding="utf-8") as f:

    reader = csv.DictReader(f)

    for row in reader:

        image_name = row["image"]

        if image_name not in split:
            print(f"[SKIP] Tidak ada split: {image_name}")
            continue

        split_name = split[image_name]

        image_path = IMAGE_DIR / image_name

        image = cv2.imread(str(image_path))

        if image is None:
            print(f"[SKIP] Gagal membaca: {image_name}")
            continue

        height, width = image.shape[:2]

        # Bounding box pixel
        x = float(row["x"])
        y = float(row["y"])
        w = float(row["width"])
        h = float(row["height"])

        # =================================================
        # KONVERSI KE FORMAT YOLO
        # =================================================

        x_center = x + (w / 2)
        y_center = y + (h / 2)

        # Normalisasi 0-1
        x_center /= width
        y_center /= height

        w_norm = w / width
        h_norm = h / height

        # Class 0 = TBS
        label_text = (
            f"0 "
            f"{x_center:.6f} "
            f"{y_center:.6f} "
            f"{w_norm:.6f} "
            f"{h_norm:.6f}"
        )

        # =================================================
        # PILIH FOLDER
        # =================================================

        if split_name == "train":

            image_out_dir = TRAIN_IMAGES
            label_out_dir = TRAIN_LABELS

        elif split_name == "val":

            image_out_dir = VAL_IMAGES
            label_out_dir = VAL_LABELS

        else:

            image_out_dir = TEST_IMAGES
            label_out_dir = TEST_LABELS

        # =================================================
        # COPY IMAGE
        # =================================================

        shutil.copy2(
            image_path,
            image_out_dir / image_name
        )

        # =================================================
        # SIMPAN LABEL
        # =================================================

        label_path = (
            label_out_dir /
            f"{Path(image_name).stem}.txt"
        )

        with open(
            label_path,
            "w",
            encoding="utf-8"
        ) as label_file:

            label_file.write(label_text + "\n")

        print(
            f"[OK] {split_name.upper()} "
            f"{image_name}"
        )

        print(
            f"     YOLO: {label_text}"
        )


print()
print("========================================")
print("YOLO DATASET SELESAI")
print("========================================")
print(f"Output: {OUTPUT_DIR}")
print("========================================")