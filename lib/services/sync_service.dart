import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/inspection.dart';

class SyncService {
  final String _endpoint = dotenv.env['APPS_SCRIPT_URL'] ?? '';

  Future<bool> syncInspection(Inspection data) async {
    print("=== SYNC SERVICE TRIGGERED ===");
    print("Target Endpoint: $_endpoint");

    if (_endpoint.isEmpty) {
      print("SYNC FAILED: The APPS_SCRIPT_URL is empty. Check your .env file.");
      return false;
    }

    try {
      String jsonPayload = jsonEncode(data.toJson());
      print("Sending Payload: $jsonPayload");

      final response = await http.post(
        Uri.parse(_endpoint),
        headers: {
          "Content-Type": "application/json",
          // Temporarily disabled to prevent Google Apps Script CORS blocking
          // "X-Api-Key": dotenv.env['SECURITY_HEADER'] ?? ''
        },
        body: jsonPayload,
      );

      print("Google Server Response Code: ${response.statusCode}");
      print("Google Server Message: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 302) {
        data.isSynced = true;
        await data.save();
        print("=== SYNC SUCCESS: Data written to Google Sheets ===");
        return true;
      }

      print("SYNC FAILED: Server rejected the request.");
      return false;

    } catch (e) {
      print("SYNC CRASHED WITH EXCEPTION: $e");
      return false;
    }
  }
}