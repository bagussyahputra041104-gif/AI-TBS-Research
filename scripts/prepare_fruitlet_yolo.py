from pathlib import Path
import shutil

IMAGE_DIR = Path("Fruitset")
POINT_DIR = Path("annotations/fruitlets")
OUTPUT_DIR = Path("dataset/fruitlet_detection")

BOX_SIZE = 40
HALF = BOX_SIZE / 2

# Split tetap seperti eksperimen sebelumnya
SPLIT = {
    "train": [
        "Pic_20260923152205302.png",
        "Pic_20260923152208549.png",
    ],
    "val": [
        "Pic_20260923152226022.png",
    ],
    "test": [
        "Pic_20260923152234998.png",
    ],
}

for split in ["train", "val", "test"]:
    (OUTPUT_DIR / split / "images").mkdir(parents=True, exist_ok=True)
    (OUTPUT_DIR / split / "labels").mkdir(parents=True, exist_ok=True)

for split, filenames in SPLIT.items():

    for filename in filenames:

        image_path = IMAGE_DIR / filename
        point_path = POINT_DIR / f"{image_path.stem}_fruitlets.txt"

        if not image_path.exists():
            print(f"[SKIP] Image tidak ditemukan: {filename}")
            continue

        if not point_path.exists():
            print(f"[SKIP] Anotasi tidak ditemukan: {point_path}")
            continue

        # Baca ukuran gambar
        import cv2
        image = cv2.imread(str(image_path))

        if image is None:
            print(f"[SKIP] Gagal membaca: {filename}")
            continue

        height, width = image.shape[:2]

        # Copy image
        shutil.copy2(
            image_path,
            OUTPUT_DIR / split / "images" / filename
        )

        labels = []

        with open(point_path, "r") as f:
            points = [
                tuple(map(int, line.strip().split(",")))
                for line in f
                if line.strip()
            ]

        for x, y in points:

            x1 = max(0, x - HALF)
            y1 = max(0, y - HALF)
            x2 = min(width, x + HALF)
            y2 = min(height, y + HALF)

            box_w = x2 - x1
            box_h = y2 - y1

            center_x = (x1 + x2) / 2
            center_y = (y1 + y2) / 2

            # YOLO normalized
            cx = center_x / width
            cy = center_y / height
            bw = box_w / width
            bh = box_h / height

            # class 0 = fruitlet
            labels.append(
                f"0 {cx:.6f} {cy:.6f} {bw:.6f} {bh:.6f}"
            )

        label_path = (
            OUTPUT_DIR /
            split /
            "labels" /
            f"{image_path.stem}.txt"
        )

        with open(label_path, "w") as f:
            f.write("\n".join(labels))

        print(
            f"[OK] {split.upper()} | "
            f"{filename} | "
            f"{len(labels)} fruitlet"
        )

# data.yaml
yaml_path = OUTPUT_DIR / "data.yaml"

yaml_content = f"""path: {OUTPUT_DIR.resolve()}
train: train/images
val: val/images
test: test/images

names:
  0: fruitlet
"""

with open(yaml_path, "w") as f:
    f.write(yaml_content)

print()
print("=" * 60)
print("DATASET YOLO FRUITLET SELESAI")
print("=" * 60)
print(f"Dataset : {OUTPUT_DIR}")
print(f"YAML    : {yaml_path}")