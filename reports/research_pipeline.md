# Research Pipeline – Segmentasi TBS

## 1. Tujuan Sistem

Sistem dirancang untuk melakukan segmentasi objek Tandan Buah Segar
(TBS) kelapa sawit dari citra kamera.

Output utama sistem adalah mask yang memisahkan objek TBS dari
background.

---

## 2. Input Sistem

Input berupa citra TBS yang diperoleh menggunakan kamera.

Citra dapat memiliki variasi:

- ukuran TBS
- jarak kamera
- sudut pengambilan
- pencahayaan
- background
- bentuk TBS

---

## 3. Proses Penelitian

Pipeline penelitian terdiri dari beberapa tahap:

```text
Citra TBS
   ↓
Dataset Audit
   ↓
Preprocessing
   ↓
Ground Truth Annotation
   ↓
Baseline GrabCut
   ↓
Training U-Net
   ↓
Validation
   ↓
Test
   ↓
Prediction
   ↓
Error Analysis
   ↓
Evaluasi