
from pathlib import Path
import csv

import cv2
import numpy as np

ROOT = Path(__file__).resolve().parent.parent
SOURCE = ROOT / "Fruitset"
OUTPUT = ROOT / "results" / "03_color_analysis"

OUTPUT.mkdir(parents=True, exist_ok=True)

extensions = {".jpg", ".jpeg", ".png", ".bmp", ".webp"}
rows = []

for path in sorted(SOURCE.rglob("*")):
    if not path.is_file() or path.suffix.lower() not in extensions:
        continue

    image = cv2.imread(str(path))
    if image is None:
        print(f"Gagal membaca: {path.name}")
        continue

    rgb = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)
    hsv = cv2.cvtColor(image, cv2.COLOR_BGR2HSV)

    # Statistik ini mencakup seluruh gambar,
    # termasuk latar belakang.
    mean_rgb = np.mean(rgb, axis=(0, 1))
    mean_hsv = np.mean(hsv, axis=(0, 1))

    rows.append({
        "filename": path.name,
        "mean_red": round(float(mean_rgb[0]), 2),
        "mean_green": round(float(mean_rgb[1]), 2),
        "mean_blue": round(float(mean_rgb[2]), 2),
        "mean_hue_opencv": round(float(mean_hsv[0]), 2),
        "mean_saturation_opencv": round(float(mean_hsv[1]), 2),
        "mean_value_opencv": round(float(mean_hsv[2]), 2),
    })

output_file = OUTPUT / "color_statistics.csv"

columns = [
    "filename",
    "mean_red",
    "mean_green",
    "mean_blue",
    "mean_hue_opencv",
    "mean_saturation_opencv",
    "mean_value_opencv",
]

with output_file.open("w", newline="", encoding="utf-8-sig") as f:
    writer = csv.DictWriter(f, fieldnames=columns)
    writer.writeheader()
    writer.writerows(rows)

print("=" * 45)
print("ANALISIS WARNA CITRA TBS")
print("=" * 45)
print(f"Jumlah gambar dianalisis: {len(rows)}")
print(f"Hasil disimpan di: {output_file}")

for row in rows:
    print(
        f"{row['filename']}: "
        f"RGB=({row['mean_red']}, "
        f"{row['mean_green']}, {row['mean_blue']})"
    )

print("Analisis warna selesai.")
