import 'package:flutter/material.dart';

import 'pages/dashboard_page.dart';

class PalmVisionApp extends StatelessWidget {
  const PalmVisionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PalmVision',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF176B45),
        scaffoldBackgroundColor: const Color(0xFFF7F9F4),
      ),
      home: const DashboardPage(),
    );
  }
}
