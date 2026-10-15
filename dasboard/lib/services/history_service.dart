import 'package:flutter/foundation.dart';

import '../models/analysis_result.dart';

class HistoryService extends ChangeNotifier {
  HistoryService._();

  static final HistoryService instance = HistoryService._();

  final List<AnalysisResult> _items = [];

  List<AnalysisResult> get items => List.unmodifiable(_items);

  int get count => _items.length;

  AnalysisResult? get latest {
    if (_items.isEmpty) return null;
    return _items.last;
  }

  double get averageArea {
    if (_items.isEmpty) return 0;

    final total = _items.fold<double>(0, (sum, item) => sum + item.area);

    return total / _items.length;
  }

  double get averageCircularity {
    if (_items.isEmpty) return 0;

    final total = _items.fold<double>(0, (sum, item) => sum + item.circularity);

    return total / _items.length;
  }

  double get averageAspectRatio {
    if (_items.isEmpty) return 0;

    final total = _items.fold<double>(0, (sum, item) => sum + item.aspectRatio);

    return total / _items.length;
  }

  void add(AnalysisResult result) {
    _items.insert(0, result);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
