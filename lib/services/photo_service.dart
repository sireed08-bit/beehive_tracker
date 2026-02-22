import 'dart:convert';
import 'dart:io';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis_auth/auth_io.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

/// Handles photo capture and upload to a specific Google Drive folder.
class PhotoService {
  PhotoService({
    ImagePicker? picker,
    GoogleSignIn? signIn,
  })  : _picker = picker ?? ImagePicker(),
        _googleSignIn = signIn ??
            GoogleSignIn(
              scopes: [drive.DriveApi.driveFileScope],
            );

  final ImagePicker _picker;
  final GoogleSignIn _googleSignIn;

  Future<String?> captureAndUploadJpeg({required String driveFolderId}) async {
    final picked = await _picker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.rear,
      imageQuality: 82,
    );

    if (picked == null) return null;

    final account = await _googleSignIn.signInSilently() ?? await _googleSignIn.signIn();
    if (account == null) return null;

    final authHeaders = await account.authHeaders;
    final client = authenticatedClient(http.Client(), AccessCredentials(
      AccessToken('Bearer', _extractBearer(authHeaders), DateTime.now().add(const Duration(hours: 1))),
      null,
      [drive.DriveApi.driveFileScope],
    ));

    final api = drive.DriveApi(client);
    final media = drive.Media(File(picked.path).openRead(), await File(picked.path).length());
    final file = drive.File()
      ..name = 'inspection_${DateTime.now().millisecondsSinceEpoch}.jpg'
      ..parents = [driveFolderId]
      ..mimeType = 'image/jpeg';

    final uploaded = await api.files.create(
      file,
      uploadMedia: media,
      $fields: 'id,webViewLink',
    );

    return uploaded.webViewLink;
  }

  String _extractBearer(Map<String, String> headers) {
    final auth = headers['Authorization'] ?? headers['authorization'] ?? '';
    return auth.replaceFirst('Bearer ', '');
  }

  String extractFileIdFromWebViewLink(String webViewLink) {
    final uri = Uri.parse(webViewLink);
    if (uri.queryParameters.containsKey('id')) {
      return uri.queryParameters['id']!;
    }

    final matches = RegExp(r'/d/([a-zA-Z0-9_-]+)').firstMatch(webViewLink);
    return matches?.group(1) ?? '';
  }

  String thumbnailFormula(String fileId) =>
      '=IMAGE("https://drive.google.com/thumbnail?sz=w200&id=$fileId")';
}
