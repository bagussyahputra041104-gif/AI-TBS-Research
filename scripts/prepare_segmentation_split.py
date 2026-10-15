from pathlib import Path
import shutil

# Folder utama dataset segmentasi
BASE_DIR = Path("dataset/segmentation")

IMAGE_DIR = BASE_DIR / "images"
MASK_DIR = BASE_DIR / "masks"

# Folder output
SPLIT_DIR = BASE_DIR / "split"

TRAIN_IMG = SPLIT_DIR / "train" / "images"
TRAIN_MASK = SPLIT_DIR / "train" / "masks"

VAL_IMG = SPLIT_DIR / "validation" / "images"
VAL_MASK = SPLIT_DIR / "validation" / "masks"

TEST_IMG = SPLIT_DIR / "test" / "images"
TEST_MASK = SPLIT_DIR / "test" / "masks"


def copy_pair(stem, image_dst, mask_dst):
    image = IMAGE_DIR / f"{stem}.png"
    mask = MASK_DIR / f"{stem}_mask_manual.png"

    if not image.exists():
        print(f"[SKIP] Image tidak ditemukan: {image}")
        return

    if not mask.exists():
        print(f"[SKIP] Mask tidak ditemukan: {mask}")
        return

    shutil.copy2(image, image_dst / image.name)
    shutil.copy2(mask, mask_dst / mask.name)

    print(f"[OK] {stem}")


def main():
    # Buat folder
    for folder in [
        TRAIN_IMG, TRAIN_MASK,
        VAL_IMG, VAL_MASK,
        TEST_IMG, TEST_MASK
    ]:
        folder.mkdir(parents=True, exist_ok=True)

    images = sorted(IMAGE_DIR.glob("*.png"))

    if not images:
        print("Tidak ada gambar ditemukan.")
        return

    stems = [img.stem for img in images]

    print(f"Jumlah gambar: {len(stems)}")
    print()

    # SIMULASI pembagian dataset
    #
    # Karena saat ini hanya ada 4 gambar,
    # pembagian ini hanya untuk menguji struktur pipeline.
    #
    # 2 train
    # 1 validation
    # 1 test

    train_stems = stems[:2]
    val_stems = stems[2:3]
    test_stems = stems[3:]

    print("TRAIN:")
    for stem in train_stems:
        copy_pair(stem, TRAIN_IMG, TRAIN_MASK)

    print("\nVALIDATION:")
    for stem in val_stems:
        copy_pair(stem, VAL_IMG, VAL_MASK)

    print("\nTEST:")
    for stem in test_stems:
        copy_pair(stem, TEST_IMG, TEST_MASK)

    print("\n================================")
    print("Pembagian dataset selesai.")
    print("================================")


if __name__ == "__main__":
    main()