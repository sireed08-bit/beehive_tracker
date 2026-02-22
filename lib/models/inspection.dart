import 'package:hive/hive.dart';

part 'inspection.g.dart';

/// Enumerates all steps/questions in the inspection finite state machine.
enum InspectionStep {
  hiveId,
  heaveTest,
  activity,
  temperament,
  sting,
  hang,
  run,
  fly,
  boxChange,
  reducerChange,
  queenSeen,
  eggsSeen,
  swarmCells,
  supercedureCells,
  framesOfBees,
  honeySurplus,
  supplementalFeed,
  feedProduct,
  feedVolume,
  miteCount,
  finalStrength,
  primaryTodo,
  done,
}

@HiveType(typeId: 0)
class Inspection extends HiveObject {
  Inspection({
    String? id,
    DateTime? createdAt,
    this.location = 'Unknown Yard',
    this.hiveId = 'Unknown',
    this.heaveTest = 0,
    this.activity = 0,
    this.temperament = 'Calm',
    this.sting = 0,
    this.hang = 0,
    this.run = 0,
    this.fly = 0,
    this.boxChange = 'None',
    this.reducerChange = 'None',
    this.queenSeen = false,
    this.eggsSeen = false,
    this.swarmCells = 0,
    this.supercedureCells = 0,
    this.framesOfBees = 0,
    this.honeySurplus = 0,
    this.supplementalFeed = false,
    this.feedProduct = 'None',
    this.feedVolumeLiters = 0,
    this.miteCount = 0,
    this.finalStrength = 'Medium',
    this.primaryTodo = 'None',
    this.photoWebViewLink = '',
    this.aiSummary = '',
    this.synced = false,
  })  : id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        createdAt = createdAt ?? DateTime.now();

  @HiveField(0)
  String id;

  @HiveField(1)
  DateTime createdAt;

  @HiveField(2)
  String location;

  /// Failsafe default avoids `late` null crashes when voice input misses.
  @HiveField(3)
  String hiveId;

  @HiveField(4)
  int heaveTest;

  @HiveField(5)
  int activity;

  @HiveField(6)
  String temperament;

  @HiveField(7)
  int sting;

  @HiveField(8)
  int hang;

  @HiveField(9)
  int run;

  @HiveField(10)
  int fly;

  @HiveField(11)
  String boxChange;

  @HiveField(12)
  String reducerChange;

  @HiveField(13)
  bool queenSeen;

  @HiveField(14)
  bool eggsSeen;

  @HiveField(15)
  int swarmCells;

  @HiveField(16)
  int supercedureCells;

  @HiveField(17)
  int framesOfBees;

  @HiveField(18)
  int honeySurplus;

  @HiveField(19)
  bool supplementalFeed;

  @HiveField(20)
  String feedProduct;

  @HiveField(21)
  double feedVolumeLiters;

  @HiveField(22)
  int miteCount;

  @HiveField(23)
  String finalStrength;

  @HiveField(24)
  String primaryTodo;

  @HiveField(25)
  String photoWebViewLink;

  @HiveField(26)
  String aiSummary;

  @HiveField(27)
  bool synced;

  Map<String, dynamic> toJson() => {
        'id': id,
        'createdAt': createdAt.toIso8601String(),
        'location': location,
        'hiveId': hiveId,
        'heaveTest': heaveTest,
        'activity': activity,
        'temperament': temperament,
        'sting': sting,
        'hang': hang,
        'run': run,
        'fly': fly,
        'boxChange': boxChange,
        'reducerChange': reducerChange,
        'queenSeen': queenSeen,
        'eggsSeen': eggsSeen,
        'swarmCells': swarmCells,
        'supercedureCells': supercedureCells,
        'framesOfBees': framesOfBees,
        'honeySurplus': honeySurplus,
        'supplementalFeed': supplementalFeed,
        'feedProduct': feedProduct,
        'feedVolumeLiters': feedVolumeLiters,
        'miteCount': miteCount,
        'finalStrength': finalStrength,
        'primaryTodo': primaryTodo,
        'photoWebViewLink': photoWebViewLink,
        'aiSummary': aiSummary,
        'synced': synced,
      };
}
