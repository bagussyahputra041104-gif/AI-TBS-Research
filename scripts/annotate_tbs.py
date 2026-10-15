import cv2
import tkinter as tk
from tkinter import ttk, messagebox
from PIL import Image, ImageTk
from pathlib import Path
import numpy as np

ROOT = Path(__file__).resolve().parent.parent
IMAGE_DIR = ROOT / "Fruitset"
MASK_DIR = ROOT / "annotations" / "masks"
MASK_DIR.mkdir(parents=True, exist_ok=True)

images = sorted(IMAGE_DIR.glob("*.png"))

class Annotator:
    def __init__(self, root):
        self.root = root
        self.root.title("Anotasi Mask TBS")
        self.root.geometry("1200x850")

        self.image_path = None
        self.original = None
        self.display = None
        self.tk_image = None

        self.points = []
        self.polygons = []
        self.scale = 1
        self.offset_x = 0
        self.offset_y = 0

        # PILIH GAMBAR
        top = tk.Frame(root)
        top.pack(fill="x", padx=10, pady=8)

        tk.Label(top, text="Pilih gambar TBS:",
                 font=("Arial", 11, "bold")).pack(side="left")

        self.combo = ttk.Combobox(
            top,
            values=[p.name for p in images],
            state="readonly",
            width=45
        )
        self.combo.pack(side="left", padx=10)
        self.combo.current(0)
        self.combo.bind("<<ComboboxSelected>>", self.change_image)

        # CANVAS
        self.canvas = tk.Canvas(root, bg="black")
        self.canvas.pack(fill="both", expand=True, padx=10)

        self.canvas.bind("<Button-1>", self.click_image)
        self.canvas.bind("<Configure>", lambda e: self.show_image())

        # TOMBOL
        bottom = tk.Frame(root)
        bottom.pack(fill="x", padx=10, pady=10)

        tk.Button(
            bottom, text="✓ SELESAI POLIGON",
            command=self.finish_polygon
        ).pack(side="left", padx=4)

        tk.Button(
            bottom, text="↶ UNDO TITIK",
            command=self.undo_point
        ).pack(side="left", padx=4)

        tk.Button(
            bottom, text="↶ UNDO POLIGON",
            command=self.undo_polygon
        ).pack(side="left", padx=4)

        tk.Button(
            bottom, text="🗑 BERSIHKAN",
            command=self.clear
        ).pack(side="left", padx=4)

        tk.Button(
            bottom, text="💾 SIMPAN MASK",
            command=self.save_mask
        ).pack(side="left", padx=4)

        tk.Button(
            bottom, text="✕ KELUAR",
            command=root.destroy
        ).pack(side="right", padx=4)

        self.load_image(images[0])

    def change_image(self, event=None):
        index = self.combo.current()

        if 0 <= index < len(images):
            self.load_image(images[index])

    def load_image(self, path):
        self.image_path = path

        self.original = cv2.imread(str(path))

        if self.original is None:
            messagebox.showerror(
                "Error",
                f"Gagal membuka:\n{path.name}"
            )
            return

        self.points = []
        self.polygons = []

        self.show_image()

    def show_image(self):
        if self.original is None:
            return

        h, w = self.original.shape[:2]

        canvas_w = max(self.canvas.winfo_width(), 400)
        canvas_h = max(self.canvas.winfo_height(), 400)

        self.scale = min(
            canvas_w / w,
            canvas_h / h
        )

        new_w = int(w * self.scale)
        new_h = int(h * self.scale)

        image = cv2.cvtColor(
            self.original,
            cv2.COLOR_BGR2RGB
        )

        image = cv2.resize(
            image,
            (new_w, new_h)
        )

        # gambar polygon sementara
        for polygon in self.polygons:
            pts = np.array([
                [
                    int(x * self.scale),
                    int(y * self.scale)
                ]
                for x, y in polygon
            ], dtype=np.int32)

            cv2.polylines(
                image,
                [pts],
                True,
                (255, 0, 0),
                3
            )

        # titik polygon aktif
        for x, y in self.points:
            cv2.circle(
                image,
                (
                    int(x * self.scale),
                    int(y * self.scale)
                ),
                5,
                (0, 255, 0),
                -1
            )

        self.display = Image.fromarray(image)
        self.tk_image = ImageTk.PhotoImage(self.display)

        self.canvas.delete("all")

        self.offset_x = (canvas_w - new_w) // 2
        self.offset_y = (canvas_h - new_h) // 2

        self.canvas.create_image(
            self.offset_x,
            self.offset_y,
            anchor="nw",
            image=self.tk_image
        )

    def click_image(self, event):
        if self.original is None:
            return

        x = (event.x - self.offset_x) / self.scale
        y = (event.y - self.offset_y) / self.scale

        h, w = self.original.shape[:2]

        if 0 <= x < w and 0 <= y < h:
            self.points.append((x, y))
            self.show_image()

    def finish_polygon(self):
        if len(self.points) < 3:
            messagebox.showwarning(
                "Peringatan",
                "Minimal 3 titik untuk membuat polygon."
            )
            return

        self.polygons.append(self.points.copy())
        self.points = []
        self.show_image()

    def undo_point(self):
        if self.points:
            self.points.pop()
            self.show_image()

    def undo_polygon(self):
        if self.polygons:
            self.polygons.pop()
            self.show_image()

    def clear(self):
        self.points = []
        self.polygons = []
        self.show_image()

    def save_mask(self):
        if not self.polygons:
            messagebox.showwarning(
                "Peringatan",
                "Belum ada polygon."
            )
            return

        h, w = self.original.shape[:2]

        mask = np.zeros(
            (h, w),
            dtype=np.uint8
        )

        for polygon in self.polygons:
            pts = np.array(
                polygon,
                dtype=np.int32
            )

            cv2.fillPoly(
                mask,
                [pts],
                255
            )

        output = MASK_DIR / (
            self.image_path.stem +
            "_mask_manual.png"
        )

        cv2.imwrite(
            str(output),
            mask
        )

        messagebox.showinfo(
            "Berhasil",
            f"Mask berhasil disimpan!\n\n{output.name}"
        )


root = tk.Tk()
app = Annotator(root)
root.mainloop()