import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../models/inspection.dart';

/// Requests a concise biology + ROI recommendation from Gemini 1.5 Pro.
class GeminiAdvisor {
  GeminiAdvisor({http.Client? client, FlutterTts? tts})
      : _client = client ?? http.Client(),
        _tts = tts ?? FlutterTts();

  final http.Client _client;
  final FlutterTts _tts;

  Future<String> generateAndSpeak(Inspection current) async {
    final box = Hive.box<Inspection>('inspections');
    final history = box.values
        .where((i) => i.hiveId == current.hiveId && i.id != current.id)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    final lastTwo = history.take(2).map((e) => e.toJson()).toList();

    final prompt = '''
You are an apiary business intelligence advisor.
Return EXACTLY two sentences:
1) Biological trajectory prediction for colony health.
2) ROI/business recommendation for next inspection cycle.

Current inspection (${DateFormat('yyyy-MM-dd HH:mm').format(current.createdAt)}):
${jsonEncode(current.toJson())}

Last two historical records:
${jsonEncode(lastTwo)}
''';

    final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
    final model = 'gemini-1.5-pro';
    final uri = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$apiKey',
    );

    final response = await _client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'contents': [
          {
            'parts': [
              {'text': prompt}
            ]
          }
        ]
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      return 'Unable to get Gemini advice right now.';
    }

    final payload = jsonDecode(response.body) as Map<String, dynamic>;
    final candidates = payload['candidates'] as List<dynamic>? ?? const [];

    String advice = 'No advisory text returned.';
    if (candidates.isNotEmpty) {
      final content = (candidates.first as Map<String, dynamic>)['content']
          as Map<String, dynamic>?;
      final parts = content?['parts'] as List<dynamic>? ?? const [];
      if (parts.isNotEmpty) {
        advice = (parts.first as Map<String, dynamic>)['text'] as String? ?? advice;
      }
    }

    await _tts.speak(advice);
    return advice;
  }
}
