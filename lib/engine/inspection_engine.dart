import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../models/inspection.dart';

class InspectionEngine extends ChangeNotifier {
  InspectionEngine({SpeechToText? speechToText, FlutterTts? tts})
      : _speechToText = speechToText ?? SpeechToText(),
        _tts = tts ?? FlutterTts();

  final SpeechToText _speechToText;
  final FlutterTts _tts;

  Inspection current = Inspection();
  InspectionStep step = InspectionStep.hiveId;
  bool _isListening = false;
  String transcript = '';

  bool get isListening => _isListening;

  Future<void> initialize() async {
    await _tts.setLanguage('en-US');
    await _speechToText.initialize(
      onStatus: (status) {
        if (status == 'done') unawaited(_reopenMic());
      },
    );
    await promptCurrentStep();
  }

  Future<void> promptCurrentStep() async {
    await _tts.speak(_promptFor(step));
    await _reopenMic();
  }

  Future<void> _reopenMic() async {
    if (_isListening) return;
    _isListening = true;
    notifyListeners();

    await _speechToText.listen(
      onResult: (result) {
        transcript = result.recognizedWords;
        if (result.finalResult) unawaited(handleVoiceCommand(transcript));
      },
      onDevice: true,
      pauseFor: const Duration(seconds: 10),
      listenFor: const Duration(minutes: 5),
      partialResults: true,
      cancelOnError: false,
      localeId: 'en_US',
    );
  }

  Future<void> _stopListening() async {
    if (!_isListening) return;
    await _speechToText.stop();
    _isListening = false;
    notifyListeners();
  }

  Future<void> handleVoiceCommand(String heard) async {
    final normalized = heard.trim().toLowerCase();
    await _stopListening();

    if (normalized == 'take picture') {
      await _tts.speak('Opening camera.');
      await promptCurrentStep();
      return;
    }
    if (normalized == 'skip') {
      _advance(skip: true);
      await promptCurrentStep();
      return;
    }
    if (normalized == 'done') {
      step = InspectionStep.done;
      notifyListeners();
      return;
    }
    if (normalized == 'next') {
      _advance(skip: false);
      await promptCurrentStep();
      return;
    }

    _applyAnswer(normalized);
    _advance(skip: false);
    await promptCurrentStep();
  }

  void _advance({required bool skip}) {
    switch (step) {
      case InspectionStep.hiveId:
        step = InspectionStep.heaveTest;
        break;
      case InspectionStep.heaveTest:
        step = InspectionStep.activity;
        break;
      case InspectionStep.activity:
        step = InspectionStep.temperament;
        break;
      case InspectionStep.temperament:
        step = (!skip && current.temperament.toLowerCase() == 'aggressive')
            ? InspectionStep.sting
            : InspectionStep.boxChange;
        break;
      case InspectionStep.sting:
        step = InspectionStep.hang;
        break;
      case InspectionStep.hang:
        step = InspectionStep.run;
        break;
      case InspectionStep.run:
        step = InspectionStep.fly;
        break;
      case InspectionStep.fly:
        step = InspectionStep.boxChange;
        break;
      case InspectionStep.boxChange:
        step = InspectionStep.reducerChange;
        break;
      case InspectionStep.reducerChange:
        step = InspectionStep.queenSeen;
        break;
      case InspectionStep.queenSeen:
        step = (!skip && current.queenSeen)
            ? InspectionStep.framesOfBees
            : InspectionStep.eggsSeen;
        break;
      case InspectionStep.eggsSeen:
        step = (!skip && !current.eggsSeen)
            ? InspectionStep.swarmCells
            : InspectionStep.framesOfBees;
        break;
      case InspectionStep.swarmCells:
        step = InspectionStep.supercedureCells;
        break;
      case InspectionStep.supercedureCells:
        step = InspectionStep.framesOfBees;
        break;
      case InspectionStep.framesOfBees:
        step = InspectionStep.honeySurplus;
        break;
      case InspectionStep.honeySurplus:
        step = InspectionStep.supplementalFeed;
        break;
      case InspectionStep.supplementalFeed:
        step = (!skip && current.supplementalFeed)
            ? InspectionStep.feedProduct
            : InspectionStep.miteCount;
        break;
      case InspectionStep.feedProduct:
        step = InspectionStep.feedVolume;
        break;
      case InspectionStep.feedVolume:
        step = InspectionStep.miteCount;
        break;
      case InspectionStep.miteCount:
        step = InspectionStep.finalStrength;
        break;
      case InspectionStep.finalStrength:
        step = InspectionStep.primaryTodo;
        break;
      case InspectionStep.primaryTodo:
      case InspectionStep.done:
        step = InspectionStep.done;
        break;
    }
    notifyListeners();
  }

  void _applyAnswer(String value) {
    switch (step) {
      case InspectionStep.hiveId:
        current.hiveId = value.isEmpty ? 'Unknown' : value;
        break;
      case InspectionStep.heaveTest:
        current.heaveTest = _parseInt(value);
        break;
      case InspectionStep.activity:
        current.activity = _parseInt(value);
        break;
      case InspectionStep.temperament:
        current.temperament = _normalizeTemperament(value);
        break;
      case InspectionStep.sting:
        current.sting = _parseInt(value);
        break;
      case InspectionStep.hang:
        current.hang = _parseInt(value);
        break;
      case InspectionStep.run:
        current.run = _parseInt(value);
        break;
      case InspectionStep.fly:
        current.fly = _parseInt(value);
        break;
      case InspectionStep.boxChange:
        current.boxChange = value;
        break;
      case InspectionStep.reducerChange:
        current.reducerChange = value;
        break;
      case InspectionStep.queenSeen:
        current.queenSeen = _toBool(value);
        break;
      case InspectionStep.eggsSeen:
        current.eggsSeen = _toBool(value);
        break;
      case InspectionStep.swarmCells:
        current.swarmCells = _parseInt(value);
        break;
      case InspectionStep.supercedureCells:
        current.supercedureCells = _parseInt(value);
        break;
      case InspectionStep.framesOfBees:
        current.framesOfBees = _parseInt(value);
        break;
      case InspectionStep.honeySurplus:
        current.honeySurplus = _parseInt(value);
        break;
      case InspectionStep.supplementalFeed:
        current.supplementalFeed = _toBool(value);
        break;
      case InspectionStep.feedProduct:
        current.feedProduct = value;
        break;
      case InspectionStep.feedVolume:
        current.feedVolumeLiters = _parseDouble(value);
        break;
      case InspectionStep.miteCount:
        current.miteCount = _parseInt(value);
        break;
      case InspectionStep.finalStrength:
        current.finalStrength = value;
        break;
      case InspectionStep.primaryTodo:
        current.primaryTodo = value;
        break;
      case InspectionStep.done:
        break;
    }
    notifyListeners();
  }

  String _promptFor(InspectionStep s) => switch (s) {
        InspectionStep.hiveId => 'Phase one. Say hive I D.',
        InspectionStep.heaveTest => 'Heave test rating zero to four.',
        InspectionStep.activity => 'Activity rating zero to four.',
        InspectionStep.temperament => 'Temperament: calm, moderate, or aggressive.',
        InspectionStep.sting => 'Aggressive branch. Sting rating.',
        InspectionStep.hang => 'Hang rating.',
        InspectionStep.run => 'Run rating.',
        InspectionStep.fly => 'Fly rating.',
        InspectionStep.boxChange => 'Phase three. Any box changes?',
        InspectionStep.reducerChange => 'Any reducer changes?',
        InspectionStep.queenSeen => 'Phase four. Queen seen? yes or no.',
        InspectionStep.eggsSeen => 'Eggs present? yes or no.',
        InspectionStep.swarmCells => 'Swarm cells count.',
        InspectionStep.supercedureCells => 'Supercedure cells count.',
        InspectionStep.framesOfBees => 'Frames of bees count.',
        InspectionStep.honeySurplus => 'Phase five. Honey surplus amount.',
        InspectionStep.supplementalFeed => 'Supplemental feed used? yes or no.',
        InspectionStep.feedProduct => 'Feed product name.',
        InspectionStep.feedVolume => 'Feed volume in liters.',
        InspectionStep.miteCount => 'Phase six. Mite count.',
        InspectionStep.finalStrength => 'Final strength: strong, medium, weak, or deadout.',
        InspectionStep.primaryTodo => 'Primary to do for next visit.',
        InspectionStep.done => 'Inspection complete.',
      };

  int _parseInt(String value) => int.tryParse(value.replaceAll(RegExp(r'[^0-9-]'), '')) ?? 0;
  double _parseDouble(String value) =>
      double.tryParse(value.replaceAll(RegExp(r'[^0-9.-]'), '')) ?? 0;
  bool _toBool(String value) => value.contains('yes') || value.contains('true');

  String _normalizeTemperament(String value) {
    if (value.contains('aggressive')) return 'Aggressive';
    if (value.contains('moderate')) return 'Moderate';
    return 'Calm';
  }
}
