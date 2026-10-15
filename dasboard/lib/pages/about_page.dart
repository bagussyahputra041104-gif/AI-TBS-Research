import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8F5),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(34, 30, 34, 50),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: Column(
                children: [
                  _brand(),
                  const SizedBox(height: 28),
                  _projectCard(),
                  const SizedBox(height: 20),
                  _methodCard(),
                  const SizedBox(height: 20),
                  _scopeCard(),
                  const SizedBox(height: 28),
                  const Text(
                    'PalmVision • AI TBS Research',
                    style: TextStyle(fontSize: 12, color: Color(0xFF929A94)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _brand() {
    return Column(
      children: [
        Container(
          width: 82,
          height: 82,
          decoration: BoxDecoration(
            color: const Color(0xFF176B3D),
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF176B3D).withValues(alpha: 0.16),
                blurRadius: 25,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(Icons.eco_rounded, color: Colors.white, size: 44),
        ),
        const SizedBox(height: 18),
        const Text(
          'PalmVision',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.7,
            color: Color(0xFF17221B),
          ),
        ),
        const SizedBox(height: 5),
        const Text(
          'AI-based Oil Palm Fresh Fruit Bunch Analysis',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: Color(0xFF747A76)),
        ),
      ],
    );
  }

  Widget _projectCard() {
    return _card(
      icon: Icons.science_outlined,
      title: 'Research Project',
      child: const Text(
        'PalmVision merupakan prototype aplikasi computer vision '
        'untuk melakukan analisis citra Tandan Buah Segar (TBS) '
        'kelapa sawit. Sistem menggunakan segmentasi berbasis '
        'Small U-Net untuk memisahkan objek TBS dari latar belakang '
        'sebelum dilakukan analisis karakteristik visual.',
        style: TextStyle(fontSize: 13, height: 1.65, color: Color(0xFF59665D)),
      ),
    );
  }

  Widget _methodCard() {
    return _card(
      icon: Icons.account_tree_outlined,
      title: 'System Pipeline',
      child: Column(
        children: [
          _step(1, 'Image Input', 'Pengguna mengunggah citra TBS.'),
          _step(
            2,
            'AI Segmentation',
            'Small U-Net menghasilkan mask objek TBS.',
          ),
          _step(
            3,
            'Shape Analysis',
            'Area, width, height, aspect ratio, dan circularity.',
          ),
          _step(
            4,
            'Color Analysis',
            'Analisis karakteristik warna HSV dan LAB.',
          ),
          _step(
            5,
            'Visualization',
            'Hasil ditampilkan pada dashboard, history, analytics, dan report.',
          ),
        ],
      ),
    );
  }

  Widget _scopeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(23),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEBD9A9)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, color: Color(0xFF9A7620), size: 23),
          SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Research Scope',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF735F29),
                  ),
                ),
                SizedBox(height: 7),
                Text(
                  'Prototype ini berfokus pada segmentasi TBS dan '
                  'analisis karakteristik visual. Dataset saat ini '
                  'belum memiliki label tingkat kematangan, sehingga '
                  'sistem tidak digunakan untuk menyimpulkan maturity '
                  'secara langsung. Nilai area juga merupakan satuan '
                  'pixel², bukan ukuran fisik.',
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.6,
                    color: Color(0xFF735F29),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _card({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(23),
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
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5EC),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(icon, color: const Color(0xFF177746)),
              ),
              const SizedBox(width: 13),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF26352C),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _step(int number, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5EC),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Text(
              '$number',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF177746),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF354139),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF7B847D),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
