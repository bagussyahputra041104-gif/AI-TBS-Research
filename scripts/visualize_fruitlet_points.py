import cv2
from pathlib import Path

IMAGE_PATH = Path("Fruitset/Pic_20260923152205302.png")
POINTS_PATH = Path(
    "annotations/fruitlets/Pic_20260923152205302_fruitlets.txt"
)
OUTPUT_DIR = Path("results/17_fruitlet_annotation")
OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

image = cv2.imread(str(IMAGE_PATH))

with open(POINTS_PATH, "r") as f:
    points = [
        tuple(map(int, line.strip().split(",")))
        for line in f
        if line.strip()
    ]

for i, (x, y) in enumerate(points, start=1):
    cv2.circle(image, (x, y), 7, (0, 255, 0), -1)

    cv2.putText(
        image,
        str(i),
        (x + 8, y),
        cv2.FONT_HERSHEY_SIMPLEX,
        0.55,
        (0, 255, 0),
        2
    )

output = OUTPUT_DIR / "Pic_20260923152205302_fruitlets.png"
cv2.imwrite(str(output), image)

print("=" * 50)
print("VISUALISASI ANOTASI FRUITLET")
print("=" * 50)
print(f"Jumlah titik : {len(points)}")
print(f"Output       : {output}")
print("=" * 50)