from ultralytics import YOLO
from pathlib import Path

DATA_YAML = Path("dataset/fruitlet_detection/data.yaml")

model = YOLO("yolo11n.pt")

model.train(
    data=str(DATA_YAML),
    epochs=50,
    imgsz=640,
    batch=2,
    device="cpu",
    workers=0,
    patience=15,
    project="runs/detect",
    name="fruitlet_detection",
    exist_ok=True
)