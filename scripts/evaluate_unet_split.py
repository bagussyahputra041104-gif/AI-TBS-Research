from pathlib import Path

import cv2
import numpy as np
import torch
import torch.nn as nn


# =========================================================
# CONFIG
# =========================================================

TEST_DIR = Path("dataset/segmentation/split/test")

MODEL_PATH = Path(
    "models/experiments/baseline_segmentation/"
    "unet_small_split_baseline.pth"
)

IMAGE_SIZE = 256

DEVICE = torch.device(
    "cuda" if torch.cuda.is_available() else "cpu"
)


# =========================================================
# U-NET
# =========================================================

class DoubleConv(nn.Module):

    def __init__(self, in_channels, out_channels):
        super().__init__()

        self.block = nn.Sequential(
            nn.Conv2d(
                in_channels,
                out_channels,
                3,
                padding=1
            ),
            nn.ReLU(inplace=True),

            nn.Conv2d(
                out_channels,
                out_channels,
                3,
                padding=1
            ),
            nn.ReLU(inplace=True)
        )

    def forward(self, x):
        return self.block(x)


class UNetSmall(nn.Module):

    def __init__(self):
        super().__init__()

        self.enc1 = DoubleConv(3, 16)
        self.pool1 = nn.MaxPool2d(2)

        self.enc2 = DoubleConv(16, 32)
        self.pool2 = nn.MaxPool2d(2)

        self.bottleneck = DoubleConv(32, 64)

        self.up2 = nn.ConvTranspose2d(
            64, 32, 2, stride=2
        )

        self.dec2 = DoubleConv(64, 32)

        self.up1 = nn.ConvTranspose2d(
            32, 16, 2, stride=2
        )

        self.dec1 = DoubleConv(32, 16)

        self.out = nn.Conv2d(
            16, 1, 1
        )

    def forward(self, x):

        e1 = self.enc1(x)
        e2 = self.enc2(self.pool1(e1))

        b = self.bottleneck(self.pool2(e2))

        d2 = self.up2(b)
        d2 = torch.cat([d2, e2], dim=1)
        d2 = self.dec2(d2)

        d1 = self.up1(d2)
        d1 = torch.cat([d1, e1], dim=1)
        d1 = self.dec1(d1)

        return self.out(d1)


# =========================================================
# METRICS
# =========================================================

def calculate_metrics(pred, target):

    pred = pred.astype(bool)
    target = target.astype(bool)

    tp = np.logical_and(
        pred,
        target
    ).sum()

    fp = np.logical_and(
        pred,
        np.logical_not(target)
    ).sum()

    fn = np.logical_and(
        np.logical_not(pred),
        target
    ).sum()

    iou = tp / (tp + fp + fn + 1e-8)

    dice = (
        2 * tp
        /
        (2 * tp + fp + fn + 1e-8)
    )

    precision = (
        tp
        /
        (tp + fp + 1e-8)
    )

    recall = (
        tp
        /
        (tp + fn + 1e-8)
    )

    return iou, dice, precision, recall


# =========================================================
# MAIN
# =========================================================

def main():

    print("================================")
    print("U-NET TEST EVALUATION")
    print("================================")

    print(f"Device: {DEVICE}")
    print()

    # Load model
    model = UNetSmall().to(DEVICE)

    model.load_state_dict(
        torch.load(
            MODEL_PATH,
            map_location=DEVICE
        )
    )

    model.eval()

    images = sorted(
        (TEST_DIR / "images").glob("*.png")
    )

    print(f"Test images: {len(images)}")
    print()

    all_metrics = []

    for image_path in images:

        mask_path = (
            TEST_DIR /
            "masks" /
            f"{image_path.stem}_mask_manual.png"
        )

        image = cv2.imread(
            str(image_path)
        )

        image_rgb = cv2.cvtColor(
            image,
            cv2.COLOR_BGR2RGB
        )

        original_h, original_w = image.shape[:2]

        image_resized = cv2.resize(
            image_rgb,
            (IMAGE_SIZE, IMAGE_SIZE)
        )

        image_input = (
            image_resized.astype(np.float32)
            / 255.0
        )

        image_input = torch.from_numpy(
            image_input
        ).permute(2, 0, 1).unsqueeze(0)

        image_input = image_input.to(DEVICE)

        with torch.no_grad():

            output = model(image_input)

            probability = torch.sigmoid(
                output
            )

            prediction = (
                probability > 0.5
            ).float()

        prediction = (
            prediction
            .squeeze()
            .cpu()
            .numpy()
        )

        prediction = cv2.resize(
            prediction,
            (original_w, original_h),
            interpolation=cv2.INTER_NEAREST
        )

        prediction = prediction > 0.5

        ground_truth = cv2.imread(
            str(mask_path),
            cv2.IMREAD_GRAYSCALE
        )

        ground_truth = ground_truth > 127

        iou, dice, precision, recall = (
            calculate_metrics(
                prediction,
                ground_truth
            )
        )

        all_metrics.append(
            [iou, dice, precision, recall]
        )

        print(f"Image: {image_path.name}")
        print(f"IoU       : {iou * 100:.2f}%")
        print(f"Dice      : {dice * 100:.2f}%")
        print(f"Precision : {precision * 100:.2f}%")
        print(f"Recall    : {recall * 100:.2f}%")
        print()

    if all_metrics:

        mean_metrics = np.mean(
            all_metrics,
            axis=0
        )

        print("================================")
        print("MEAN TEST RESULT")
        print("================================")

        print(
            f"IoU       : "
            f"{mean_metrics[0] * 100:.2f}%"
        )

        print(
            f"Dice      : "
            f"{mean_metrics[1] * 100:.2f}%"
        )

        print(
            f"Precision : "
            f"{mean_metrics[2] * 100:.2f}%"
        )

        print(
            f"Recall    : "
            f"{mean_metrics[3] * 100:.2f}%"
        )

    print()
    print("Evaluasi selesai.")


if __name__ == "__main__":
    main()