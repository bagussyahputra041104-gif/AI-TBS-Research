import cv2
import numpy as np
from pathlib import Path

# =========================
# FOLDER
# =========================

GT_DIR = Path("annotations/masks")
PRED_DIR = Path("results/07_grabcut_v2")
OUT_DIR = Path("evaluation/error_analysis")

OUT_DIR.mkdir(parents=True, exist_ok=True)

# =========================
# CARI MASK MANUAL
# =========================

manual_masks = sorted(GT_DIR.glob("*_mask_manual.png"))

if not manual_masks:
    print("Tidak ditemukan mask manual.")
    raise SystemExit

print("=== ERROR ANALYSIS GRABCUT V2 ===")

for gt_path in manual_masks:

    name = gt_path.name.replace("_mask_manual.png", "")

    pred_path = PRED_DIR / f"{name}_mask.png"

    if not pred_path.exists():
        print(f"\nPrediksi tidak ditemukan: {name}")
        continue

    gt = cv2.imread(str(gt_path), cv2.IMREAD_GRAYSCALE)
    pred = cv2.imread(str(pred_path), cv2.IMREAD_GRAYSCALE)

    if gt is None or pred is None:
        print(f"\nGagal membaca: {name}")
        continue

    # Binary
    gt = gt > 0
    pred = pred > 0

    # =========================
    # KATEGORI ERROR
    # =========================

    true_positive = gt & pred
    false_positive = (~gt) & pred
    false_negative = gt & (~pred)

    # =========================
    # BUAT GAMBAR ERROR
    # =========================

    error_map = np.zeros((gt.shape[0], gt.shape[1], 3), dtype=np.uint8)

    # Hijau = benar
    error_map[true_positive] = [0, 255, 0]

    # Merah = background salah masuk
    error_map[false_positive] = [0, 0, 255]

    # Biru = TBS hilang
    error_map[false_negative] = [255, 0, 0]

    # =========================
    # SIMPAN
    # =========================

    output_path = OUT_DIR / f"{name}_error.png"

    cv2.imwrite(str(output_path), error_map)

    # =========================
    # HITUNG JUMLAH PIXEL
    # =========================

    tp = true_positive.sum()
    fp = false_positive.sum()
    fn = false_negative.sum()

    print(f"\n{name}")
    print(f"  True Positive  : {tp}")
    print(f"  False Positive : {fp}")
    print(f"  False Negative : {fn}")
    print(f"  Error map      : {output_path}")

print("\n=== SELESAI ===")
print(f"Hasil tersimpan di: {OUT_DIR}")