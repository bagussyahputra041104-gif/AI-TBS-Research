import cv2
import numpy as np
from pathlib import Path

MASK_DIR = Path("annotations/masks")
REFINED_DIR = Path("results/06_grabcut_refined")

manual_masks = sorted(MASK_DIR.glob("*_mask_manual.png"))

if not manual_masks:
    print("Mask manual tidak ditemukan.")
    raise SystemExit

results = []

print("\n=== EVALUASI GRABCUT REFINED ===")

for manual_path in manual_masks:

    name = manual_path.name.replace("_mask_manual.png", "")
    refined_path = REFINED_DIR / f"{name}_mask.png"

    gt = cv2.imread(
        str(manual_path),
        cv2.IMREAD_GRAYSCALE
    )

    pred = cv2.imread(
        str(refined_path),
        cv2.IMREAD_GRAYSCALE
    )

    if gt is None:
        print(f"Gagal membaca GT: {manual_path.name}")
        continue

    if pred is None:
        print(f"Mask refined tidak ditemukan: {refined_path.name}")
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

    print(f"\n{name}")
    print(f"  IoU  : {iou:.4f} ({iou * 100:.2f}%)")
    print(f"  Dice : {dice:.4f} ({dice * 100:.2f}%)")


if results:

    mean_iou = np.mean(
        [r[1] for r in results]
    )

    mean_dice = np.mean(
        [r[2] for r in results]
    )

    print("\n=== RATA-RATA ===")
    print(
        f"IoU  : {mean_iou:.4f} "
        f"({mean_iou * 100:.2f}%)"
    )

    print(
        f"Dice : {mean_dice:.4f} "
        f"({mean_dice * 100:.2f}%)"
    )