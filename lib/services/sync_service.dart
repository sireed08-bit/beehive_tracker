import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/inspection.dart';

class SyncService {
  final String endpoint = "YOUR_APPS_SCRIPT_URL";

  Future<void> sync(Inspection data) async {
    final response = await http.post(
      Uri.parse(endpoint),
      body: jsonEncode(data.toJson()),
    );
    if (response.statusCode == 200) {
      data.isSynced = true;
      await data.save();
    }
  }
}