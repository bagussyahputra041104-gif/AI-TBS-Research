
from pathlib import Path
from PIL import Image
import csv
import hashlib

# Lokasi proyek
ROOT = Path(__file__).resolve().parent.parent
DATASET_DIR = ROOT / "Fruitset"
OUTPUT_DIR = ROOT / "results" / "01_dataset_audit"

OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

SUPPORTED = {".jpg", ".jpeg", ".png", ".bmp", ".webp"}

rows = []
hashes = {}

for path in sorted(DATASET_DIR.rglob("*")):
    if not path.is_file() or path.suffix.lower() not in SUPPORTED:
        continue

    try:
        with Image.open(path) as img:
            width, height = img.size
            image_format = img.format
            mode = img.mode
            img.verify()

        # Hash file untuk mendeteksi file identik
        file_hash = hashlib.sha256(path.read_bytes()).hexdigest()
        hashes.setdefault(file_hash, []).append(path.name)

        rows.append({
            "filename": path.name,
            "width": width,
            "height": height,
            "pixels": width * height,
            "format": image_format,
            "mode": mode,
            "file_size_bytes": path.stat().st_size,
            "status": "OK"
        })

    except Exception as error:
        rows.append({
            "filename": path.name,
            "width": "",
            "height": "",
            "pixels": "",
            "format": "",
            "mode": "",
            "file_size_bytes": path.stat().st_size,
            "status": f"ERROR: {error}"
        })

csv_path = OUTPUT_DIR / "dataset_audit.csv"

columns = [
    "filename", "width", "height", "pixels",
    "format", "mode", "file_size_bytes", "status"
]

with csv_path.open("w", newline="", encoding="utf-8-sig") as file:
    writer = csv.DictWriter(file, fieldnames=columns)
    writer.writeheader()
    writer.writerows(rows)

duplicates = [names for names in hashes.values() if len(names) > 1]
valid = [row for row in rows if row["status"] == "OK"]

print("=" * 45)
print("LAPORAN AUDIT DATASET TBS")
print("=" * 45)
print(f"Folder sumber : {DATASET_DIR}")
print(f"Jumlah gambar : {len(rows)}")
print(f"Gambar valid  : {len(valid)}")
print(f"Gambar error  : {len(rows) - len(valid)}")
print(f"Resolusi unik : {len(set((r['width'], r['height']) for r in valid))}")
print(f"Grup file identik berdasarkan SHA-256: {len(duplicates)}")
print(f"Laporan CSV   : {csv_path}")

if valid:
    total_bytes = sum(r["file_size_bytes"] for r in valid)
    print(f"Total ukuran  : {total_bytes / (1024**2):.2f} MiB")

print("\nAudit selesai.")
