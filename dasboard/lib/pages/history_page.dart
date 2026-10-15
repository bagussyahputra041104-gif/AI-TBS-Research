import 'package:flutter/material.dart';

import '../models/analysis_result.dart';
import '../services/history_service.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final history = HistoryService.instance;

    return AnimatedBuilder(
      animation: history,
      builder: (context, _) {
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
                      _buildHeader(history),
                      const SizedBox(height: 28),
                      if (history.items.isEmpty)
                        _buildEmptyState()
                      else ...[
                        _buildSummary(history),
                        const SizedBox(height: 26),
                        _buildHistoryPanel(history),
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

  Widget _buildHeader(HistoryService history) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFFE4F2E8),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.history_rounded,
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
                      'Analysis History',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.7,
                        color: Color(0xFF17221B),
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Daftar hasil analisis citra TBS yang telah dilakukan.',
                      style: TextStyle(fontSize: 14, color: Color(0xFF747A76)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (history.items.isNotEmpty)
          OutlinedButton.icon(
            onPressed: history.clear,
            icon: const Icon(Icons.delete_sweep_outlined, size: 18),
            label: const Text('Clear History'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF9B433A),
              backgroundColor: Colors.white,
              side: const BorderSide(color: Color(0xFFE2C4C0)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
      ],
    );
  }

  // ============================================================
  // SUMMARY
  // ============================================================

  Widget _buildSummary(HistoryService history) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 900;

        final cards = [
          _summaryCard(
            icon: Icons.analytics_outlined,
            title: 'Total Analysis',
            value: history.count.toString(),
            description: 'Analisis tersimpan',
          ),
          _summaryCard(
            icon: Icons.area_chart_outlined,
            title: 'Average Area',
            value: history.averageArea.toStringAsFixed(0),
            description: 'pixel²',
          ),
          _summaryCard(
            icon: Icons.circle_outlined,
            title: 'Average Circularity',
            value: history.averageCircularity.toStringAsFixed(3),
            description: 'Visual shape metric',
          ),
        ];

        if (compact) {
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
            Expanded(child: cards[0]),
            const SizedBox(width: 16),
            Expanded(child: cards[1]),
            const SizedBox(width: 16),
            Expanded(child: cards[2]),
          ],
        );
      },
    );
  }

  Widget _summaryCard({
    required IconData icon,
    required String title,
    required String value,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(21),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE1E9E3)),
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
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5EC),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, color: const Color(0xFF176B3A), size: 25),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF7A817C),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF17221B),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF9AA19C),
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
  // HISTORY PANEL
  // ============================================================

  Widget _buildHistoryPanel(HistoryService history) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE1E9E3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _panelHeader(history),
          const Divider(height: 1, color: Color(0xFFE9EEEA)),
          ...history.items.asMap().entries.map(
            (entry) =>
                _historyItem(entry.value, entry.key, history.items.length),
          ),
        ],
      ),
    );
  }

  Widget _panelHeader(HistoryService history) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(23, 21, 23, 19),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF5ED),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.history_rounded,
              color: Color(0xFF39845A),
              size: 21,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Previous Analyses',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF26352C),
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Riwayat hasil analisis yang tersimpan pada sesi ini.',
                  style: TextStyle(fontSize: 11, color: Color(0xFF8A928D)),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F6F2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${history.count} Records',
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: Color(0xFF397151),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // HISTORY ITEM
  // ============================================================

  Widget _historyItem(AnalysisResult item, int index, int total) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 19),
      decoration: BoxDecoration(
        border: index < total - 1
            ? const Border(bottom: BorderSide(color: Color(0xFFEEF2EF)))
            : null,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 850) {
            return _compactHistoryItem(item);
          }

          return Row(
            children: [
              _fileIcon(),
              const SizedBox(width: 16),
              Expanded(flex: 3, child: _fileInfo(item)),
              _metric('Area', item.area.toStringAsFixed(0), 'pixel²'),
              _metric(
                'Circularity',
                item.circularity.toStringAsFixed(3),
                'shape',
              ),
              _metric(
                'Aspect Ratio',
                item.aspectRatio.toStringAsFixed(3),
                'ratio',
              ),
              const SizedBox(width: 12),
              _completedBadge(),
            ],
          );
        },
      ),
    );
  }

  Widget _compactHistoryItem(AnalysisResult item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _fileIcon(),
            const SizedBox(width: 14),
            Expanded(child: _fileInfo(item)),
            _completedBadge(),
          ],
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 24,
          runSpacing: 12,
          children: [
            _compactMetric('Area', item.area.toStringAsFixed(0), 'pixel²'),
            _compactMetric(
              'Circularity',
              item.circularity.toStringAsFixed(3),
              'shape',
            ),
            _compactMetric(
              'Aspect Ratio',
              item.aspectRatio.toStringAsFixed(3),
              'ratio',
            ),
          ],
        ),
      ],
    );
  }

  Widget _fileIcon() {
    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        color: const Color(0xFFEAF5ED),
        borderRadius: BorderRadius.circular(15),
      ),
      child: const Icon(
        Icons.image_outlined,
        color: Color(0xFF39845A),
        size: 27,
      ),
    );
  }

  Widget _fileInfo(AnalysisResult item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.fileName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFF26352C),
          ),
        ),
        const SizedBox(height: 5),
        Row(
          children: [
            const Icon(
              Icons.schedule_outlined,
              size: 13,
              color: Color(0xFF9AA19C),
            ),
            const SizedBox(width: 5),
            Text(
              _formatDate(item.timestamp),
              style: const TextStyle(fontSize: 11, color: Color(0xFF969D98)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _metric(String label, String value, String unit) {
    return SizedBox(
      width: 118,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: Color(0xFF9AA19C)),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF354139),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            unit,
            style: const TextStyle(fontSize: 9, color: Color(0xFF9AA19C)),
          ),
        ],
      ),
    );
  }

  Widget _compactMetric(String label, String value, String unit) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: Color(0xFF9AA19C)),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Color(0xFF354139),
          ),
        ),
        Text(
          unit,
          style: const TextStyle(fontSize: 9, color: Color(0xFF9AA19C)),
        ),
      ],
    );
  }

  Widget _completedBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F6ED),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFD6EEDF)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle_outline, size: 13, color: Color(0xFF167A45)),
          SizedBox(width: 5),
          Text(
            'Completed',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Color(0xFF167A45),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 90),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2E9E4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
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
              Icons.history_rounded,
              size: 42,
              color: Color(0xFF7BA18A),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Belum Ada Riwayat Analisis',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF26352C),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Hasil analisis akan otomatis tersimpan di halaman ini.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Color(0xFF858D87)),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();

    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return '$day/$month/$year • $hour:$minute';
  }
}
