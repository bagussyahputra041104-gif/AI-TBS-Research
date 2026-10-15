from pathlib import Path
from ultralytics import YOLO


# =========================================================
# PATH
# =========================================================

MODEL_PATH = Path(
    "runs/detect/models/experiments/detection/"
    "yolo_tbs_baseline/weights/best.pt"
)

TEST_DIR = Path(
    "dataset/detection/test/images"
)

OUTPUT_DIR = Path(
    "results/16_yolo_detection"
)

OUTPUT_DIR.mkdir(
    parents=True,
    exist_ok=True
)


# =========================================================
# LOAD MODEL
# =========================================================

print("Loading YOLO model...")

model = YOLO(str(MODEL_PATH))


# =========================================================
# PREDIKSI
# =========================================================

print()
print("========================================")
print("MULAI DETEKSI")
print("========================================")

results = model.predict(
    source=str(TEST_DIR),
    imgsz=640,
    conf=0.25,
    save=True,
    project=str(OUTPUT_DIR),
    name="test",
    exist_ok=True,
    device="cpu"
)


# =========================================================
# TAMPILKAN HASIL
# =========================================================

print()
print("========================================")
print("HASIL DETEKSI")
print("========================================")

for result in results:

    image_name = Path(
        result.path
    ).name

    boxes = result.boxes

    print()
    print(f"Gambar : {image_name}")
    print(f"Jumlah deteksi : {len(boxes)}")

    for i, box in enumerate(boxes):

        cls_id = int(
            box.cls[0].item()
        )

        confidence = float(
            box.conf[0].item()
        )

        class_name = model.names[
            cls_id
        ]

        print(
            f"  Deteksi {i + 1}: "
            f"{class_name} "
            f"confidence={confidence:.4f}"
        )


print()
print("========================================")
print("SELESAI")
print("========================================")
print(f"Output : {OUTPUT_DIR}")
print("========================================")