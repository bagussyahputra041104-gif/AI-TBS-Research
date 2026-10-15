from pathlib import Path
import cv2
import numpy as np
import torch
import torch.nn as nn


# ============================================================
# PATH
# ============================================================

TEST_IMAGES_DIR = Path("dataset/segmentation/split/test/images")
TEST_MASKS_DIR = Path("dataset/segmentation/split/test/masks")

MODEL_PATH = Path(
    "models/experiments/baseline_segmentation/unet_small_split_baseline.pth"
)

OUTPUT_DIR = Path("results/10_test_visualization")
OUTPUT_DIR.mkdir(parents=True, exist_ok=True)


# ============================================================
# MODEL
# ============================================================

class DoubleConv(nn.Module):
    def __init__(self, in_channels, out_channels):
        super().__init__()

        self.block = nn.Sequential(
            nn.Conv2d(in_channels, out_channels, 3, padding=1),
            nn.ReLU(inplace=True),

            nn.Conv2d(out_channels, out_channels, 3, padding=1),
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

        self.out = nn.Conv2d(16, 1, 1)

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


# ============================================================
# DEVICE
# ============================================================

device = torch.device("cpu")


# ============================================================
# LOAD MODEL
# ============================================================

model = UNetSmall()

model.load_state_dict(
    torch.load(
        MODEL_PATH,
        map_location=device
    )
)

model.to(device)
model.eval()


# ============================================================
# HEADER
# ============================================================

print("================================")
print("VISUALISASI TEST PREDICTION")
print("================================")
print()

print("Model berhasil dimuat.")
print()


# ============================================================
# FIND TEST IMAGES
# ============================================================

image_paths = sorted(
    TEST_IMAGES_DIR.glob("*.png")
)

print(f"Jumlah gambar test: {len(image_paths)}")
print()


if len(image_paths) == 0:

    print("[ERROR] Tidak ada gambar test.")

    raise SystemExit


# ============================================================
# PROCESS
# ============================================================

for image_path in image_paths:

    print(f"Memproses: {image_path.name}")

    # --------------------------------------------------------
    # LOAD IMAGE
    # --------------------------------------------------------

    image = cv2.imread(
        str(image_path)
    )

    if image is None:

        print("[ERROR] Gambar tidak dapat dibaca.")
        continue

    original_h, original_w = image.shape[:2]


    # --------------------------------------------------------
    # FIND GROUND TRUTH MASK
    # --------------------------------------------------------

    # Nama gambar:
    # Pic_xxxxx.png
    #
    # Nama mask manual:
    # Pic_xxxxx_mask_manual.png

    mask_path = TEST_MASKS_DIR / (
        image_path.stem + "_mask_manual.png"
    )

    if not mask_path.exists():

        print("[ERROR] Ground truth tidak ditemukan:")
        print(mask_path)

        continue


    # --------------------------------------------------------
    # LOAD MASK
    # --------------------------------------------------------

    ground_truth = cv2.imread(
        str(mask_path),
        cv2.IMREAD_GRAYSCALE
    )

    if ground_truth is None:

        print("[ERROR] Mask tidak dapat dibaca.")
        continue


    # --------------------------------------------------------
    # PREPROCESS IMAGE
    # --------------------------------------------------------

    image_rgb = cv2.cvtColor(
        image,
        cv2.COLOR_BGR2RGB
    )

    resized = cv2.resize(
        image_rgb,
        (256, 256)
    )

    input_tensor = (
        torch.from_numpy(resized)
        .permute(2, 0, 1)
        .float()
        / 255.0
    )

    input_tensor = input_tensor.unsqueeze(0).to(device)


    # --------------------------------------------------------
    # PREDICTION
    # --------------------------------------------------------

    with torch.no_grad():

        output = model(input_tensor)

        probability = torch.sigmoid(output)

        prediction = (
            probability > 0.5
        ).float()


    # --------------------------------------------------------
    # RESIZE PREDICTION
    # --------------------------------------------------------

    prediction_mask = (
        prediction[0, 0]
        .cpu()
        .numpy()
        * 255
    ).astype(np.uint8)


    prediction_mask = cv2.resize(
        prediction_mask,
        (original_w, original_h),
        interpolation=cv2.INTER_NEAREST
    )


    # --------------------------------------------------------
    # PREPARE GROUND TRUTH
    # --------------------------------------------------------

    ground_truth = cv2.resize(
        ground_truth,
        (original_w, original_h),
        interpolation=cv2.INTER_NEAREST
    )

    ground_truth = np.where(
        ground_truth > 127,
        255,
        0
    ).astype(np.uint8)


    # --------------------------------------------------------
    # SAVE PREDICTION MASK
    # --------------------------------------------------------

    prediction_path = (
        OUTPUT_DIR
        / f"{image_path.stem}_prediction.png"
    )

    cv2.imwrite(
        str(prediction_path),
        prediction_mask
    )


    # --------------------------------------------------------
    # CREATE OVERLAYS
    # --------------------------------------------------------

    # Ground truth = merah
    ground_truth_overlay = image.copy()

    gt_region = ground_truth > 0

    ground_truth_overlay[gt_region] = (
        0.5 * ground_truth_overlay[gt_region]
        + 0.5 * np.array([0, 0, 255])
    ).astype(np.uint8)


    # Prediction = hijau
    prediction_overlay = image.copy()

    pred_region = prediction_mask > 0

    prediction_overlay[pred_region] = (
        0.5 * prediction_overlay[pred_region]
        + 0.5 * np.array([0, 255, 0])
    ).astype(np.uint8)


    # --------------------------------------------------------
    # SAVE OVERLAYS
    # --------------------------------------------------------

    cv2.imwrite(
        str(
            OUTPUT_DIR
            / f"{image_path.stem}_ground_truth_overlay.png"
        ),
        ground_truth_overlay
    )

    cv2.imwrite(
        str(
            OUTPUT_DIR
            / f"{image_path.stem}_prediction_overlay.png"
        ),
        prediction_overlay
    )


    # --------------------------------------------------------
    # COMPARISON IMAGE
    # --------------------------------------------------------

    # Resize supaya 4 gambar bisa disusun
    display_w = 500
    display_h = int(
        original_h
        * display_w
        / original_w
    )

    original_display = cv2.resize(
        image,
        (display_w, display_h)
    )

    gt_display = cv2.resize(
        ground_truth_overlay,
        (display_w, display_h)
    )

    pred_display = cv2.resize(
        prediction_overlay,
        (display_w, display_h)
    )


    # Overlay gabungan:
    # GT = merah
    # Prediction = hijau

    combined = image.copy()

    gt = ground_truth > 0
    pred = prediction_mask > 0

    # True Positive = kuning
    tp = gt & pred

    # False Positive = hijau
    fp = (~gt) & pred

    # False Negative = merah
    fn = gt & (~pred)

    combined[tp] = [0, 255, 255]
    combined[fp] = [0, 255, 0]
    combined[fn] = [0, 0, 255]

    combined_display = cv2.resize(
        combined,
        (display_w, display_h)
    )


    # --------------------------------------------------------
    # ADD LABELS
    # --------------------------------------------------------

    panels = [
        ("ORIGINAL", original_display),
        ("GROUND TRUTH", gt_display),
        ("PREDICTION", pred_display),
        ("ERROR ANALYSIS", combined_display)
    ]

    labeled_panels = []

    for title, panel in panels:

        panel = panel.copy()

        cv2.putText(
            panel,
            title,
            (20, 35),
            cv2.FONT_HERSHEY_SIMPLEX,
            1,
            (255, 255, 255),
            2,
            cv2.LINE_AA
        )

        labeled_panels.append(panel)


    # --------------------------------------------------------
    # CONCATENATE
    # --------------------------------------------------------

    comparison = np.hstack(
        labeled_panels
    )


    # --------------------------------------------------------
    # SAVE COMPARISON
    # --------------------------------------------------------

    comparison_path = (
        OUTPUT_DIR
        / f"{image_path.stem}_comparison.png"
    )

    cv2.imwrite(
        str(comparison_path),
        comparison
    )


    print(
        f"[OK] Visualisasi disimpan: "
        f"{comparison_path}"
    )

    print()


print("================================")
print("SELESAI")
print("================================")
print(f"Output: {OUTPUT_DIR}")