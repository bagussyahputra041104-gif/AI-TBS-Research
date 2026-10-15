import base64
import io
from pathlib import Path

import cv2
import numpy as np
import torch
import torch.nn as nn

from fastapi import FastAPI, File, UploadFile
from fastapi.middleware.cors import CORSMiddleware
from PIL import Image


# ============================================================
# PALMVISION AI BACKEND
# ============================================================

app = FastAPI(
    title="PalmVision AI Backend",
    version="1.0.0",
)


# ============================================================
# CORS
# ============================================================

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
)


# ============================================================
# U-NET MODEL
# ============================================================

class DoubleConv(nn.Module):
    def __init__(self, in_channels, out_channels):
        super().__init__()

        self.block = nn.Sequential(
            nn.Conv2d(
                in_channels,
                out_channels,
                kernel_size=3,
                padding=1,
            ),
            nn.ReLU(inplace=True),

            nn.Conv2d(
                out_channels,
                out_channels,
                kernel_size=3,
                padding=1,
            ),
            nn.ReLU(inplace=True),
        )

    def forward(self, x):
        return self.block(x)


class SmallUNet(nn.Module):
    def __init__(self):
        super().__init__()

        self.enc1 = DoubleConv(3, 16)
        self.pool1 = nn.MaxPool2d(2)

        self.enc2 = DoubleConv(16, 32)
        self.pool2 = nn.MaxPool2d(2)

        self.bottleneck = DoubleConv(32, 64)

        self.up2 = nn.ConvTranspose2d(
            64,
            32,
            kernel_size=2,
            stride=2,
        )

        self.dec2 = DoubleConv(64, 32)

        self.up1 = nn.ConvTranspose2d(
            32,
            16,
            kernel_size=2,
            stride=2,
        )

        self.dec1 = DoubleConv(32, 16)

        self.out = nn.Conv2d(
            16,
            1,
            kernel_size=1,
        )

    def forward(self, x):

        e1 = self.enc1(x)

        e2 = self.enc2(
            self.pool1(e1)
        )

        b = self.bottleneck(
            self.pool2(e2)
        )

        d2 = self.up2(b)

        d2 = torch.cat(
            [d2, e2],
            dim=1,
        )

        d2 = self.dec2(d2)

        d1 = self.up1(d2)

        d1 = torch.cat(
            [d1, e1],
            dim=1,
        )

        d1 = self.dec1(d1)

        return self.out(d1)


# ============================================================
# LOAD MODEL
# ============================================================

BASE_DIR = Path(__file__).resolve().parent

MODEL_PATH = (
    BASE_DIR
    / "../../models/experiments/baseline_segmentation/"
    / "unet_small_split_baseline.pth"
).resolve()

DEVICE = torch.device("cpu")

model = SmallUNet().to(DEVICE)

model.load_state_dict(
    torch.load(
        MODEL_PATH,
        map_location=DEVICE,
        weights_only=True,
    )
)

model.eval()


# ============================================================
# HELPER: MASK TO BASE64
# ============================================================

def encode_mask(mask):
    success, buffer = cv2.imencode(
        ".png",
        mask,
    )

    if not success:
        return ""

    return base64.b64encode(
        buffer.tobytes()
    ).decode("utf-8")


# ============================================================
# HELPER: CIRCULARITY
# ============================================================

def calculate_circularity(contour):

    perimeter = cv2.arcLength(
        contour,
        True,
    )

    if perimeter <= 0:
        return 0.0

    area = cv2.contourArea(
        contour
    )

    return float(
        (4.0 * np.pi * area)
        / (perimeter * perimeter)
    )


# ============================================================
# HELPER: HISTOGRAM
# ============================================================

def calculate_histogram(
    image,
    mask,
    channel,
    bins=32,
):
    """
    Menghitung distribusi channel warna
    hanya pada area TBS hasil segmentasi.

    Hasil dikembalikan dalam persen.
    """

    pixels = image[
        mask > 0,
        channel,
    ]

    if len(pixels) == 0:
        return [0.0] * bins

    histogram, _ = np.histogram(
        pixels,
        bins=bins,
        range=(0, 256),
    )

    histogram = histogram.astype(
        np.float32
    )

    total = histogram.sum()

    if total > 0:
        histogram = (
            histogram / total
        ) * 100.0

    return [
        round(float(value), 4)
        for value in histogram
    ]


# ============================================================
# HOME
# ============================================================

@app.get("/")
def home():

    return {
        "status": "ok",
        "message": "PalmVision AI Backend aktif!",
        "model": "Small U-Net",
        "features": [
            "segmentation",
            "shape_analysis",
            "hsv_analysis",
            "lab_analysis",
            "color_histogram",
        ],
    }


# ============================================================
# ANALYZE
# ============================================================

@app.post("/analyze")
async def analyze(
    file: UploadFile = File(...)
):

    # ========================================================
    # 1. READ IMAGE
    # ========================================================

    image_bytes = await file.read()

    pil_image = Image.open(
        io.BytesIO(image_bytes)
    ).convert("RGB")

    original_width, original_height = (
        pil_image.size
    )

    image_rgb = np.array(
        pil_image
    )

    # ========================================================
    # 2. PREPROCESS IMAGE
    # ========================================================

    resized = cv2.resize(
        image_rgb,
        (256, 256),
        interpolation=cv2.INTER_AREA,
    )

    tensor = (
        torch.from_numpy(
            resized.astype(
                np.float32
            ) / 255.0
        )
        .permute(2, 0, 1)
        .unsqueeze(0)
        .to(DEVICE)
    )

    # ========================================================
    # 3. U-NET PREDICTION
    # ========================================================

    with torch.no_grad():

        prediction = model(
            tensor
        )

        prediction = torch.sigmoid(
            prediction
        )

        prediction = (
            prediction
            .squeeze()
            .cpu()
            .numpy()
        )

    # ========================================================
    # 4. CREATE BINARY MASK
    # ========================================================

    mask_small = (
        prediction > 0.5
    ).astype(np.uint8) * 255

    # ========================================================
    # 5. RESIZE MASK TO ORIGINAL IMAGE
    # ========================================================

    mask = cv2.resize(
        mask_small,
        (
            original_width,
            original_height,
        ),
        interpolation=cv2.INTER_NEAREST,
    )

    # ========================================================
    # 6. FIND CONTOURS
    # ========================================================

    contours, _ = cv2.findContours(
        mask,
        cv2.RETR_EXTERNAL,
        cv2.CHAIN_APPROX_SIMPLE,
    )

    # ========================================================
    # 7. IF OBJECT NOT FOUND
    # ========================================================

    if not contours:

        return {
            "status": "success",

            "filename": file.filename,

            "image": {
                "width": original_width,
                "height": original_height,
            },

            "segmentation": {
                "area_px": 0.0,
                "width_px": 0,
                "height_px": 0,
                "aspect_ratio": 0.0,
                "circularity": 0.0,
            },

            "color": {
                "hsv": {
                    "h_mean": 0.0,
                    "s_mean": 0.0,
                    "v_mean": 0.0,
                },

                "lab": {
                    "l_mean": 0.0,
                    "a_mean": 0.0,
                    "b_mean": 0.0,
                },

                "histogram": {
                    "h": [0.0] * 32,
                    "s": [0.0] * 32,
                    "v": [0.0] * 32,
                    "l": [0.0] * 32,
                    "a": [0.0] * 32,
                    "b": [0.0] * 32,
                },
            },

            "mask": {
                "format": "png",
                "data": encode_mask(mask),
            },
        }

    # ========================================================
    # 8. LARGEST CONTOUR
    # ========================================================

    largest_contour = max(
        contours,
        key=cv2.contourArea,
    )

    # ========================================================
    # 9. SHAPE ANALYSIS
    # ========================================================

    area = cv2.contourArea(
        largest_contour
    )

    x, y, width, height = (
        cv2.boundingRect(
            largest_contour
        )
    )

    if height > 0:
        aspect_ratio = (
            width / height
        )
    else:
        aspect_ratio = 0.0

    circularity = (
        calculate_circularity(
            largest_contour
        )
    )

    # ========================================================
    # 10. CLEAN OBJECT MASK
    # ========================================================

    object_mask = np.zeros_like(
        mask
    )

    cv2.drawContours(
        object_mask,
        [largest_contour],
        -1,
        255,
        thickness=-1,
    )

    # ========================================================
    # 11. HSV COLOR
    # ========================================================

    hsv_image = cv2.cvtColor(
        image_rgb,
        cv2.COLOR_RGB2HSV,
    )

    hsv_pixels = hsv_image[
        object_mask > 0
    ]

    if len(hsv_pixels) > 0:

        h_mean = float(
            np.mean(
                hsv_pixels[:, 0]
            )
        )

        s_mean = float(
            np.mean(
                hsv_pixels[:, 1]
            )
        )

        v_mean = float(
            np.mean(
                hsv_pixels[:, 2]
            )
        )

    else:

        h_mean = 0.0
        s_mean = 0.0
        v_mean = 0.0

    # ========================================================
    # 12. LAB COLOR
    # ========================================================

    lab_image = cv2.cvtColor(
        image_rgb,
        cv2.COLOR_RGB2LAB,
    )

    lab_pixels = lab_image[
        object_mask > 0
    ]

    if len(lab_pixels) > 0:

        l_mean = float(
            np.mean(
                lab_pixels[:, 0]
            )
        )

        a_mean = float(
            np.mean(
                lab_pixels[:, 1]
            )
        )

        b_mean = float(
            np.mean(
                lab_pixels[:, 2]
            )
        )

    else:

        l_mean = 0.0
        a_mean = 0.0
        b_mean = 0.0

    # ========================================================
    # 13. HSV HISTOGRAM
    # ========================================================

    h_hist = calculate_histogram(
        hsv_image,
        object_mask,
        0,
    )

    s_hist = calculate_histogram(
        hsv_image,
        object_mask,
        1,
    )

    v_hist = calculate_histogram(
        hsv_image,
        object_mask,
        2,
    )

    # ========================================================
    # 14. LAB HISTOGRAM
    # ========================================================

    l_hist = calculate_histogram(
        lab_image,
        object_mask,
        0,
    )

    a_hist = calculate_histogram(
        lab_image,
        object_mask,
        1,
    )

    b_hist = calculate_histogram(
        lab_image,
        object_mask,
        2,
    )

    # ========================================================
    # 15. RETURN RESULT
    # ========================================================

    return {

        "status": "success",

        "filename": file.filename,

        # ----------------------------------------------------
        # IMAGE
        # ----------------------------------------------------

        "image": {
            "width": original_width,
            "height": original_height,
        },

        # ----------------------------------------------------
        # SEGMENTATION + SHAPE
        # ----------------------------------------------------

        "segmentation": {

            "area_px": round(
                float(area),
                2,
            ),

            "width_px": int(
                width
            ),

            "height_px": int(
                height
            ),

            "aspect_ratio": round(
                float(aspect_ratio),
                4,
            ),

            "circularity": round(
                float(circularity),
                4,
            ),
        },

        # ----------------------------------------------------
        # COLOR
        # ----------------------------------------------------

        "color": {

            "hsv": {

                "h_mean": round(
                    h_mean,
                    2,
                ),

                "s_mean": round(
                    s_mean,
                    2,
                ),

                "v_mean": round(
                    v_mean,
                    2,
                ),
            },

            "lab": {

                "l_mean": round(
                    l_mean,
                    2,
                ),

                "a_mean": round(
                    a_mean,
                    2,
                ),

                "b_mean": round(
                    b_mean,
                    2,
                ),
            },

            # ------------------------------------------------
            # HISTOGRAM
            # ------------------------------------------------

            "histogram": {

                "h": h_hist,

                "s": s_hist,

                "v": v_hist,

                "l": l_hist,

                "a": a_hist,

                "b": b_hist,
            },
        },

        # ----------------------------------------------------
        # MASK
        # ----------------------------------------------------

        "mask": {

            "format": "png",

            "data": encode_mask(
                mask
            ),
        },
    }