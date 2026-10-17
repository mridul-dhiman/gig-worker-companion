import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

/// Thin REST client for the Gemini generateContent endpoint.
///
/// Always asks for JSON (`responseMimeType: application/json` plus a
/// schema), retries transient failures with exponential backoff, and returns
/// null instead of throwing so callers can switch to the fallback engine.
class GeminiClient {
  GeminiClient({http.Client? httpClient}) : _http = httpClient ?? http.Client();

  static const model = 'gemini-3-flash-preview';
  static const _endpoint = 'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent';
  static const maxAttempts = 3;

  final http.Client _http;
  final _rand = Random();

  String apiKey = const String.fromEnvironment('GEMINI_API_KEY');

  /// When true, every call fails as if the network were down. Used to demo
  /// the fallback path.
  bool simulateOffline = false;

  bool get hasKey => apiKey.trim().isNotEmpty;

  Future<Map<String, dynamic>?> generateJson({
    required String systemInstruction,
    required String prompt,
    required Map<String, dynamic> schema,
    Uint8List? imageBytes,
    String imageMime = 'image/jpeg',
    void Function(int attempt)? onRetry,
  }) async {
    final body = jsonEncode({
      'systemInstruction': {
        'parts': [
          {'text': systemInstruction}
        ]
      },
      'contents': [
        {
          'role': 'user',
          'parts': [
            if (imageBytes != null)
              {
                'inlineData': {'mimeType': imageMime, 'data': base64Encode(imageBytes)}
              },
            {'text': prompt},
          ],
        }
      ],
      'generationConfig': {
        'responseMimeType': 'application/json',
        'responseSchema': schema,
        'temperature': 0.3,
      },
    });

    for (var attempt = 1; attempt <= maxAttempts; attempt++) {
      if (attempt > 1) {
        onRetry?.call(attempt);
        final backoff = 500 * pow(2, attempt - 2) + _rand.nextInt(250);
        await Future<void>.delayed(Duration(milliseconds: simulateOffline ? 450 : backoff.toInt()));
      }
      if (simulateOffline) continue;
      if (!hasKey) return null;
      try {
        final res = await _http
            .post(
              Uri.parse(_endpoint),
              headers: {'Content-Type': 'application/json', 'x-goog-api-key': apiKey.trim()},
              body: body,
            )
            .timeout(const Duration(seconds: 25));
        if (res.statusCode == 200) {
          return _extractJson(res.body);
        }
        final transient = res.statusCode == 429 || res.statusCode >= 500;
        if (!transient) return null;
      } on TimeoutException {
        // retry
      } on http.ClientException {
        // retry
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  static Map<String, dynamic>? _extractJson(String responseBody) {
    try {
      final decoded = jsonDecode(responseBody) as Map<String, dynamic>;
      final parts = (decoded['candidates'] as List).first['content']['parts'] as List;
      final text = parts.map((p) => (p as Map)['text'] ?? '').join();
      final json = jsonDecode(text);
      return json is Map<String, dynamic> ? json : null;
    } catch (_) {
      return null;
    }
  }
}

/// Small helpers for writing Gemini response schemas (OpenAPI subset).
Map<String, dynamic> obj(Map<String, dynamic> props, {List<String>? required}) => {
      'type': 'OBJECT',
      'properties': props,
      'required': required ?? props.keys.toList(),
    };
Map<String, dynamic> arr(Map<String, dynamic> items) => {'type': 'ARRAY', 'items': items};
const str = {'type': 'STRING'};
const integer = {'type': 'INTEGER'};
const boolean = {'type': 'BOOLEAN'};
