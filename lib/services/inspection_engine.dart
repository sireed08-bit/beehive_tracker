import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:hive/hive.dart';
import '../models/inspection.dart';
import 'sync_service.dart';

enum AppState { inactive, askHiveId, askHeaveTest, askMites, askFinalStrength, finished }

class InspectionEngine {
  final SpeechToText _stt = SpeechToText();
  final FlutterTts _tts = FlutterTts();
  final SyncService _syncService = SyncService();

  late Inspection _currentEntry;
  AppState _currentState = AppState.inactive;
  bool isListening = false;
  bool _isProcessing = false;
  Function(String)? _onResultCallback;

  Future<void> startInspection(String locationName, {Function(String)? onResult}) async {
    _onResultCallback = onResult;

    // THE MASTER FIX: Force TTS to dynamically wait until it is 100% finished speaking
    await _tts.awaitSpeakCompletion(true);

    if (isListening) {
      _stt.cancel();
    }
    await _tts.stop();
    isListening = false;

    bool available = await _stt.initialize();
    if (!available) return;

    _currentEntry = Inspection()..location = locationName;
    _currentState = AppState.askHiveId;
    _runState();
  }

  Future<void> _runState() async {
    _isProcessing = false;

    String prompt = "";
    switch (_currentState) {
      case AppState.askHiveId: prompt = "Hive ID?"; break;
      case AppState.askHeaveTest: prompt = "Heave Test zero to four?"; break;
      case AppState.askMites: prompt = "Mite count?"; break;
      case AppState.askFinalStrength: prompt = "Final strength?"; break;
      case AppState.finished: await _finishInspection(); return;
      case AppState.inactive: return;
    }

    if (_onResultCallback != null) _onResultCallback!("Asking: $prompt");

    // The app will now dynamically pause here until the voice finishes the entire sentence
    await _tts.speak(prompt);

    isListening = true;

    _stt.listen(
      onResult: _handleVoiceInput,
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 10),
      listenOptions: SpeechListenOptions(
        listenMode: ListenMode.confirmation,
        partialResults: true,
      ),
    );
  }

  void _handleVoiceInput(SpeechRecognitionResult result) {
    if (_isProcessing) return;

    String spoken = result.recognizedWords.toLowerCase();
    if (_onResultCallback != null) _onResultCallback!(spoken);

    if (result.finalResult || spoken.contains("next") || spoken.contains("skip")) {

      String answer = spoken.replaceAll("next", "").replaceAll("skip", "").trim();

      _isProcessing = true;
      _stt.cancel();
      isListening = false;

      // THE TRANSLATOR: Convert spoken words AND common homophones into exact numbers
      answer = answer.replaceAll('zero', '0')
          .replaceAll('one', '1').replaceAll('won', '1')
          .replaceAll('two', '2').replaceAll('too', '2').replaceAll('to', '2')
          .replaceAll('three', '3')
          .replaceAll('four', '4').replaceAll('for', '4')
          .replaceAll('five', '5')
          .replaceAll('six', '6')
          .replaceAll('seven', '7')
          .replaceAll('eight', '8').replaceAll('ate', '8')
          .replaceAll('nine', '9')
          .replaceAll('ten', '10');

      print("=== RECORDING ANSWER FOR STATE $_currentState: '$answer' ===");

      if (_currentState == AppState.askHiveId) _currentEntry.hiveId = answer;

      if (_currentState == AppState.askHeaveTest) {
        _currentEntry.heaveTest = int.tryParse(answer.replaceAll(RegExp(r'[^0-9]'), ''));
      }
      if (_currentState == AppState.askMites) {
        _currentEntry.miteCount = int.tryParse(answer.replaceAll(RegExp(r'[^0-9]'), ''));
      }
      if (_currentState == AppState.askFinalStrength) _currentEntry.strength = answer;

      Future.delayed(const Duration(milliseconds: 500), () => _advanceState(answer));
    }
  }

  void _advanceState(String answer) {
    switch (_currentState) {
      case AppState.askHiveId: _currentState = AppState.askHeaveTest; break;
      case AppState.askHeaveTest: _currentState = AppState.askMites; break;
      case AppState.askMites: _currentState = AppState.askFinalStrength; break;
      case AppState.askFinalStrength: _currentState = AppState.finished; break;
      default: break;
    }

    _runState();
  }

  Future<void> _finishInspection() async {
    await _tts.speak("Inspection saved.");
    var box = Hive.box<Inspection>('inspections_box');
    await box.add(_currentEntry);
    await _syncService.syncInspection(_currentEntry);
    _currentState = AppState.inactive;
  }
}