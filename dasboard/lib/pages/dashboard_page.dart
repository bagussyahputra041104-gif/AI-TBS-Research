import 'package:flutter/material.dart';

import '../services/history_service.dart';
import '../widgets/sidebar.dart';
import 'about_page.dart';
import 'analytics_page.dart';
import 'analyze_page.dart';
import 'history_page.dart';
import 'reports_page.dart';
import 'settings_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int selectedIndex = 0;

  final List<Widget> pages = const [
    _HomePage(),
    AnalyzePage(),
    HistoryPage(),
    AnalyticsPage(),
    ReportsPage(),
    SettingsPage(),
    AboutPage(),
  ];

  void _navigate(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8F5),
      body: Row(
        children: [
          Sidebar(selectedIndex: selectedIndex, onItemSelected: _navigate),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              child: KeyedSubtree(
                key: ValueKey(selectedIndex),
                child: pages[selectedIndex],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// HOME PAGE
// ============================================================

class _HomePage extends StatelessWidget {
  const _HomePage();

  @override
  Widget build(BuildContext context) {
    final history = HistoryService.instance;

    return AnimatedBuilder(
      animation: history,
      builder: (context, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(38, 34, 38, 50),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1380),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTopBar(),

                  const SizedBox(height: 28),

                  _buildHero(context),

                  const SizedBox(height: 34),

                  _buildSectionHeader(
                    'Overview',
                    'Ringkasan hasil analisis TBS',
                  ),

                  const SizedBox(height: 16),

                  _buildOverview(history),

                  const SizedBox(height: 38),

                  _buildSectionHeader(
                    'AI Analysis Pipeline',
                    'Alur pemrosesan citra TBS',
                  ),

                  const SizedBox(height: 16),

                  _buildPipeline(),

                  const SizedBox(height: 38),

                  _buildResearchCard(),

                  const SizedBox(height: 28),

                  _buildFooter(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ==========================================================
  // TOP BAR
  // ==========================================================

  Widget _buildTopBar() {
    return Row(
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'PalmVision',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.7,
                  color: Color(0xFF17221B),
                ),
              ),
              SizedBox(height: 5),
              Text(
                'AI-based Oil Palm Fresh Fruit Bunch Analysis',
                style: TextStyle(fontSize: 15, color: Color(0xFF747A76)),
              ),
            ],
          ),
        ),

        // AI STATUS
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F6ED),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: const Color(0xFFD0EBDD)),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.circle, size: 9, color: Color(0xFF168044)),
              SizedBox(width: 8),
              Text(
                'AI Engine Ready',
                style: TextStyle(
                  color: Color(0xFF166B3F),
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==========================================================
  // HERO
  // ==========================================================

  Widget _buildHero(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 34, vertical: 30),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFEAF7EE), Color(0xFFDDF1E4)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFD5EBDD)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // LABEL
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 11,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.72),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'COMPUTER VISION',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.1,
                      color: Color(0xFF167A45),
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                const Text(
                  'Analisis TBS\ndengan Artificial Intelligence',
                  style: TextStyle(
                    fontSize: 30,
                    height: 1.12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.8,
                    color: Color(0xFF14251C),
                  ),
                ),

                const SizedBox(height: 12),

                const Text(
                  'PalmVision menggunakan Small U-Net untuk '
                  'melakukan segmentasi TBS kemudian menghasilkan '
                  'analisis bentuk dan warna dari objek yang '
                  'terdeteksi.',
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.55,
                    color: Color(0xFF626B65),
                  ),
                ),

                const SizedBox(height: 22),

                FilledButton.icon(
                  onPressed: () {
                    final dashboardState = context
                        .findAncestorStateOfType<_DashboardPageState>();

                    dashboardState?._navigate(1);
                  },
                  icon: const Icon(Icons.auto_awesome, size: 18),
                  label: const Text('Mulai Analisis'),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF176B3D),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 19,
                      vertical: 13,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 30),

          // ICON
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFF176B3D),
              borderRadius: BorderRadius.circular(34),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF176B3D).withValues(alpha: 0.18),
                  blurRadius: 30,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: const Icon(Icons.eco_rounded, color: Colors.white, size: 62),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // SECTION HEADER
  // ==========================================================

  Widget _buildSectionHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
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

  // ==========================================================
  // OVERVIEW
  // ==========================================================

  Widget _buildOverview(HistoryService history) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 800) {
          return Column(
            children: [
              _statCard(
                icon: Icons.analytics_outlined,
                label: 'Total Analysis',
                value: history.count.toString(),
                caption: 'hasil analisis',
              ),
              const SizedBox(height: 12),
              _statCard(
                icon: Icons.crop_square_rounded,
                label: 'Average Area',
                value: history.averageArea.toStringAsFixed(0),
                caption: 'pixel²',
              ),
              const SizedBox(height: 12),
              _statCard(
                icon: Icons.circle_outlined,
                label: 'Average Circularity',
                value: history.averageCircularity.toStringAsFixed(3),
                caption: 'shape metric',
              ),
            ],
          );
        }

        return Row(
          children: [
            Expanded(
              child: _statCard(
                icon: Icons.analytics_outlined,
                label: 'Total Analysis',
                value: history.count.toString(),
                caption: 'hasil analisis',
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: _statCard(
                icon: Icons.crop_square_rounded,
                label: 'Average Area',
                value: history.averageArea.toStringAsFixed(0),
                caption: 'pixel²',
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: _statCard(
                icon: Icons.circle_outlined,
                label: 'Average Circularity',
                value: history.averageCircularity.toStringAsFixed(3),
                caption: 'shape metric',
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _statCard({
    required IconData icon,
    required String label,
    required String value,
    required String caption,
  }) {
    return Container(
      height: 126,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE4E9E5)),
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
            child: Icon(icon, color: const Color(0xFF177746), size: 25),
          ),

          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF727A75),
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                    color: Color(0xFF17221B),
                  ),
                ),

                const SizedBox(height: 1),

                Text(
                  caption,
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

  // ==========================================================
  // PIPELINE
  // ==========================================================

  Widget _buildPipeline() {
    final steps = [
      (Icons.upload_file_rounded, 'Upload', 'Masukkan citra TBS'),
      (Icons.memory_rounded, 'AI Segmentation', 'Small U-Net'),
      (Icons.crop_free_rounded, 'Shape Analysis', 'Area & bentuk'),
      (Icons.palette_outlined, 'Color Analysis', 'HSV & LAB'),
      (Icons.assessment_outlined, 'Report', 'Hasil analisis'),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 27),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE4E9E5)),
      ),
      child: Row(
        children: List.generate(steps.length, (index) {
          final step = steps[index];

          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE9F5ED),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          step.$1,
                          color: const Color(0xFF167543),
                          size: 25,
                        ),
                      ),

                      const SizedBox(height: 11),

                      Text(
                        '${index + 1}. ${step.$2}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A251E),
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        step.$3,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF8A918C),
                        ),
                      ),
                    ],
                  ),
                ),

                if (index != steps.length - 1)
                  Container(
                    width: 26,
                    height: 1,
                    color: const Color(0xFFD8E3DB),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  // ==========================================================
  // RESEARCH CARD
  // ==========================================================

  Widget _buildResearchCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF142D21),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.science_outlined,
              color: Color(0xFFB9E5C9),
              size: 26,
            ),
          ),

          const SizedBox(width: 17),

          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Research Prototype',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                SizedBox(height: 5),

                Text(
                  'PalmVision merupakan prototype computer vision '
                  'untuk analisis citra TBS berbasis segmentasi dan '
                  'karakteristik visual.',
                  style: TextStyle(
                    color: Color(0xFFB7C8BE),
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 20),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: const Color(0xFF24573D),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'AI TBS Research',
              style: TextStyle(
                color: Color(0xFFC8E8D3),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // FOOTER
  // ==========================================================

  Widget _buildFooter() {
    return Center(
      child: Text(
        'PalmVision • AI TBS Research',
        style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
      ),
    );
  }
}
