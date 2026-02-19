import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';

class InspectionEngine {
  final SpeechToText _stt = SpeechToText();
  final FlutterTts _tts = FlutterTts();

  Future<void> startInspection() async {
    bool available = await _stt.initialize();
    if (available) {
      // Loop through the 21 questions defined in the branch tree
      await _askQuestion("What is the hive strength? Say next when done.");
    }
  }

  Future<void> _askQuestion(String text) async {
    await _tts.speak(text);
    _stt.listen(onResult: (result) {
      if (result.recognizedWords.contains("next")) {
        _stt.stop();
        // Move to next question logic
      }
    }, listenFor: Duration(seconds: 10));
  }
}