from pathlib import Path

import cv2
import numpy as np


IMAGE_DIR = Path("dataset/segmentation/images")
GT_DIR = Path("dataset/segmentation/masks")
PRED_DIR = Path("results/08_baseline_prediction")
OUTPUT_DIR = Path("results/09_unet_visualization")


def add_title(image, title):
    result = image.copy()

    cv2.rectangle(
        result,
        (0, 0),
        (result.shape[1], 45),
        (40, 40, 40),
        -1
    )

    cv2.putText(
        result,
        title,
        (15, 30),
        cv2.FONT_HERSHEY_SIMPLEX,
        0.8,
        (255, 255, 255),
        2,
        cv2.LINE_AA
    )

    return result


def main():

    OUTPUT_DIR.mkdir(
        parents=True,
        exist_ok=True
    )

    images = sorted(
        IMAGE_DIR.glob("*.png")
    )

    print("======================================")
    print("VISUALISASI U-NET")
    print("======================================")
    print()

    for image_path in images:

        stem = image_path.stem

        gt_path = (
            GT_DIR
            / f"{stem}_mask_manual.png"
        )

        pred_path = (
            PRED_DIR
            / f"{stem}_prediction_mask.png"
        )

        image = cv2.imread(
            str(image_path)
        )

        gt = cv2.imread(
            str(gt_path),
            cv2.IMREAD_GRAYSCALE
        )

        pred = cv2.imread(
            str(pred_path),
            cv2.IMREAD_GRAYSCALE
        )

        if (
            image is None
            or gt is None
            or pred is None
        ):
            print(
                f"Gagal membaca: {stem}"
            )
            continue

        # =========================
        # MASK -> TAMPILAN
        # =========================

        gt_display = cv2.cvtColor(
            gt,
            cv2.COLOR_GRAY2BGR
        )

        pred_display = cv2.cvtColor(
            pred,
            cv2.COLOR_GRAY2BGR
        )

        # =========================
        # OVERLAY GT
        # =========================

        gt_overlay = image.copy()

        gt_color = np.zeros_like(image)
        gt_color[:, :] = (0, 255, 0)

        gt_mask = gt > 0

        gt_overlay[gt_mask] = (
            gt_overlay[gt_mask] * 0.65
            + gt_color[gt_mask] * 0.35
        ).astype(np.uint8)

        # =========================
        # OVERLAY PREDIKSI
        # =========================

        pred_overlay = image.copy()

        pred_color = np.zeros_like(image)
        pred_color[:, :] = (0, 0, 255)

        pred_mask = pred > 0

        pred_overlay[pred_mask] = (
            pred_overlay[pred_mask] * 0.65
            + pred_color[pred_mask] * 0.35
        ).astype(np.uint8)

        # =========================
        # RESIZE
        # =========================

        width = 500

        def resize_width(img):
            h, w = img.shape[:2]
            new_h = int(h * width / w)

            return cv2.resize(
                img,
                (width, new_h)
            )

        image = resize_width(image)
        gt_display = resize_width(gt_display)
        pred_display = resize_width(pred_display)
        gt_overlay = resize_width(gt_overlay)
        pred_overlay = resize_width(pred_overlay)

        # =========================
        # BARIS 1
        # =========================

        row1 = np.hstack([
            add_title(
                image,
                "Foto Asli"
            ),
            add_title(
                gt_display,
                "Ground Truth Manual"
            ),
            add_title(
                pred_display,
                "Prediksi U-Net"
            )
        ])

        # =========================
        # BARIS 2
        # =========================

        row2 = np.hstack([
            add_title(
                image,
                "Foto Asli"
            ),
            add_title(
                gt_overlay,
                "Overlay Ground Truth"
            ),
            add_title(
                pred_overlay,
                "Overlay Prediksi U-Net"
            )
        ])

        # Gabungkan
        comparison = np.vstack([
            row1,
            row2
        ])

        output_path = (
            OUTPUT_DIR
            / f"{stem}_comparison.png"
        )

        cv2.imwrite(
            str(output_path),
            comparison
        )

        print(
            "Disimpan:",
            output_path
        )

    print()
    print("======================================")
    print("Visualisasi selesai.")
    print("======================================")


if __name__ == "__main__":
    main()