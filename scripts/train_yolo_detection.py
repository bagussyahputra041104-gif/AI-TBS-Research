from ultralytics import YOLO
from pathlib import Path


# =========================================================
# PATH
# =========================================================

DATASET_DIR = Path("dataset/detection")
MODEL_DIR = Path("models/experiments/detection")
MODEL_DIR.mkdir(parents=True, exist_ok=True)


# =========================================================
# BUAT DATA.YAML
# =========================================================

yaml_path = DATASET_DIR / "data.yaml"

yaml_text = f"""
path: {DATASET_DIR.resolve()}
train: train/images
val: val/images
test: test/images

names:
  0: TBS
"""

yaml_path.write_text(
    yaml_text.strip(),
    encoding="utf-8"
)

print("data.yaml berhasil dibuat:")
print(yaml_path)


# =========================================================
# LOAD YOLO
# =========================================================

model = YOLO("yolo11n.pt")


# =========================================================
# TRAINING
# =========================================================

results = model.train(
    data=str(yaml_path),

    epochs=30,
    imgsz=640,
    batch=2,

    project=str(MODEL_DIR),
    name="yolo_tbs_baseline",

    device="cpu",

    patience=10,

    workers=0,

    verbose=True
)


print()
print("========================================")
print("TRAINING YOLO SELESAI")
print("========================================")
print(f"Output : {MODEL_DIR / 'yolo_tbs_baseline'}")
print("========================================")