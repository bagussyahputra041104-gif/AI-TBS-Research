# Eksperimen Segmentasi TBS Menggunakan GrabCut

## 1. Tujuan

Eksperimen GrabCut dilakukan sebagai pendekatan segmentasi awal
sebelum menggunakan model deep learning.

Metode ini digunakan untuk mengetahui sejauh mana segmentasi objek TBS
dapat dilakukan menggunakan pendekatan computer vision berbasis
foreground dan background tanpa proses training model.

---

## 2. Dataset

Eksperimen menggunakan 4 citra TBS yang tersedia pada dataset awal.

Karakteristik dataset:

- Jumlah citra: 4
- Format: PNG
- Resolusi: 1600 × 1200 piksel
- Seluruh citra berasal dari TBS yang sama dengan beberapa sudut
  pengambilan gambar.

Mask manual digunakan sebagai ground truth untuk mengevaluasi hasil
segmentasi GrabCut.

---

## 3. Ground Truth

Ground truth dibuat secara manual menggunakan anotasi polygon.

Objek yang dianotasi adalah seluruh TBS yang terlihat pada citra.

Bagian yang termasuk objek:

- badan TBS
- buah yang menyatu dengan TBS
- serabut atau bagian luar TBS yang terlihat
- tangkai apabila ditetapkan sebagai bagian objek

Background tidak termasuk dalam mask.

---

## 4. Eksperimen GrabCut

Beberapa konfigurasi GrabCut diuji untuk memperoleh segmentasi awal
yang lebih baik.

### GrabCut V1

Konfigurasi:

- Margin: 5%
- Iterasi GrabCut: 5

Hasil:

| Citra | IoU | Dice |
|---|---:|---:|
| Pic_20260923152205302 | 93.89% | 96.85% |
| Pic_20260923152208549 | 65.59% | 79.22% |
| Pic_20260923152226022 | 93.43% | 96.60% |
| Pic_20260923152234998 | 90.84% | 95.20% |
| **Mean** | **85.94%** | **91.97%** |

Hasil menunjukkan bahwa konfigurasi awal GrabCut dapat melakukan
segmentasi dengan baik pada beberapa citra, tetapi mengalami kesalahan
cukup besar pada citra tertentu.

Kesalahan utama terlihat pada area background di sisi objek.

---

## 5. GrabCut V2

Konfigurasi GrabCut kemudian diperbaiki dengan menggunakan:

- Margin: 12%
- Iterasi GrabCut: 7
- Operasi morphological processing

Hasil:

| Citra | IoU | Dice |
|---|---:|---:|
| Pic_20260923152205302 | 82.31% | 90.30% |
| Pic_20260923152208549 | 95.73% | 97.82% |
| Pic_20260923152226022 | 86.43% | 92.72% |
| Pic_20260923152234998 | 88.41% | 93.85% |
| **Mean** | **88.22%** | **93.67%** |

Perubahan konfigurasi meningkatkan hasil rata-rata dibandingkan
GrabCut V1.

Namun, terdapat penurunan pada beberapa citra sehingga perubahan
parameter tidak selalu menghasilkan peningkatan pada setiap citra.

---

## 6. GrabCut Refined

Eksperimen berikutnya menggunakan konfigurasi refined:

- Margin: 10%
- Iterasi GrabCut: 8
- Morphological processing
- Largest connected component

Hasil:

| Citra | IoU | Dice |
|---|---:|---:|
| Pic_20260923152205302 | 84.56% | 91.63% |
| Pic_20260923152208549 | 93.82% | 96.81% |
| Pic_20260923152226022 | 88.67% | 93.99% |
| Pic_20260923152234998 | 88.41% | 93.85% |
| **Mean** | **88.86%** | **94.07%** |

Konfigurasi refined menghasilkan mean IoU dan mean Dice tertinggi dari
seluruh eksperimen GrabCut.

---

## 7. Perbandingan GrabCut

| Metode | Mean IoU | Mean Dice |
|---|---:|---:|
| GrabCut V1 | 85.94% | 91.97% |
| GrabCut V2 | 88.22% | 93.67% |
| GrabCut Refined | **88.86%** | **94.07%** |

GrabCut Refined memberikan hasil terbaik pada dataset awal berdasarkan
mean IoU dan mean Dice.

---

## 8. Error Analysis

Analisis kesalahan dilakukan dengan membandingkan hasil segmentasi
GrabCut terhadap ground truth manual.

Kategori kesalahan:

- True Positive (TP): area TBS yang berhasil disegmentasi
- False Positive (FP): background yang salah dianggap sebagai TBS
- False Negative (FN): bagian TBS yang tidak berhasil disegmentasi

Pada GrabCut V1, citra
Pic_20260923152208549.png menunjukkan False Positive yang cukup besar
pada area background di sisi TBS.

Pada citra lainnya, kesalahan lebih banyak terlihat pada bagian tepi,
serabut, dan area sekitar tangkai.

---

## 9. Interpretasi

Eksperimen menunjukkan bahwa GrabCut dapat digunakan sebagai metode
segmentasi awal untuk memisahkan TBS dari background.

Namun, performanya sensitif terhadap konfigurasi dan kondisi citra.
Perubahan margin dan jumlah iterasi dapat meningkatkan hasil pada
sebagian citra tetapi juga menurunkan hasil pada citra lainnya.

Hal ini menunjukkan keterbatasan pendekatan berbasis segmentasi klasik
ketika kondisi objek dan background berubah.

---

## 10. Keterbatasan

Eksperimen GrabCut memiliki keterbatasan:

1. Dataset hanya terdiri dari 4 citra.
2. Keempat citra berasal dari TBS yang sama.
3. Kondisi objek dan background masih terbatas.
4. Parameter GrabCut perlu disesuaikan terhadap kondisi citra tertentu.
5. Hasil eksperimen belum dapat digunakan untuk menyatakan kemampuan
   generalisasi terhadap TBS yang berbeda.

Oleh karena itu, eksperimen GrabCut diposisikan sebagai baseline
computer vision klasik dan pembanding terhadap pendekatan deep
learning.

---

## 11. Kesimpulan Sementara

Pada dataset awal, konfigurasi GrabCut Refined menghasilkan performa
terbaik dengan:

- Mean IoU: 88.86%
- Mean Dice: 94.07%

Hasil tersebut menunjukkan bahwa GrabCut mampu menghasilkan segmentasi
TBS yang cukup baik pada dataset awal.

Namun, karena dataset masih terbatas dan berasal dari satu TBS,
diperlukan dataset yang lebih beragam untuk mengevaluasi kemampuan
generalisasi metode secara lebih kuat.