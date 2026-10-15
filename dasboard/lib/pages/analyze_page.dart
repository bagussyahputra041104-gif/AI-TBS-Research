import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../models/analysis_result.dart';
import '../services/api_service.dart';
import '../services/history_service.dart';
import '../widgets/histogram_chart.dart';
import '../widgets/metric_card.dart';

class AnalyzePage extends StatefulWidget {
  const AnalyzePage({super.key});

  @override
  State<AnalyzePage> createState() => _AnalyzePageState();
}

class _AnalyzePageState extends State<AnalyzePage> {
  Uint8List? imageBytes;
  String? fileName;
  AnalysisResult? result;

  bool loading = false;
  String? error;

  Future<void> _pickImage() async {
    try {
      final file = await FilePicker.pickFile(type: FileType.image);

      if (file == null) return;

      final bytes = await file.readAsBytes();

      setState(() {
        imageBytes = bytes;
        fileName = file.name;
        result = null;
        error = null;
      });
    } catch (e) {
      setState(() {
        error = 'Gagal memilih gambar: $e';
      });
    }
  }

  Future<void> _analyze() async {
    if (imageBytes == null || fileName == null) return;

    setState(() {
      loading = true;
      error = null;
      result = null;
    });

    try {
      final analysis = await ApiService.analyzeImage(
        bytes: imageBytes!,
        fileName: fileName!,
      );

      HistoryService.instance.add(analysis);

      setState(() {
        result = analysis;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  void _clear() {
    setState(() {
      imageBytes = null;
      fileName = null;
      result = null;
      error = null;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8F5),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(34, 30, 34, 50),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1380),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 28),
                  _buildWorkspace(),
                  if (error != null) ...[
                    const SizedBox(height: 18),
                    _buildError(),
                  ],
                  if (loading) ...[const SizedBox(height: 22), _buildLoading()],
                  if (result != null && !loading) ...[
                    const SizedBox(height: 34),
                    _buildResultHeader(),
                    const SizedBox(height: 18),
                    _buildImages(),
                    const SizedBox(height: 32),
                    _buildShapeSection(),
                    const SizedBox(height: 32),
                    _buildColorSection(),
                    const SizedBox(height: 32),
                    _buildInsight(),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Analyze TBS',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.7,
                  color: Color(0xFF17221B),
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Upload citra TBS dan jalankan analisis computer vision.',
                style: TextStyle(fontSize: 14, color: Color(0xFF747A76)),
              ),
            ],
          ),
        ),
        _headerStatus(),
      ],
    );
  }

  Widget _headerStatus() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF5ED),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFD4E8DA)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, size: 8, color: Color(0xFF3FA766)),
          SizedBox(width: 7),
          Text(
            'AI Engine Ready',
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: Color(0xFF33784D),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkspace() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE1E8E3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        children: [
          if (imageBytes == null)
            _buildEmptyUpload()
          else
            _buildSelectedImage(),
          const SizedBox(height: 20),
          _buildActionBar(),
        ],
      ),
    );
  }

  Widget _buildEmptyUpload() {
    return Container(
      width: double.infinity,
      height: 300,
      decoration: BoxDecoration(
        color: const Color(0xFFF8FBF9),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFD2E2D7), width: 1.4),
      ),
      child: InkWell(
        onTap: loading ? null : _pickImage,
        borderRadius: BorderRadius.circular(18),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _UploadIcon(),
            SizedBox(height: 18),
            Text(
              'Upload citra TBS',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w700,
                color: Color(0xFF26352C),
              ),
            ),
            SizedBox(height: 7),
            Text(
              'PNG, JPG atau JPEG',
              style: TextStyle(fontSize: 13, color: Color(0xFF858D87)),
            ),
            SizedBox(height: 5),
            Text(
              'Klik area ini untuk memilih gambar',
              style: TextStyle(fontSize: 12, color: Color(0xFFA0A7A2)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedImage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 390,
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFFF1F4F2),
            borderRadius: BorderRadius.circular(17),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(17),
            child: Image.memory(imageBytes!, fit: BoxFit.contain),
          ),
        ),
        const SizedBox(height: 13),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFF7FAF8),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE3EBE5)),
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5EC),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const Icon(
                  Icons.image_outlined,
                  size: 17,
                  color: Color(0xFF39845A),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  fileName ?? 'Selected image',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF354139),
                  ),
                ),
              ),
              const Icon(
                Icons.check_circle_rounded,
                size: 16,
                color: Color(0xFF45A466),
              ),
              const SizedBox(width: 6),
              const Text(
                'Ready',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF43865A),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionBar() {
    return Row(
      children: [
        OutlinedButton.icon(
          onPressed: loading ? null : _pickImage,
          icon: const Icon(Icons.upload_file_rounded, size: 18),
          label: Text(imageBytes == null ? 'Pilih Gambar' : 'Ganti Gambar'),
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF176B3D),
            side: const BorderSide(color: Color(0xFFBFDAC8)),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const Spacer(),
        if (imageBytes != null) ...[
          TextButton.icon(
            onPressed: loading ? null : _clear,
            icon: const Icon(Icons.delete_outline_rounded, size: 18),
            label: const Text('Clear'),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF8B625D),
            ),
          ),
          const SizedBox(width: 8),
          FilledButton.icon(
            onPressed: loading ? null : _analyze,
            icon: const Icon(Icons.auto_awesome, size: 18),
            label: const Text('Analyze with AI'),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF176B3D),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 21, vertical: 13),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildError() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4F3),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF1C8C4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline_rounded, color: Color(0xFFC4483D)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              error!,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF8F332C),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E9E4)),
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 30,
            height: 30,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: Color(0xFF176B3D),
            ),
          ),
          const SizedBox(width: 17),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI sedang menganalisis citra...',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF26352C),
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Melakukan segmentasi TBS dan menghitung karakteristik visual.',
                  style: TextStyle(fontSize: 12, color: Color(0xFF858D87)),
                ),
              ],
            ),
          ),
          const Text(
            'Processing',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF39845A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultHeader() {
    return Row(
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Analysis Result',
                style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF17221B),
                ),
              ),
              SizedBox(height: 5),
              Text(
                'Hasil segmentasi dan analisis karakteristik visual TBS.',
                style: TextStyle(fontSize: 13, color: Color(0xFF7A817C)),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F6ED),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFD2E8D9)),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.check_circle_outline,
                size: 16,
                color: Color(0xFF167A45),
              ),
              SizedBox(width: 6),
              Text(
                'Analysis Complete',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF167A45),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImages() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final stacked = constraints.maxWidth < 760;

        final original = _imageCard(
          title: 'Original Image',
          subtitle: fileName ?? 'Input image',
          badge: 'INPUT',
          badgeColor: const Color(0xFF6C8174),
          child: Image.memory(imageBytes!, fit: BoxFit.contain),
        );

        final mask = _imageCard(
          title: 'AI Segmentation',
          subtitle: 'Small U-Net output',
          badge: 'MASK',
          badgeColor: const Color(0xFF39845A),
          child: Image.memory(result!.maskBytes, fit: BoxFit.contain),
        );

        if (stacked) {
          return Column(children: [original, const SizedBox(height: 16), mask]);
        }

        return Row(
          children: [
            Expanded(child: original),
            const SizedBox(width: 16),
            Expanded(child: mask),
          ],
        );
      },
    );
  }

  Widget _imageCard({
    required String title,
    required String subtitle,
    required String badge,
    required Color badgeColor,
    required Widget child,
  }) {
    return Container(
      height: 350,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E9E4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF26352C),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF909791),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Text(
                  badge,
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    color: badgeColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(13),
              child: Container(
                width: double.infinity,
                color: const Color(0xFFF4F6F4),
                child: child,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShapeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(
          'Shape Analysis',
          'Karakteristik geometris objek TBS hasil segmentasi.',
        ),
        const SizedBox(height: 15),
        LayoutBuilder(
          builder: (context, constraints) {
            final cards = [
              MetricCard(
                title: 'Area',
                value: result!.area.toStringAsFixed(0),
                subtitle: 'pixel²',
                icon: Icons.area_chart_outlined,
              ),
              MetricCard(
                title: 'Width',
                value: result!.width.toString(),
                subtitle: 'pixel',
                icon: Icons.swap_horiz_rounded,
              ),
              MetricCard(
                title: 'Height',
                value: result!.height.toString(),
                subtitle: 'pixel',
                icon: Icons.height_rounded,
              ),
              MetricCard(
                title: 'Aspect Ratio',
                value: result!.aspectRatio.toStringAsFixed(3),
                subtitle: 'width / height',
                icon: Icons.crop_free_rounded,
              ),
              MetricCard(
                title: 'Circularity',
                value: result!.circularity.toStringAsFixed(3),
                subtitle: 'shape metric',
                icon: Icons.circle_outlined,
              ),
            ];

            if (constraints.maxWidth < 850) {
              return Column(
                children: [
                  for (var i = 0; i < cards.length; i++) ...[
                    cards[i],
                    if (i != cards.length - 1) const SizedBox(height: 12),
                  ],
                ],
              );
            }

            return Wrap(
              spacing: 14,
              runSpacing: 14,
              children: cards
                  .map(
                    (card) => SizedBox(
                      width: (constraints.maxWidth - 28) / 3,
                      child: card,
                    ),
                  )
                  .toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildColorSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(
          'Color Analysis',
          'Nilai rata-rata warna pada area TBS yang tersegmentasi.',
        ),
        const SizedBox(height: 15),
        LayoutBuilder(
          builder: (context, constraints) {
            final cards = [
              MetricCard(
                title: 'HSV — Hue',
                value: result!.hMean.toStringAsFixed(2),
                subtitle: 'OpenCV scale',
                icon: Icons.palette_outlined,
              ),
              MetricCard(
                title: 'HSV — Saturation',
                value: result!.sMean.toStringAsFixed(2),
                subtitle: '0–255',
                icon: Icons.opacity_outlined,
              ),
              MetricCard(
                title: 'HSV — Value',
                value: result!.vMean.toStringAsFixed(2),
                subtitle: '0–255',
                icon: Icons.brightness_6_outlined,
              ),
              MetricCard(
                title: 'LAB — L',
                value: result!.lMean.toStringAsFixed(2),
                subtitle: 'OpenCV encoding',
                icon: Icons.light_mode_outlined,
              ),
              MetricCard(
                title: 'LAB — A',
                value: result!.aMean.toStringAsFixed(2),
                subtitle: 'OpenCV encoding',
                icon: Icons.colorize_outlined,
              ),
              MetricCard(
                title: 'LAB — B',
                value: result!.bMean.toStringAsFixed(2),
                subtitle: 'OpenCV encoding',
                icon: Icons.gradient_outlined,
              ),
            ];

            if (constraints.maxWidth < 850) {
              return Column(
                children: [
                  for (var i = 0; i < cards.length; i++) ...[
                    cards[i],
                    if (i != cards.length - 1) const SizedBox(height: 12),
                  ],
                ],
              );
            }

            return Wrap(
              spacing: 14,
              runSpacing: 14,
              children: cards
                  .map(
                    (card) => SizedBox(
                      width: (constraints.maxWidth - 28) / 3,
                      child: card,
                    ),
                  )
                  .toList(),
            );
          },
        ),
        const SizedBox(height: 20),
        _buildHistogram(),
      ],
    );
  }

  Widget _buildHistogram() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E9E4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Color Distribution',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF26352C),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Distribusi nilai channel pada area TBS yang tersegmentasi.',
            style: TextStyle(fontSize: 12, color: Color(0xFF8A918C)),
          ),
          const SizedBox(height: 20),
          HistogramChart(
            title: 'HSV Hue',
            values: result!.histogram['h'] ?? [],
          ),
          const SizedBox(height: 22),
          HistogramChart(
            title: 'HSV Saturation',
            values: result!.histogram['s'] ?? [],
          ),
          const SizedBox(height: 22),
          HistogramChart(
            title: 'HSV Value',
            values: result!.histogram['v'] ?? [],
          ),
        ],
      ),
    );
  }

  Widget _buildInsight() {
    final circularity = result!.circularity;
    final aspect = result!.aspectRatio;

    String shapeText;

    if (circularity >= 0.7) {
      shapeText =
          'Objek memiliki bentuk yang relatif mendekati '
          'lingkaran berdasarkan nilai circularity.';
    } else if (circularity >= 0.5) {
      shapeText =
          'Objek menunjukkan bentuk yang cukup kompak, '
          'namun masih memiliki variasi kontur.';
    } else {
      shapeText =
          'Objek memiliki kontur yang relatif tidak beraturan '
          'berdasarkan nilai circularity.';
    }

    String ratioText;

    if (aspect > 1.2) {
      ratioText = 'Orientasi visual objek cenderung melebar secara horizontal.';
    } else if (aspect < 0.83) {
      ratioText = 'Orientasi visual objek cenderung memanjang secara vertikal.';
    } else {
      ratioText = 'Dimensi objek relatif seimbang antara lebar dan tinggi.';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(23),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF142D21), Color(0xFF1C4933)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: Color(0xFFBCE8CB),
              size: 23,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'AI Insight',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Visual characteristic summary',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.55),
                    fontSize: 10.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            flex: 5,
            child: Text(
              '$shapeText $ratioText '
              'Hasil ini merupakan analisis karakteristik visual '
              'dan tidak digunakan untuk menentukan tingkat '
              'kematangan TBS secara langsung.',
              style: const TextStyle(
                color: Color(0xFFC0D1C6),
                fontSize: 12,
                height: 1.55,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.w700,
            color: Color(0xFF17221B),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(fontSize: 13, color: Color(0xFF7A817C)),
        ),
      ],
    );
  }
}

class _UploadIcon extends StatelessWidget {
  const _UploadIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5EC),
        borderRadius: BorderRadius.circular(21),
      ),
      child: const Icon(
        Icons.add_photo_alternate_outlined,
        size: 38,
        color: Color(0xFF4A9166),
      ),
    );
  }
}
