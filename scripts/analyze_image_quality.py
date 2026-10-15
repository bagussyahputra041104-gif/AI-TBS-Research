
from pathlib import Path
import csv

import cv2
import numpy as np

ROOT = Path(__file__).resolve().parent.parent
SOURCE = ROOT / "Fruitset"
OUTPUT = ROOT / "results" / "02_image_quality"

OUTPUT.mkdir(parents=True, exist_ok=True)

extensions = {".jpg", ".jpeg", ".png", ".bmp", ".webp"}
rows = []

for path in sorted(SOURCE.rglob("*")):
    if not path.is_file() or path.suffix.lower() not in extensions:
        continue

    image = cv2.imread(str(path))

    if image is None:
        print(f"GAGAL MEMBACA: {path.name}")
        continue

    height, width = image.shape[:2]

    gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
    hsv = cv2.cvtColor(image, cv2.COLOR_BGR2HSV)

    # Rata-rata intensitas grayscale: 0-255
    brightness = float(np.mean(gray))

    # Varians Laplacian sebagai indikator ketajaman
    sharpness = float(cv2.Laplacian(gray, cv2.CV_64F).var())

    # Persentase piksel gelap dan terang
    dark_pct = float(np.mean(gray < 40) * 100)
    bright_pct = float(np.mean(gray > 220) * 100)

    # Distribusi hue hanya dihitung untuk piksel cukup jenuh
    saturation = hsv[:, :, 1]
    hue = hsv[:, :, 0]
    valid_hue = hue[saturation > 40]

    if valid_hue.size:
        hue_mean = float(np.mean(valid_hue))
        saturated_pct = float(np.mean(saturation > 40) * 100)
    else:
        hue_mean = ""
        saturated_pct = 0.0

    rows.append({
        "filename": path.name,
        "width": width,
        "height": height,
        "brightness_mean": round(brightness, 2),
        "laplacian_variance": round(sharpness, 2),
        "dark_pixels_pct": round(dark_pct, 2),
        "bright_pixels_pct": round(bright_pct, 2),
        "saturated_pixels_pct": round(saturated_pct, 2),
        "mean_hue_saturated_pixels": (
            round(hue_mean, 2) if hue_mean != "" else ""
        ),
    })

columns = [
    "filename",
    "width",
    "height",
    "brightness_mean",
    "laplacian_variance",
    "dark_pixels_pct",
    "bright_pixels_pct",
    "saturated_pixels_pct",
    "mean_hue_saturated_pixels",
]

output_file = OUTPUT / "image_quality.csv"

with output_file.open("w", newline="", encoding="utf-8-sig") as f:
    writer = csv.DictWriter(f, fieldnames=columns)
    writer.writeheader()
    writer.writerows(rows)

print("=" * 45)
print("ANALISIS KUALITAS CITRA TBS")
print("=" * 45)
print(f"Jumlah gambar dianalisis: {len(rows)}")
print(f"Hasil CSV: {output_file}")

if rows:
    for key in [
        "brightness_mean",
        "laplacian_variance",
        "dark_pixels_pct",
        "bright_pixels_pct",
    ]:
        values = [r[key] for r in rows]
        print(
            f"{key}: minimum={min(values):.2f}, "
            f"maksimum={max(values):.2f}, "
            f"rata-rata={np.mean(values):.2f}"
        )

print("Analisis selesai.")
