import cv2
from pathlib import Path

IMAGE_DIR = Path("Fruitset")
POINTS_DIR = Path("annotations/fruitlets")
OUTPUT_DIR = Path("results/18_fruitlet_boxes")

OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

BOX_SIZE = 40
HALF = BOX_SIZE // 2

images = sorted(IMAGE_DIR.glob("*.png"))

for image_path in images:

    points_path = POINTS_DIR / f"{image_path.stem}_fruitlets.txt"

    if not points_path.exists():
        print(f"[SKIP] Anotasi tidak ditemukan: {image_path.name}")
        continue

    image = cv2.imread(str(image_path))

    with open(points_path, "r") as f:
        points = [
            tuple(map(int, line.strip().split(",")))
            for line in f
            if line.strip()
        ]

    for i, (x, y) in enumerate(points, start=1):

        x1 = max(0, x - HALF)
        y1 = max(0, y - HALF)
        x2 = min(image.shape[1] - 1, x + HALF)
        y2 = min(image.shape[0] - 1, y + HALF)

        cv2.rectangle(
            image,
            (x1, y1),
            (x2, y2),
            (0, 255, 0),
            2
        )

        cv2.circle(
            image,
            (x, y),
            4,
            (0, 0, 255),
            -1
        )

        cv2.putText(
            image,
            str(i),
            (x1, max(20, y1 - 5)),
            cv2.FONT_HERSHEY_SIMPLEX,
            0.5,
            (0, 255, 0),
            1
        )

    output = OUTPUT_DIR / f"{image_path.stem}_boxes40.png"

    cv2.imwrite(str(output), image)

    print(
        f"[OK] {image_path.name} "
        f"→ {len(points)} fruitlet "
        f"→ {output.name}"
    )

print()
print("=" * 60)
print("SEMUA VISUALISASI SELESAI")
print("=" * 60)