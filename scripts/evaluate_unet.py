from pathlib import Path

import cv2
import numpy as np


# =========================
# PATH
# =========================
GT_DIR = Path("dataset/segmentation/masks")
PRED_DIR = Path("results/08_baseline_prediction")

THRESHOLD = 127


# =========================
# METRICS
# =========================
def calculate_metrics(gt, pred):

    gt = gt > THRESHOLD
    pred = pred > THRESHOLD

    intersection = np.logical_and(gt, pred).sum()

    union = np.logical_or(gt, pred).sum()

    gt_pixels = gt.sum()
    pred_pixels = pred.sum()

    iou = (
        intersection / union
        if union > 0
        else 0
    )

    dice = (
        (2 * intersection)
        / (gt_pixels + pred_pixels)
        if (gt_pixels + pred_pixels) > 0
        else 0
    )

    return iou, dice


# =========================
# MAIN
# =========================
def main():

    predictions = sorted(
        PRED_DIR.glob("*_prediction_mask.png")
    )

    if not predictions:
        print("Tidak ditemukan mask prediksi.")
        return

    print("======================================")
    print("EVALUASI U-NET BASELINE")
    print("======================================")
    print()

    all_iou = []
    all_dice = []

    for pred_path in predictions:

        stem = pred_path.name.replace(
            "_prediction_mask.png",
            ""
        )

        gt_path = (
            GT_DIR
            / f"{stem}_mask_manual.png"
        )

        if not gt_path.exists():
            print(
                f"GT tidak ditemukan: {gt_path}"
            )
            continue

        gt = cv2.imread(
            str(gt_path),
            cv2.IMREAD_GRAYSCALE
        )

        pred = cv2.imread(
            str(pred_path),
            cv2.IMREAD_GRAYSCALE
        )

        if gt is None or pred is None:
            print(
                f"Gagal membaca: {stem}"
            )
            continue

        # Pastikan ukuran sama
        if gt.shape != pred.shape:

            pred = cv2.resize(
                pred,
                (gt.shape[1], gt.shape[0]),
                interpolation=cv2.INTER_NEAREST
            )

        iou, dice = calculate_metrics(
            gt,
            pred
        )

        all_iou.append(iou)
        all_dice.append(dice)

        print(f"Gambar : {stem}")
        print(f"IoU    : {iou * 100:.2f}%")
        print(f"Dice   : {dice * 100:.2f}%")
        print("--------------------------------------")

    if all_iou:

        mean_iou = np.mean(all_iou)
        mean_dice = np.mean(all_dice)

        print()
        print("======================================")
        print("RATA-RATA")
        print("======================================")
        print(f"Mean IoU  : {mean_iou * 100:.2f}%")
        print(f"Mean Dice : {mean_dice * 100:.2f}%")
        print("======================================")


if __name__ == "__main__":
    main()