import 'package:flutter/foundation.dart';

class SettingsService extends ChangeNotifier {
  SettingsService._();

  static final SettingsService instance = SettingsService._();

  String _backendUrl = 'http://127.0.0.1:8000';

  String get backendUrl => _backendUrl;

  void setBackendUrl(String value) {
    final newValue = value.trim();

    if (newValue.isEmpty) {
      return;
    }

    _backendUrl = newValue;

    notifyListeners();
  }
}
