# Baseline Segmentation – U-Net

## 1. Tujuan

Eksperimen ini dilakukan untuk membangun baseline model segmentasi
objek Tandan Buah Segar (TBS) kelapa sawit menggunakan arsitektur
U-Net sederhana.

Objek yang disegmentasi adalah seluruh TBS yang terlihat pada citra,
bukan setiap buah secara individual.

---

## 2. Dataset Awal

Dataset awal terdiri dari 4 citra TBS.

Karakteristik dataset:

- Jumlah citra: 4
- Format: PNG
- Resolusi: 1600 × 1200 piksel
- Seluruh citra berasal dari TBS yang sama dengan beberapa sudut
  pengambilan gambar.

Mask manual digunakan sebagai ground truth.

Mask menggunakan format binary:

- 0 = background
- 255 = TBS

Dataset awal digunakan untuk membangun dan menguji pipeline awal
segmentasi.

Karena seluruh citra berasal dari TBS yang sama dan jumlah data
terbatas, hasil eksperimen ini belum digunakan sebagai bukti
generalisasi model terhadap TBS yang berbeda.

---

## 3. Pembagian Dataset

Untuk simulasi pipeline train/validation/test, dataset dibagi menjadi:

### Training

- Pic_20260923152205302.png
- Pic_20260923152208549.png

### Validation

- Pic_20260923152226022.png

### Test

- Pic_20260923152234998.png

Pembagian ini digunakan untuk menguji alur evaluasi dengan data yang
tidak digunakan dalam proses training.

Namun, karena keempat citra berasal dari TBS yang sama, pembagian ini
belum dapat dianggap sebagai pengujian generalisasi terhadap objek TBS
yang benar-benar berbeda.

---

## 4. Arsitektur Model

Model yang digunakan adalah U-Net sederhana (UNetSmall).

Komponen utama:

- Input RGB
- Encoder
- Max Pooling
- Bottleneck
- Decoder
- Transposed Convolution
- Skip Connection
- Output 1 channel untuk binary segmentation

Model digunakan sebagai baseline, bukan sebagai model final.

---

## 5. Konfigurasi Training

Parameter training:

- Device: CPU
- Ukuran input: 256 × 256 piksel
- Batch size: 1
- Epoch: 20
- Loss function: BCEWithLogitsLoss
- Optimizer: Adam
- Learning rate: 0.001
- Threshold prediksi: 0.5

Model baseline disimpan pada:

`models/experiments/baseline_segmentation/unet_small_split_baseline.pth`

---

## 6. Hasil Training

Hasil training pada epoch terakhir:

- Training Dice: 0.9552
- Validation Dice: 0.9531
- Loss: 0.0969

Validation Dice tertinggi selama training:

- Epoch: 18
- Validation Dice: 0.9637

Hasil validation hanya berasal dari satu citra sehingga nilainya harus
ditafsirkan sebagai hasil validasi awal.

---

## 7. Hasil Pengujian

Model diuji menggunakan satu citra yang tidak digunakan dalam proses
training.

Hasil pengujian:

| Metrik | Hasil |
|---|---:|
| IoU | 90.64% |
| Dice | 95.09% |
| Precision | 92.76% |
| Recall | 97.55% |

Citra test:

`Pic_20260923152234998.png`

---

## 8. Interpretasi Hasil

Hasil pengujian awal menunjukkan bahwa model mampu melakukan segmentasi
TBS dengan tingkat overlap yang tinggi terhadap ground truth pada citra
uji.

Nilai recall sebesar 97.55% menunjukkan bahwa sebagian besar area TBS
pada citra uji berhasil ditangkap oleh model.

Precision sebesar 92.76% menunjukkan bahwa masih terdapat sebagian area
background yang ikut diprediksi sebagai TBS.

Nilai IoU sebesar 90.64% dan Dice sebesar 95.09% menunjukkan kesesuaian
yang cukup tinggi antara hasil prediksi dan ground truth pada citra uji.

---

## 9. Visualisasi Error

Visualisasi hasil prediksi dibuat untuk memeriksa kesalahan segmentasi
secara visual.

Kategori error:

- Kuning = True Positive / area yang diprediksi benar
- Hijau = False Positive / background yang diprediksi sebagai TBS
- Merah = False Negative / bagian TBS yang tidak terdeteksi

Hasil visualisasi menunjukkan bahwa sebagian besar area TBS berhasil
diprediksi dengan benar.

Kesalahan terutama terlihat pada bagian tepi TBS dan sebagian kecil
area background.

File visualisasi:

`results/10_test_visualization/Pic_20260923152234998_comparison.png`

---

## 10. Keterbatasan Eksperimen

Eksperimen ini memiliki keterbatasan utama:

1. Dataset hanya terdiri dari 4 citra.
2. Keempat citra berasal dari TBS yang sama.
3. Dataset test hanya terdiri dari 1 citra.
4. Variasi objek dan kondisi pengambilan gambar masih terbatas.
5. Hasil pengujian belum dapat digunakan untuk menyatakan kemampuan
   generalisasi model terhadap TBS yang berbeda.

Oleh karena itu, hasil eksperimen ini diposisikan sebagai baseline dan
proof-of-concept pipeline segmentasi.

---

## 11. Tahap Pengembangan Berikutnya

Tahap berikutnya adalah memperoleh citra TBS dari data perusahaan
dengan variasi:

- ukuran TBS
- bentuk TBS
- sudut pengambilan
- jarak kamera
- pencahayaan
- kondisi background

Data tersebut kemudian akan dianotasi menggunakan mask manual dan
dibagi menjadi training, validation, dan test.

Model U-Net baseline selanjutnya dapat digunakan sebagai baseline
pembanding pada dataset yang lebih beragam.