# Error Analysis – Segmentasi TBS

## 1. Tujuan

Error analysis dilakukan untuk mengetahui jenis kesalahan yang terjadi
pada proses segmentasi TBS.

Analisis dilakukan dengan membandingkan hasil prediksi terhadap
ground truth manual.

Tujuan utama analisis adalah mengetahui bagian objek yang berhasil
disegmentasi, bagian objek yang terlewat, serta background yang salah
dianggap sebagai objek.

---

## 2. Kategori Kesalahan

Kesalahan segmentasi dibagi menjadi tiga kategori utama:

### True Positive (TP)

Area TBS yang terdapat pada ground truth dan berhasil diprediksi
sebagai TBS.

### False Positive (FP)

Area background yang salah diprediksi sebagai TBS.

### False Negative (FN)

Area TBS yang terdapat pada ground truth tetapi tidak berhasil
diprediksi oleh model.

---

## 3. Error Analysis GrabCut

### GrabCut V1

GrabCut V1 menghasilkan mean IoU sebesar 85.94% dan mean Dice sebesar
91.97%.

Kesalahan paling besar ditemukan pada citra:

`Pic_20260923152208549.png`

Pada citra tersebut terdapat area background di sisi objek yang ikut
tersegmentasi sebagai TBS sehingga menghasilkan False Positive yang
cukup besar.

Pada citra lainnya, kesalahan lebih banyak terdapat pada bagian tepi
objek, serabut, dan sekitar tangkai.

---

## 4. GrabCut V2

GrabCut V2 menghasilkan:

- Mean IoU: 88.22%
- Mean Dice: 93.67%

Perubahan konfigurasi berhasil meningkatkan performa rata-rata
dibandingkan GrabCut V1.

Namun, peningkatan tersebut tidak terjadi secara konsisten pada setiap
citra.

Hal ini menunjukkan bahwa hasil GrabCut cukup sensitif terhadap
perubahan parameter dan kondisi visual citra.

---

## 5. GrabCut Refined

GrabCut Refined menghasilkan:

- Mean IoU: 88.86%
- Mean Dice: 94.07%

Konfigurasi ini menghasilkan performa terbaik di antara tiga
eksperimen GrabCut.

Penggunaan morphological processing dan largest connected component
membantu mengurangi komponen background yang tidak berhubungan dengan
objek utama.

Namun, kesalahan pada bagian tepi dan detail serabut masih dapat
ditemukan.

---

## 6. Error Analysis U-Net

Pada pengujian awal menggunakan satu citra test,
U-Net menghasilkan:

- IoU: 90.64%
- Dice: 95.09%
- Precision: 92.76%
- Recall: 97.55%

Visualisasi prediksi menunjukkan bahwa sebagian besar area TBS berhasil
ditangkap oleh model.

Area True Positive mendominasi bagian utama objek.

False Negative terutama terlihat pada beberapa bagian tepi TBS dan
detail serabut yang lebih kecil.

False Positive terlihat pada sebagian kecil area background yang ikut
diprediksi sebagai TBS.

---

## 7. Perbandingan Jenis Error

Secara umum, terdapat pola kesalahan yang sama pada pendekatan
GrabCut dan U-Net, yaitu:

- kesalahan pada batas objek
- bagian serabut yang sulit dipisahkan dari background
- area sekitar tangkai
- sebagian kecil background yang memiliki karakteristik visual mirip
  dengan TBS

Perbedaan utama adalah U-Net mempelajari pola visual dari data training,
sedangkan GrabCut bergantung pada proses pemisahan foreground dan
background berdasarkan citra.

---

## 8. Visualisasi

Visualisasi error digunakan untuk membantu interpretasi hasil metrik.

Pada visualisasi:

- Kuning = True Positive
- Hijau = False Positive
- Merah = False Negative

Visualisasi U-Net tersedia pada:

`results/10_test_visualization/Pic_20260923152234998_comparison.png`

Visualisasi GrabCut tersedia pada folder hasil eksperimen GrabCut.

---

## 9. Interpretasi

Kesalahan segmentasi paling penting berada pada boundary objek.

Hal ini menunjukkan bahwa mendeteksi area utama TBS relatif lebih mudah
dibandingkan mempertahankan detail bagian luar seperti serabut dan
batas tipis objek.

Karena tujuan penelitian adalah memperoleh segmentasi seluruh TBS yang
terlihat, termasuk bagian luar yang ditetapkan sebagai bagian objek,
boundary menjadi salah satu aspek penting dalam evaluasi.

---

## 10. Keterbatasan Analisis

Analisis error saat ini masih menggunakan dataset yang sangat terbatas.

Dataset terdiri dari 4 citra yang berasal dari TBS yang sama.

Oleh karena itu, pola error yang ditemukan belum dapat dianggap
mewakili seluruh variasi kondisi TBS.

Analisis yang lebih kuat akan dilakukan setelah tersedia data TBS yang
lebih beragam dari perusahaan.

---

## 11. Kesimpulan

Eksperimen menunjukkan bahwa kesalahan segmentasi terutama terjadi
pada boundary objek, serabut, tangkai, dan sebagian kecil background.

GrabCut Refined menghasilkan performa terbaik di antara konfigurasi
GrabCut dengan mean IoU 88.86% dan mean Dice 94.07%.

U-Net menghasilkan IoU 90.64% dan Dice 95.09% pada satu citra test
awal.

Hasil tersebut menunjukkan bahwa pipeline segmentasi telah berhasil
dibangun, tetapi pengujian pada dataset yang lebih beragam masih
diperlukan untuk mengevaluasi kemampuan generalisasi model.