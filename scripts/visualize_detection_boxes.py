from pathlib import Path
import cv2
import csv


# =========================================================
# PATH
# =========================================================

IMAGE_DIR = Path("Fruitset")
CSV_PATH = Path("annotations/detection/tbs_detection_boxes.csv")
OUTPUT_DIR = Path("results/15_detection_visualization")

OUTPUT_DIR.mkdir(parents=True, exist_ok=True)


# =========================================================
# BACA CSV
# =========================================================

with open(CSV_PATH, "r", encoding="utf-8") as f:
    reader = csv.DictReader(f)

    for row in reader:

        image_name = row["image"]

        x = int(row["x"])
        y = int(row["y"])
        w = int(row["width"])
        h = int(row["height"])

        image_path = IMAGE_DIR / image_name

        image = cv2.imread(str(image_path))

        if image is None:
            print(f"[SKIP] Gagal membaca {image_name}")
            continue

        # Titik kiri atas
        x1 = x
        y1 = y

        # Titik kanan bawah
        x2 = x + w
        y2 = y + h

        # Gambar bounding box
        cv2.rectangle(
            image,
            (x1, y1),
            (x2, y2),
            (0, 255, 0),
            4
        )

        # Label
        cv2.putText(
            image,
            "TBS",
            (x1, max(y1 - 10, 30)),
            cv2.FONT_HERSHEY_SIMPLEX,
            1.2,
            (0, 255, 0),
            3,
            cv2.LINE_AA
        )

        # Simpan
        output_path = OUTPUT_DIR / image_name

        cv2.imwrite(
            str(output_path),
            image
        )

        print(
            f"[OK] {image_name} -> "
            f"{output_path}"
        )


print()
print("========================================")
print("VISUALISASI SELESAI")
print("========================================")
print(f"Output : {OUTPUT_DIR}")
print("========================================")