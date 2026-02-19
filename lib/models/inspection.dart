import 'package:hive/hive.dart';

part 'inspection.g.dart';

@HiveType(typeId: 0)
class Inspection extends HiveObject {
  @HiveField(0) late String date;
  @HiveField(1) late String hiveId;
  @HiveField(2) late String location;
  @HiveField(3) bool isSynced = false;
  
  // Biological Data
  @HiveField(4) String? strength;
  @HiveField(5) bool? queenSeen;
  @HiveField(6) bool? eggs;
  @HiveField(7) int? miteCount;
  
  // BI & Labor Data
  @HiveField(8) int? laborMinutes;
  @HiveField(9) double? feedVol;
  @HiveField(10) String? photoUrl;
  
  // AI Insights
  @HiveField(11) String? aiDiagnosis;
  @HiveField(12) String? aiSummary;

  Map<String, dynamic> toJson() => {
    'date': date, 'hiveId': hiveId, 'location': location,
    'strength': strength, 'miteCount': miteCount,
    'photoUrl': photoUrl, 'aiSummary': aiSummary,
  };
}