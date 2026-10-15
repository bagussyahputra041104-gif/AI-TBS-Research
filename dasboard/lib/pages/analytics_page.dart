import 'package:flutter/material.dart';

import '../models/analysis_result.dart';
import '../services/history_service.dart';

class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({super.key});

  static const _background = Color(0xFFF5F8F5);
  static const _text = Color(0xFF17221B);
  static const _muted = Color(0xFF747A76);
  static const _green = Color(0xFF176B3D);
  static const _border = Color(0xFFE2E9E4);

  @override
  Widget build(BuildContext context) {
    final history = HistoryService.instance;

    return AnimatedBuilder(
      animation: history,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: _background,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(34, 30, 34, 50),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1380),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _header(history),
                      const SizedBox(height: 28),
                      _overview(history),
                      const SizedBox(height: 30),
                      _shapeOverview(history),
                      const SizedBox(height: 30),
                      _latestResult(history),
                      const SizedBox(height: 30),
                      _historyTable(history),
                      const SizedBox(height: 30),
                      _researchNote(),
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

  Widget _header(HistoryService history) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5F3E9),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.insights_rounded,
                      color: _green,
                      size: 23,
                    ),
                  ),
                  const SizedBox(width: 13),
                  const Text(
                    'Analytics',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.7,
                      color: _text,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 9),
              const Text(
                'Ringkasan statistik dan karakteristik visual dari hasil analisis TBS.',
                style: TextStyle(fontSize: 14, color: _muted),
              ),
            ],
          ),
        ),
        const SizedBox(width: 20),
        if (history.count > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle_outline_rounded,
                  size: 17,
                  color: _green,
                ),
                const SizedBox(width: 7),
                Text(
                  '${history.count} Analysis',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF405047),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _overview(HistoryService history) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cards = [
          _metric(
            icon: Icons.analytics_outlined,
            title: 'Total Analysis',
            value: history.count.toString(),
            subtitle: 'citra telah dianalisis',
          ),
          _metric(
            icon: Icons.area_chart_outlined,
            title: 'Average Area',
            value: history.averageArea.toStringAsFixed(0),
            subtitle: 'pixel²',
          ),
          _metric(
            icon: Icons.circle_outlined,
            title: 'Average Circularity',
            value: history.averageCircularity.toStringAsFixed(3),
            subtitle: 'shape metric',
          ),
          _metric(
            icon: Icons.crop_free_rounded,
            title: 'Average Aspect Ratio',
            value: history.averageAspectRatio.toStringAsFixed(3),
            subtitle: 'width / height',
          ),
        ];

        if (constraints.maxWidth < 820) {
          return Column(
            children: [
              for (var i = 0; i < cards.length; i++) ...[
                cards[i],
                if (i != cards.length - 1) const SizedBox(height: 12),
              ],
            ],
          );
        }

        return Row(
          children: [
            for (var i = 0; i < cards.length; i++) ...[
              Expanded(child: cards[i]),
              if (i != cards.length - 1) const SizedBox(width: 14),
            ],
          ],
        );
      },
    );
  }

  Widget _metric({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
  }) {
    return Container(
      height: 138,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5EC),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: _green, size: 25),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF727A75),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  value,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w700,
                    color: _text,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF969D98),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _shapeOverview(HistoryService history) {
    final hasData = history.count > 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(21),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 14,
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
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF5ED),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.shape_line_rounded,
                  color: _green,
                  size: 21,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Shape Analysis Overview',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF26352C),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Rata-rata karakteristik geometris dari hasil segmentasi.',
                      style: TextStyle(fontSize: 12, color: Color(0xFF858D87)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 25),
          if (!hasData)
            _shapeEmpty()
          else
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 650) {
                  return Column(
                    children: [
                      _shapeMetricCard(
                        label: 'Circularity',
                        value: history.averageCircularity,
                        display: history.averageCircularity.toStringAsFixed(3),
                        icon: Icons.circle_outlined,
                      ),
                      const SizedBox(height: 14),
                      _shapeMetricCard(
                        label: 'Aspect Ratio',
                        value: _aspectProgress(history.averageAspectRatio),
                        display: history.averageAspectRatio.toStringAsFixed(3),
                        icon: Icons.crop_free_rounded,
                      ),
                    ],
                  );
                }

                return Row(
                  children: [
                    Expanded(
                      child: _shapeMetricCard(
                        label: 'Circularity',
                        value: history.averageCircularity,
                        display: history.averageCircularity.toStringAsFixed(3),
                        icon: Icons.circle_outlined,
                      ),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: _shapeMetricCard(
                        label: 'Aspect Ratio',
                        value: _aspectProgress(history.averageAspectRatio),
                        display: history.averageAspectRatio.toStringAsFixed(3),
                        icon: Icons.crop_free_rounded,
                      ),
                    ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _shapeMetricCard({
    required String label,
    required double value,
    required String display,
    required IconData icon,
  }) {
    final normalized = value.clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FBF9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5ECE7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: _green),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF344039),
                  ),
                ),
              ),
              Text(
                display,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: _green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: normalized,
              minHeight: 8,
              backgroundColor: const Color(0xFFE3EBE5),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF39845A),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label == 'Circularity'
                ? 'Indikator kekompakan bentuk objek.'
                : 'Perbandingan lebar terhadap tinggi.',
            style: const TextStyle(fontSize: 10, color: Color(0xFF8A948E)),
          ),
        ],
      ),
    );
  }

  Widget _shapeEmpty() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FBF9),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFE5ECE7)),
      ),
      child: const Row(
        children: [
          Icon(Icons.insights_outlined, color: Color(0xFF77A288), size: 22),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Belum ada data shape. Jalankan analisis pada halaman Analyze terlebih dahulu.',
              style: TextStyle(fontSize: 12, color: Color(0xFF68756D)),
            ),
          ),
        ],
      ),
    );
  }

  double _aspectProgress(double value) {
    if (value <= 0) return 0;

    final distance = (value - 1).abs();

    return (1 - distance / 2).clamp(0.0, 1.0);
  }

  Widget _latestResult(HistoryService history) {
    final latest = history.latest;

    if (latest == null) {
      return _emptyCard(
        icon: Icons.auto_awesome_outlined,
        title: 'Belum Ada Analisis',
        subtitle: 'Lakukan analisis pada halaman Analyze untuk melihat hasil terbaru.',
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(23),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF142D21), Color(0xFF1D4A34)],
        ),
        borderRadius: BorderRadius.circular(21),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF142D21).withValues(alpha: 0.12),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final metrics = [
            _darkMetric('Area', latest.area.toStringAsFixed(0)),
            _darkMetric('Circularity', latest.circularity.toStringAsFixed(3)),
            _darkMetric('Aspect', latest.aspectRatio.toStringAsFixed(3)),
          ];

          if (constraints.maxWidth < 700) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _latestTitle(latest),
                const SizedBox(height: 22),
                Wrap(spacing: 28, runSpacing: 16, children: metrics),
              ],
            );
          }

          return Row(
            children: [
              Expanded(child: _latestTitle(latest)),
              const SizedBox(width: 25),
              for (var i = 0; i < metrics.length; i++) ...[
                metrics[i],
                if (i != metrics.length - 1) const SizedBox(width: 30),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _latestTitle(AnalysisResult latest) {
    return Row(
      children: [
        Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(17),
          ),
          child: const Icon(
            Icons.auto_awesome,
            color: Color(0xFFBCE8CB),
            size: 27,
          ),
        ),
        const SizedBox(width: 17),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Latest Analysis',
                style: TextStyle(
                  color: Color(0xFFBCE8CB),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                latest.fileName,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _darkMetric(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: Color(0xFF9CB9A7)),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _historyTable(HistoryService history) {
    if (history.items.isEmpty) {
      return _emptyCard(
        icon: Icons.table_chart_outlined,
        title: 'Analysis History Kosong',
        subtitle: 'Hasil analisis akan muncul di sini setelah proses selesai.',
      );
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(21),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(23, 21, 23, 18),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Analysis Summary',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF26352C),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Ringkasan seluruh citra yang telah dianalisis.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF858D87),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF5ED),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${history.items.length} Records',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: _green,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE9EEEA)),
          ...history.items.map(_historyRow),
        ],
      ),
    );
  }

  Widget _historyRow(AnalysisResult item) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFEEF2EF))),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 720) {
            return _compactHistoryRow(item);
          }

          return Row(
            children: [
              _fileIcon(),
              const SizedBox(width: 14),
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.fileName,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF344039),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Segmentation analysis completed',
                      style: TextStyle(fontSize: 10, color: Color(0xFF969D98)),
                    ),
                  ],
                ),
              ),
              _tableValue('Area', item.area.toStringAsFixed(0)),
              _tableValue('Circularity', item.circularity.toStringAsFixed(3)),
              _tableValue('Aspect', item.aspectRatio.toStringAsFixed(3)),
            ],
          );
        },
      ),
    );
  }

  Widget _compactHistoryRow(AnalysisResult item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _fileIcon(),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                item.fileName,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF344039),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 24,
          runSpacing: 12,
          children: [
            _tableValue('Area', item.area.toStringAsFixed(0), compact: true),
            _tableValue(
              'Circularity',
              item.circularity.toStringAsFixed(3),
              compact: true,
            ),
            _tableValue(
              'Aspect',
              item.aspectRatio.toStringAsFixed(3),
              compact: true,
            ),
          ],
        ),
      ],
    );
  }

  Widget _fileIcon() {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: const Color(0xFFEAF5ED),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(
        Icons.image_outlined,
        size: 20,
        color: Color(0xFF39845A),
      ),
    );
  }

  Widget _tableValue(String label, String value, {bool compact = false}) {
    return SizedBox(
      width: compact ? 110 : 125,
      child: Column(
        crossAxisAlignment: compact
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.end,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: Color(0xFF9AA19C)),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF354139),
            ),
          ),
        ],
      ),
    );
  }

  Widget _researchNote() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF5ED),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFD4E8DA)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, color: Color(0xFF31794F), size: 21),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Catatan penelitian: statistik area, bentuk, dan warna '
              'merupakan karakteristik visual dari citra TBS. '
              'Nilai tersebut belum digunakan untuk menyatakan '
              'tingkat kematangan karena dataset penelitian belum '
              'memiliki label maturity.',
              style: TextStyle(
                fontSize: 12,
                height: 1.5,
                color: Color(0xFF496152),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF5ED),
              borderRadius: BorderRadius.circular(17),
            ),
            child: Icon(icon, size: 28, color: const Color(0xFF77A288)),
          ),
          const SizedBox(height: 13),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF26352C),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: Color(0xFF858D87)),
          ),
        ],
      ),
    );
  }
}
