import 'package:hive/hive.dart';
part 'inspection.g.dart';

@HiveType(typeId: 0)
class Inspection extends HiveObject {
  @HiveField(0) String date = DateTime.now().toIso8601String();
  @HiveField(1) String hiveId = "Unknown";
  @HiveField(2) String location = "Unassigned";
  @HiveField(3) bool isSynced = false;

  @HiveField(4) int? heaveTest;
  @HiveField(5) int? activity;
  @HiveField(6) String? temperament;
  @HiveField(7) int? sting;
  @HiveField(8) int? hang;
  @HiveField(9) int? run;
  @HiveField(10) int? fly;
  @HiveField(11) String? hardwareNotes;
  @HiveField(12) bool? queenSeen;
  @HiveField(13) bool? eggs;
  @HiveField(14) bool? cells;
  @HiveField(15) int? fob;
  @HiveField(16) int? surplusFrames;
  @HiveField(17) bool? feeding;
  @HiveField(18) String? feedProd;
  @HiveField(19) double? feedVol;
  @HiveField(20) int? miteCount;
  @HiveField(21) String? strength;
  @HiveField(22) String? nextVisit;

  // NEW: Fields to specifically match your 2026 Spring Voice Engine
  @HiveField(23) String? broodPattern; // For the "Brood Pattern %" question
  @HiveField(24) String? swarmSigns;   // For the "Swarming/Queen Cells" question

  Map<String, dynamic> toJson() => {
    'date': date, 'hiveId': hiveId, 'location': location,
    'heaveTest': heaveTest, 'activity': activity, 'temperament': temperament,
    'sting': sting, 'hang': hang, 'run': run, 'fly': fly,
    'hardwareNotes': hardwareNotes, 'queenSeen': queenSeen, 'eggs': eggs,
    'cells': cells, 'fob': fob, 'surplusFrames': surplusFrames,
    'feeding': feeding, 'feedProd': feedProd, 'feedVol': feedVol,
    'miteCount': miteCount, 'strength': strength, 'nextVisit': nextVisit,
    'broodPattern': broodPattern, 'swarmSigns': swarmSigns,
  };
}