import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../models/analysis_result.dart';
import 'settings_service.dart';

class ApiService {
  static Future<AnalysisResult> analyzeImage({
    required Uint8List bytes,
    required String fileName,
  }) async {
    final baseUrl = SettingsService.instance.backendUrl;
    final uri = Uri.parse('$baseUrl/analyze');

    final request = http.MultipartRequest('POST', uri);

    request.files.add(
      http.MultipartFile.fromBytes('file', bytes, filename: fileName),
    );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 200) {
      throw Exception('Backend error ${response.statusCode}: ${response.body}');
    }

    final decoded = jsonDecode(response.body);

    if (decoded is! Map<String, dynamic>) {
      throw Exception('Format response backend tidak valid.');
    }

    final data = decoded;

    final maskValue = data['mask'];

    if (maskValue == null) {
      throw Exception('Backend tidak mengembalikan field "mask".');
    }

    final maskBase64 = _extractMaskBase64(maskValue);

    if (maskBase64 == null || maskBase64.isEmpty) {
      throw Exception('Data mask dari backend tidak ditemukan.');
    }

    try {
      final maskBytes = base64Decode(maskBase64);

      return AnalysisResult.fromJson(
        fileName: fileName,
        maskBytes: maskBytes,
        json: data,
      );
    } catch (e) {
      throw Exception('Data mask dari backend bukan Base64 PNG yang valid: $e');
    }
  }

  static String? _extractMaskBase64(dynamic value) {
    // Kasus normal:
    // "mask": "iVBORw0KGgoAAA..."
    if (value is String) {
      return _cleanBase64(value);
    }

    // Kalau backend mengirim:
    // "mask": {
    //   "data": "iVBORw0KGgoAAA..."
    // }
    if (value is Map) {
      final possibleKeys = [
        'data',
        'base64',
        'image',
        'png',
        'content',
        'value',
      ];

      for (final key in possibleKeys) {
        if (value.containsKey(key)) {
          final result = _extractMaskBase64(value[key]);

          if (result != null && result.isNotEmpty) {
            return result;
          }
        }
      }

      // Cari string Base64 secara rekursif
      for (final entry in value.entries) {
        final result = _extractMaskBase64(entry.value);

        if (result != null && result.isNotEmpty) {
          return result;
        }
      }
    }

    return null;
  }

  static String _cleanBase64(String value) {
    // Jika backend mengirim:
    // data:image/png;base64,iVBORw0KGgo...
    if (value.contains(',')) {
      final parts = value.split(',');

      if (parts.length == 2 && parts.first.toLowerCase().contains('base64')) {
        return parts.last;
      }
    }

    return value.trim();
  }
}
