import 'package:flutter/material.dart';

import '../models/analysis_result.dart';
import '../services/history_service.dart';

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final history = HistoryService.instance;

    return AnimatedBuilder(
      animation: history,
      builder: (context, _) {
        final latest = history.latest;

        return Scaffold(
          backgroundColor: const Color(0xFFF5F8F5),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(34, 30, 34, 50),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1180),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 28),
                      if (latest == null)
                        _buildEmpty()
                      else ...[
                        _buildReportHeader(latest),
                        const SizedBox(height: 22),
                        _buildQuickOverview(latest),
                        const SizedBox(height: 22),
                        _buildShapeReport(latest),
                        const SizedBox(height: 18),
                        _buildColorReport(latest),
                        const SizedBox(height: 18),
                        _buildMethodReport(),
                        const SizedBox(height: 18),
                        _buildResearchWarning(),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: const Color(0xFFE4F2E8),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.description_outlined,
            color: Color(0xFF176B3A),
            size: 27,
          ),
        ),
        const SizedBox(width: 16),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Reports',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.7,
                  color: Color(0xFF17221B),
                ),
              ),
              SizedBox(height: 5),
              Text(
                'Ringkasan hasil analisis untuk kebutuhan penelitian dan presentasi.',
                style: TextStyle(fontSize: 14, color: Color(0xFF747A76)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // REPORT HEADER
  // ============================================================

  Widget _buildReportHeader(AnalysisResult result) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(27),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF102B1E), Color(0xFF1E4E37)],
        ),
        borderRadius: BorderRadius.circular(23),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF102B1E).withValues(alpha: 0.12),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 66,
            height: 66,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: const Icon(
              Icons.description_outlined,
              color: Color(0xFFC2E8CE),
              size: 31,
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'PALMVISION ANALYSIS REPORT',
                  style: TextStyle(
                    fontSize: 10,
                    letterSpacing: 1.3,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFB8DEC4),
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  result.fileName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'AI-based TBS visual analysis',
                  style: TextStyle(fontSize: 12, color: Color(0xFFB5C8BC)),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF9ED8AE).withValues(alpha: 0.13),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF9ED8AE).withValues(alpha: 0.20),
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle_outline,
                  color: Color(0xFF9ED8AE),
                  size: 15,
                ),
                SizedBox(width: 6),
                Text(
                  'Analyzed',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFBDE8C8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // QUICK OVERVIEW
  // ============================================================

  Widget _buildQuickOverview(AnalysisResult result) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cards = [
          _overviewCard(
            icon: Icons.crop_free_rounded,
            title: 'Object Area',
            value: result.area.toStringAsFixed(0),
            unit: 'pixel²',
          ),
          _overviewCard(
            icon: Icons.swap_vert_rounded,
            title: 'Dimensions',
            value: '${result.width} × ${result.height}',
            unit: 'pixel',
          ),
          _overviewCard(
            icon: Icons.straighten_rounded,
            title: 'Aspect Ratio',
            value: result.aspectRatio.toStringAsFixed(3),
            unit: 'visual ratio',
          ),
          _overviewCard(
            icon: Icons.circle_outlined,
            title: 'Circularity',
            value: result.circularity.toStringAsFixed(3),
            unit: 'shape metric',
          ),
        ];

        if (constraints.maxWidth < 850) {
          return Column(
            children: [
              for (int i = 0; i < cards.length; i++) ...[
                cards[i],
                if (i != cards.length - 1) const SizedBox(height: 12),
              ],
            ],
          );
        }

        return Row(
          children: [
            for (int i = 0; i < cards.length; i++) ...[
              Expanded(child: cards[i]),
              if (i != cards.length - 1) const SizedBox(width: 13),
            ],
          ],
        );
      },
    );
  }

  Widget _overviewCard({
    required IconData icon,
    required String title,
    required String value,
    required String unit,
  }) {
    return Container(
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: const Color(0xFFE1E9E3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 13,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5EC),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: const Color(0xFF177746), size: 23),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF7A817C),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF17221B),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  unit,
                  style: const TextStyle(fontSize: 9, color: Color(0xFF9AA19C)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SHAPE
  // ============================================================

  Widget _buildShapeReport(AnalysisResult result) {
    return _reportCard(
      icon: Icons.crop_free_rounded,
      title: 'Shape Analysis',
      subtitle: 'Karakteristik geometris objek TBS hasil segmentasi.',
      child: Column(
        children: [
          _reportRow('Area', '${result.area.toStringAsFixed(0)} pixel²'),
          _reportRow('Width', '${result.width} pixel'),
          _reportRow('Height', '${result.height} pixel'),
          _reportRow('Aspect Ratio', result.aspectRatio.toStringAsFixed(3)),
          _reportRow(
            'Circularity',
            result.circularity.toStringAsFixed(3),
            isLast: true,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // COLOR
  // ============================================================

  Widget _buildColorReport(AnalysisResult result) {
    return _reportCard(
      icon: Icons.palette_outlined,
      title: 'Color Analysis',
      subtitle: 'Nilai rata-rata warna pada area TBS yang dianalisis.',
      child: Column(
        children: [
          _reportRow('HSV Hue', result.hMean.toStringAsFixed(2)),
          _reportRow('HSV Saturation', result.sMean.toStringAsFixed(2)),
          _reportRow('HSV Value', result.vMean.toStringAsFixed(2)),
          _reportRow('LAB L', result.lMean.toStringAsFixed(2)),
          _reportRow('LAB A', result.aMean.toStringAsFixed(2)),
          _reportRow('LAB B', result.bMean.toStringAsFixed(2), isLast: true),
        ],
      ),
    );
  }

  Widget _reportCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(21),
        border: Border.all(color: const Color(0xFFE2E9E4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 47,
                height: 47,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5EC),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: const Color(0xFF177746), size: 23),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF26352C),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF858D87),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 19),
          child,
        ],
      ),
    );
  }

  Widget _reportRow(String label, String value, {bool isLast = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 13),
      decoration: isLast
          ? null
          : const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFFEEF2EF))),
            ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 13, color: Color(0xFF69736C)),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF26352C),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // METHOD
  // ============================================================

  Widget _buildMethodReport() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F6F2),
        borderRadius: BorderRadius.circular(21),
        border: Border.all(color: const Color(0xFFDCE9DF)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.72),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.account_tree_outlined,
              color: Color(0xFF39845A),
              size: 23,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Analysis Method',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF26352C),
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  '1. Citra TBS diunggah melalui dashboard.\n'
                  '2. Small U-Net melakukan segmentasi objek TBS.\n'
                  '3. Mask hasil segmentasi digunakan untuk analisis bentuk.\n'
                  '4. Area objek digunakan sebagai region untuk analisis warna.\n'
                  '5. Hasil analisis ditampilkan pada dashboard dan history.',
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.7,
                    color: Color(0xFF59665D),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // RESEARCH WARNING
  // ============================================================

  Widget _buildResearchWarning() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E8),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEBD9A9)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.science_outlined, color: Color(0xFF9A7620), size: 22),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Catatan penelitian: hasil ini merupakan karakteristik '
              'visual citra TBS. Sistem belum digunakan untuk menentukan '
              'tingkat kematangan karena dataset belum memiliki label '
              'maturity. Nilai area juga berada dalam satuan pixel², '
              'bukan ukuran fisik dalam cm² atau berat dalam kg.',
              style: TextStyle(
                fontSize: 12,
                height: 1.55,
                color: Color(0xFF735F29),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // EMPTY
  // ============================================================

  Widget _buildEmpty() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 90),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2E9E4)),
      ),
      child: Column(
        children: [
          Container(
            width: 82,
            height: 82,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF5ED),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(
              Icons.description_outlined,
              size: 42,
              color: Color(0xFF7BA18A),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Belum Ada Report',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF26352C),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Lakukan analisis terlebih dahulu untuk menghasilkan report.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Color(0xFF858D87)),
          ),
        ],
      ),
    );
  }
}
