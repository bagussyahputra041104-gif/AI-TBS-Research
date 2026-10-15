import 'package:flutter/material.dart';

import '../services/settings_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late final TextEditingController _backendController;

  bool _saved = false;

  @override
  void initState() {
    super.initState();

    _backendController = TextEditingController(
      text: SettingsService.instance.backendUrl,
    );
  }

  @override
  void dispose() {
    _backendController.dispose();
    super.dispose();
  }

  void _saveBackendUrl() {
    final value = _backendController.text.trim();

    if (value.isEmpty) {
      setState(() {
        _saved = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Backend URL tidak boleh kosong.'),
          behavior: SnackBarBehavior.floating,
        ),
      );

      return;
    }

    SettingsService.instance.setBackendUrl(value);

    setState(() {
      _saved = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Backend URL berhasil disimpan.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
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
              constraints: const BoxConstraints(maxWidth: 1050),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 28),
                  _buildBackendCard(),
                  const SizedBox(height: 20),
                  _buildAiCard(),
                  const SizedBox(height: 20),
                  _buildResearchCard(),
                  const SizedBox(height: 20),
                  _buildSystemStatus(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Settings',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.7,
            color: Color(0xFF17221B),
          ),
        ),
        SizedBox(height: 6),
        Text(
          'Konfigurasi koneksi dan informasi sistem PalmVision.',
          style: TextStyle(fontSize: 14, color: Color(0xFF747A76)),
        ),
      ],
    );
  }

  Widget _buildBackendCard() {
    return _buildCard(
      icon: Icons.cloud_outlined,
      title: 'Backend Connection',
      subtitle: 'Alamat server yang digunakan untuk menjalankan AI.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Backend URL',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF354139),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _backendController,
            onChanged: (_) {
              if (_saved) {
                setState(() {
                  _saved = false;
                });
              }
            },
            keyboardType: TextInputType.url,
            decoration: InputDecoration(
              hintText: 'http://127.0.0.1:8000',
              prefixIcon: const Icon(Icons.link_rounded, size: 20),
              suffixIcon: _saved
                  ? const Icon(
                      Icons.check_circle_rounded,
                      color: Color(0xFF23824D),
                    )
                  : null,
              filled: true,
              fillColor: const Color(0xFFF7FAF8),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 15,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFDCE6DF)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFDCE6DF)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFF39845A),
                  width: 1.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 9),
          const Text(
            'Contoh: http://127.0.0.1:8000',
            style: TextStyle(fontSize: 11, color: Color(0xFF929A94)),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              FilledButton.icon(
                onPressed: _saveBackendUrl,
                icon: const Icon(Icons.save_outlined, size: 18),
                label: const Text('Save Configuration'),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF176B3D),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 13,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(11),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              if (_saved)
                const Row(
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      size: 17,
                      color: Color(0xFF23824D),
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Configuration saved',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF23824D),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAiCard() {
    return _buildCard(
      icon: Icons.memory_rounded,
      title: 'AI Engine',
      subtitle: 'Model dan teknologi yang digunakan oleh PalmVision.',
      child: Column(
        children: [
          _infoRow('Model', 'Small U-Net'),
          _infoRow('Task', 'TBS Segmentation'),
          _infoRow('Framework', 'PyTorch'),
          _infoRow('Inference', 'Python / FastAPI'),
          _infoRow('Analysis', 'Shape + Color'),
        ],
      ),
    );
  }

  Widget _buildResearchCard() {
    return _buildCard(
      icon: Icons.science_outlined,
      title: 'Research Configuration',
      subtitle: 'Konteks penggunaan sistem dalam penelitian.',
      child: Column(
        children: [
          _infoRow('Project', 'AI TBS Research'),
          _infoRow('Application', 'PalmVision'),
          _infoRow('Computer Vision', 'Segmentation'),
          _infoRow('Output', 'Shape & Color Characteristics'),
        ],
      ),
    );
  }

  Widget _buildSystemStatus() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(21),
      decoration: BoxDecoration(
        color: const Color(0xFF142D21),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.check_circle_outline_rounded,
              color: Color(0xFFBDE5C8),
              size: 25,
            ),
          ),
          const SizedBox(width: 15),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PalmVision System',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'AI engine siap digunakan untuk analisis citra TBS.',
                  style: TextStyle(color: Color(0xFFB7C8BE), fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: const Color(0xFF24573D),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.circle, size: 8, color: Color(0xFF8FE0A7)),
                SizedBox(width: 7),
                Text(
                  'READY',
                  style: TextStyle(
                    color: Color(0xFFC8E8D3),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.7,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({
    required IconData icon,
    required String title,
    required String subtitle,
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
          const SizedBox(height: 22),
          child,
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
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
}
