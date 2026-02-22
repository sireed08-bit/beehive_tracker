import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;

import '../models/inspection.dart';

/// Sends unsynced inspections to Google Apps Script webhook.
class SyncService {
  SyncService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<void> pushUnsynced({required String webhookUrl}) async {
    final box = Hive.box<Inspection>('inspections');
    final unsynced = box.values.where((row) => !row.synced).toList();

    for (final inspection in unsynced) {
      try {
        final response = await _client.post(
          Uri.parse(webhookUrl),
          headers: {
            'Content-Type': 'application/json',
            // Required security header from prompt.
            'X-Api-Key': dotenv.env['ENV_SECRET'] ?? 'ENV_SECRET',
          },
          body: jsonEncode(inspection.toJson()),
        );

        if (response.statusCode >= 200 && response.statusCode < 300) {
          inspection.synced = true;
          await inspection.save();
        } else {
          debugPrint('Sync failed for ${inspection.id}: ${response.body}');
        }
      } catch (e) {
        debugPrint('Sync exception for ${inspection.id}: $e');
      }
    }
  }
}
