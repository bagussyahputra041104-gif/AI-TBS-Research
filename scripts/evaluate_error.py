import cv2
import numpy as np
from pathlib import Path

MASK_DIR = Path("annotations/masks")
GRABCUT_DIR = Path("results/05_grabcut_all")
OUTPUT_DIR = Path("evaluation/error_analysis")

OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

manual_masks = sorted(MASK_DIR.glob("*_mask_manual.png"))

if not manual_masks:
    print("Tidak ditemukan mask manual.")
    raise SystemExit

print("=== ERROR ANALYSIS GRABCUT ===")

for manual_path in manual_masks:

    name = manual_path.name.replace("_mask_manual.png", "")
    grabcut_path = GRABCUT_DIR / f"{name}_mask.png"

    gt = cv2.imread(str(manual_path), cv2.IMREAD_GRAYSCALE)
    pred = cv2.imread(str(grabcut_path), cv2.IMREAD_GRAYSCALE)

    if gt is None:
        print(f"Gagal membaca GT: {manual_path.name}")
        continue

    if pred is None:
        print(f"GrabCut tidak ditemukan: {grabcut_path.name}")
        continue

    gt = gt > 0
    pred = pred > 0

    # True Positive
    tp = np.logical_and(gt, pred)

    # False Positive
    fp = np.logical_and(~gt, pred)

    # False Negative
    fn = np.logical_and(gt, ~pred)

    # Visualisasi error
    error = np.zeros((gt.shape[0], gt.shape[1], 3), dtype=np.uint8)

    # TP = hijau
    error[tp] = (0, 255, 0)

    # FP = merah
    error[fp] = (0, 0, 255)

    # FN = biru
    error[fn] = (255, 0, 0)

    output_path = OUTPUT_DIR / f"{name}_error.png"

    cv2.imwrite(str(output_path), error)

    total_gt = gt.sum()
    total_pred = pred.sum()

    fp_pct = (fp.sum() / total_gt) * 100 if total_gt > 0 else 0
    fn_pct = (fn.sum() / total_gt) * 100 if total_gt > 0 else 0

    print(f"\n{name}")
    print(f"  False Positive : {fp.sum()} pixel ({fp_pct:.2f}%)")
    print(f"  False Negative : {fn.sum()} pixel ({fn_pct:.2f}%)")
    print(f"  Hasil          : {output_path}")

print("\n=== SELESAI ===")
print(f"Hasil tersimpan di: {OUTPUT_DIR}")