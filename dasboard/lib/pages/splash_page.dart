import 'dart:async';

import 'package:flutter/material.dart';

import 'dashboard_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _progressAnimation;

  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.65, curve: Curves.easeOut),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.75,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _progressAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _controller.forward();

    _timer = Timer(const Duration(milliseconds: 2600), _openDashboard);
  }

  void _openDashboard() {
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 700),
        pageBuilder: (context, animation, secondaryAnimation) {
          return const DashboardPage();
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
            child: child,
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0A2E20), Color(0xFF0E3827), Color(0xFF071D15)],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -130,
              right: -100,
              child: _glowCircle(size: 330, opacity: 0.08),
            ),
            Positioned(
              bottom: -160,
              left: -120,
              child: _glowCircle(size: 380, opacity: 0.06),
            ),
            Center(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: Transform.scale(
                      scale: _scaleAnimation.value,
                      child: child,
                    ),
                  );
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildLogo(),
                    const SizedBox(height: 30),
                    const Text(
                      'PALMVISION',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 34,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 4,
                      ),
                    ),
                    const SizedBox(height: 9),
                    Text(
                      'AI TBS RESEARCH',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.68),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 3.2,
                      ),
                    ),
                    const SizedBox(height: 52),
                    SizedBox(
                      width: 240,
                      child: AnimatedBuilder(
                        animation: _progressAnimation,
                        builder: (context, child) {
                          final progress = _progressAnimation.value;

                          return Column(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: LinearProgressIndicator(
                                  minHeight: 5,
                                  value: progress,
                                  backgroundColor: Colors.white.withValues(
                                    alpha: 0.12,
                                  ),
                                  valueColor:
                                      const AlwaysStoppedAnimation<Color>(
                                        Color(0xFF7BE495),
                                      ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 350),
                                child: Text(
                                  _loadingText(progress),
                                  key: ValueKey(_loadingText(progress)),
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.62),
                                    fontSize: 12,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 30,
              left: 0,
              right: 0,
              child: Text(
                'Research Prototype • 2026',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.35),
                  fontSize: 11,
                  letterSpacing: 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 108,
      height: 108,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.08),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.14),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7BE495).withValues(alpha: 0.12),
            blurRadius: 40,
            spreadRadius: 8,
          ),
        ],
      ),
      child: const Center(
        child: Icon(Icons.eco_rounded, color: Color(0xFF7BE495), size: 58),
      ),
    );
  }

  Widget _glowCircle({required double size, required double opacity}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF7BE495).withValues(alpha: opacity),
      ),
    );
  }

  String _loadingText(double progress) {
    if (progress < 0.35) {
      return 'Initializing system...';
    }

    if (progress < 0.65) {
      return 'Loading AI engine...';
    }

    if (progress < 0.9) {
      return 'Preparing analysis workspace...';
    }

    return 'Ready';
  }
}
