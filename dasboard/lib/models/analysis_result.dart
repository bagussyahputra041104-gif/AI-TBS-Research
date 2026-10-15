import 'dart:typed_data';

class AnalysisResult {
  final String fileName;

  final double area;
  final int width;
  final int height;
  final double aspectRatio;
  final double circularity;

  final double hMean;
  final double sMean;
  final double vMean;

  final double lMean;
  final double aMean;
  final double bMean;

  final Uint8List maskBytes;
  final Map<String, List<double>> histogram;
  final DateTime timestamp;

  AnalysisResult({
    required this.fileName,
    required this.area,
    required this.width,
    required this.height,
    required this.aspectRatio,
    required this.circularity,
    required this.hMean,
    required this.sMean,
    required this.vMean,
    required this.lMean,
    required this.aMean,
    required this.bMean,
    required this.maskBytes,
    required this.histogram,
    required this.timestamp,
  });

  factory AnalysisResult.fromJson({
    required String fileName,
    required Uint8List maskBytes,
    required Map<String, dynamic> json,
  }) {
    // ========================================================
    // SEGMENTATION / SHAPE
    // Backend mengirim:
    // "segmentation": {
    //   "area_px": ...,
    //   "width_px": ...,
    //   "height_px": ...,
    //   "aspect_ratio": ...,
    //   "circularity": ...
    // }
    // ========================================================

    final segmentation = json['segmentation'];

    final Map<String, dynamic> shape = segmentation is Map
        ? Map<String, dynamic>.from(segmentation)
        : {};

    // ========================================================
    // COLOR
    // ========================================================

    final colorRaw = json['color'];

    final Map<String, dynamic> color = colorRaw is Map
        ? Map<String, dynamic>.from(colorRaw)
        : {};

    final hsvRaw = color['hsv'];

    final Map<String, dynamic> hsv = hsvRaw is Map
        ? Map<String, dynamic>.from(hsvRaw)
        : {};

    final labRaw = color['lab'];

    final Map<String, dynamic> lab = labRaw is Map
        ? Map<String, dynamic>.from(labRaw)
        : {};

    final histogramRaw = color['histogram'];

    final Map<String, dynamic> histogramData = histogramRaw is Map
        ? Map<String, dynamic>.from(histogramRaw)
        : {};

    // ========================================================
    // HISTOGRAM
    // ========================================================

    final histogram = <String, List<double>>{};

    for (final key in ['h', 's', 'v', 'l', 'a', 'b']) {
      final values = histogramData[key];

      if (values is List) {
        histogram[key] = values
            .whereType<num>()
            .map((value) => value.toDouble())
            .toList();
      } else {
        histogram[key] = [];
      }
    }

    // ========================================================
    // RESULT
    // ========================================================

    return AnalysisResult(
      fileName: fileName,

      // Shape / segmentation
      area: _doubleValue(shape['area_px']),
      width: _intValue(shape['width_px']),
      height: _intValue(shape['height_px']),
      aspectRatio: _doubleValue(shape['aspect_ratio']),
      circularity: _doubleValue(shape['circularity']),

      // HSV
      hMean: _doubleValue(hsv['h_mean']),
      sMean: _doubleValue(hsv['s_mean']),
      vMean: _doubleValue(hsv['v_mean']),

      // LAB
      lMean: _doubleValue(lab['l_mean']),
      aMean: _doubleValue(lab['a_mean']),
      bMean: _doubleValue(lab['b_mean']),

      maskBytes: maskBytes,
      histogram: histogram,
      timestamp: DateTime.now(),
    );
  }

  static double _doubleValue(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return 0.0;
  }

  static int _intValue(dynamic value) {
    if (value is num) {
      return value.toInt();
    }

    return 0;
  }
}
