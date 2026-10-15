import cv2
from pathlib import Path

IMAGE_DIR = Path("Fruitset")
OUTPUT_DIR = Path("annotations/fruitlets")

OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

images = sorted(IMAGE_DIR.glob("*.png"))

if not images:
    print("Tidak ada gambar!")
    exit()


for image_path in images:

    output_file = OUTPUT_DIR / f"{image_path.stem}_fruitlets.txt"

    # Lewati gambar yang sudah dianotasi
    if output_file.exists():
        print(f"[SKIP] Sudah ada: {image_path.name}")
        continue

    image = cv2.imread(str(image_path))

    if image is None:
        print(f"[ERROR] Gagal membaca: {image_path.name}")
        continue

    display = image.copy()
    points = []

    def mouse_callback(event, x, y, flags, param):
        if event == cv2.EVENT_LBUTTONDOWN:

            points.append((x, y))

            cv2.circle(
                display,
                (x, y),
                7,
                (0, 255, 0),
                -1
            )

            cv2.putText(
                display,
                str(len(points)),
                (x + 10, y),
                cv2.FONT_HERSHEY_SIMPLEX,
                0.6,
                (0, 255, 0),
                2
            )

    cv2.namedWindow("Fruitlet Annotation", cv2.WINDOW_NORMAL)
    cv2.resizeWindow("Fruitlet Annotation", 1200, 800)

    cv2.setMouseCallback(
        "Fruitlet Annotation",
        mouse_callback
    )

    print()
    print("=" * 60)
    print(f"GAMBAR : {image_path.name}")
    print("=" * 60)
    print("Klik tengah setiap fruitlet yang terlihat jelas.")
    print()
    print("S = simpan dan lanjut ke gambar berikutnya")
    print("R = reset")
    print("Q = keluar")
    print("=" * 60)

    while True:

        cv2.imshow("Fruitlet Annotation", display)

        key = cv2.waitKey(1) & 0xFF

        if key == ord("r"):

            points.clear()
            display = image.copy()

            print("Anotasi di-reset.")

        elif key == ord("s"):

            with open(output_file, "w") as f:
                for x, y in points:
                    f.write(f"{x},{y}\n")

            print(
                f"[OK] {len(points)} fruitlet disimpan."
            )
            print(f"File: {output_file}")

            cv2.destroyWindow("Fruitlet Annotation")
            break

        elif key == ord("q"):

            cv2.destroyWindow("Fruitlet Annotation")

            print("Anotasi dihentikan.")
            exit()


cv2.destroyAllWindows()

print()
print("=" * 60)
print("SEMUA ANOTASI SELESAI")
print("=" * 60)