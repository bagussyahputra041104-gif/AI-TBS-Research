# Dataset Protocol – Segmentasi TBS

## 1. Tujuan

Dataset digunakan untuk penelitian segmentasi objek Tandan Buah Segar (TBS)
kelapa sawit menggunakan computer vision.

## 2. Objek yang Dianotasi

Objek utama adalah seluruh TBS yang terlihat pada citra.

Bagian yang termasuk objek:
- badan TBS
- buah yang menyatu dengan TBS
- serabut/ujung luar yang merupakan bagian dari TBS
- tangkai apabila terlihat dan ditetapkan sebagai bagian objek penelitian

Background tidak termasuk objek.

## 3. Format Mask

Mask menggunakan format binary:
- 0 = background
- 255 = TBS

Ukuran mask harus sama dengan ukuran gambar aslinya.

## 4. Variasi Data

Dataset diusahakan memiliki variasi:
- sudut pengambilan gambar
- jarak kamera
- ukuran TBS dalam citra
- pencahayaan
- kondisi background
- bentuk dan ukuran TBS

## 5. Pembagian Dataset

Dataset akhir akan dibagi menjadi:
- Training
- Validation
- Test

Data test tidak boleh digunakan selama proses training.

## 6. Ground Truth

Mask manual digunakan sebagai ground truth untuk evaluasi model.

## 7. Metrik Evaluasi

Model akan dievaluasi menggunakan:
- IoU (Intersection over Union)
- Dice Score
- Precision
- Recall

## 8. Catatan

Dataset awal yang tersedia digunakan untuk membangun dan menguji
pipeline awal. Dataset tambahan dari perusahaan digunakan untuk
pengujian kemampuan generalisasi model pada data yang belum pernah
dilihat sebelumnya.