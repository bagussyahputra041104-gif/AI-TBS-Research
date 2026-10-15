import 'package:flutter/material.dart';

class HistogramChart extends StatelessWidget {
  final List<double> values;
  final String title;

  const HistogramChart({
    super.key,
    required this.values,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final maxValue = values.isEmpty
        ? 1.0
        : values.reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 120,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: values.map((value) {
                final height = maxValue == 0
                    ? 0.0
                    : (value / maxValue) * 100;

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 1),
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        height: height,
                        decoration: BoxDecoration(
                          color: const Color(0xFF4CAF50),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
