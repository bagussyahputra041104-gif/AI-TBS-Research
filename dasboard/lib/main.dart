import 'package:flutter/material.dart';

import 'pages/splash_page.dart';

void main() {
  runApp(const PalmVisionApp());
}

class PalmVisionApp extends StatelessWidget {
  const PalmVisionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PalmVision AI TBS Research',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF7F9F8),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF176B3A),
          brightness: Brightness.light,
        ),
        fontFamily: 'Arial',
      ),
      home: const SplashPage(),
    );
  }
}
