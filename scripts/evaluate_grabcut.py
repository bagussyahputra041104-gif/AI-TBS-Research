import cv2
import numpy as np
from pathlib import Path

MASK_DIR = Path("annotations/masks")
GRABCUT_DIR = Path("results/07_grabcut_v2")

images = sorted(MASK_DIR.glob("*_mask_manual.png"))

if not images:
    print("Tidak ditemukan mask manual.")
    raise SystemExit

results = []

for manual_path in images:
    name = manual_path.name.replace("_mask_manual.png", "")
    grabcut_path = GRABCUT_DIR / f"{name}_mask.png"

    gt = cv2.imread(str(manual_path), cv2.IMREAD_GRAYSCALE)
    pred = cv2.imread(str(grabcut_path), cv2.IMREAD_GRAYSCALE)

    if gt is None:
        print(f"Gagal membaca: {manual_path.name}")
        continue

    if pred is None:
        print(f"GrabCut tidak ditemukan: {grabcut_path.name}")
        continue

    gt = gt > 0
    pred = pred > 0

    intersection = np.logical_and(gt, pred).sum()
    union = np.logical_or(gt, pred).sum()

    iou = intersection / union if union > 0 else 0
    dice = (
        2 * intersection / (gt.sum() + pred.sum())
        if (gt.sum() + pred.sum()) > 0
        else 0
    )

    results.append((name, iou, dice))

print("\n=== HASIL EVALUASI GRABCUT ===")

for name, iou, dice in results:
    print(f"{name}")
    print(f"  IoU  : {iou:.4f} ({iou * 100:.2f}%)")
    print(f"  Dice : {dice:.4f} ({dice * 100:.2f}%)")

if results:
    mean_iou = np.mean([r[1] for r in results])
    mean_dice = np.mean([r[2] for r in results])

    print("\n=== RATA-RATA ===")
    print(f"IoU  : {mean_iou:.4f} ({mean_iou * 100:.2f}%)")
    print(f"Dice : {mean_dice:.4f} ({mean_dice * 100:.2f}%)")