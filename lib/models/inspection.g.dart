// GENERATED CODE - MANUALLY CURATED FOR SAMPLE PROJECT.

part of 'inspection.dart';

class InspectionAdapter extends TypeAdapter<Inspection> {
  @override
  final int typeId = 0;

  @override
  Inspection read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };

    return Inspection(
      id: fields[0] as String?,
      createdAt: fields[1] as DateTime?,
      location: fields[2] as String? ?? 'Unknown Yard',
      hiveId: fields[3] as String? ?? 'Unknown',
      heaveTest: fields[4] as int? ?? 0,
      activity: fields[5] as int? ?? 0,
      temperament: fields[6] as String? ?? 'Calm',
      sting: fields[7] as int? ?? 0,
      hang: fields[8] as int? ?? 0,
      run: fields[9] as int? ?? 0,
      fly: fields[10] as int? ?? 0,
      boxChange: fields[11] as String? ?? 'None',
      reducerChange: fields[12] as String? ?? 'None',
      queenSeen: fields[13] as bool? ?? false,
      eggsSeen: fields[14] as bool? ?? false,
      swarmCells: fields[15] as int? ?? 0,
      supercedureCells: fields[16] as int? ?? 0,
      framesOfBees: fields[17] as int? ?? 0,
      honeySurplus: fields[18] as int? ?? 0,
      supplementalFeed: fields[19] as bool? ?? false,
      feedProduct: fields[20] as String? ?? 'None',
      feedVolumeLiters: fields[21] as double? ?? 0,
      miteCount: fields[22] as int? ?? 0,
      finalStrength: fields[23] as String? ?? 'Medium',
      primaryTodo: fields[24] as String? ?? 'None',
      photoWebViewLink: fields[25] as String? ?? '',
      aiSummary: fields[26] as String? ?? '',
      synced: fields[27] as bool? ?? false,
    );
  }

  @override
  void write(BinaryWriter writer, Inspection obj) {
    writer
      ..writeByte(28)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.createdAt)
      ..writeByte(2)
      ..write(obj.location)
      ..writeByte(3)
      ..write(obj.hiveId)
      ..writeByte(4)
      ..write(obj.heaveTest)
      ..writeByte(5)
      ..write(obj.activity)
      ..writeByte(6)
      ..write(obj.temperament)
      ..writeByte(7)
      ..write(obj.sting)
      ..writeByte(8)
      ..write(obj.hang)
      ..writeByte(9)
      ..write(obj.run)
      ..writeByte(10)
      ..write(obj.fly)
      ..writeByte(11)
      ..write(obj.boxChange)
      ..writeByte(12)
      ..write(obj.reducerChange)
      ..writeByte(13)
      ..write(obj.queenSeen)
      ..writeByte(14)
      ..write(obj.eggsSeen)
      ..writeByte(15)
      ..write(obj.swarmCells)
      ..writeByte(16)
      ..write(obj.supercedureCells)
      ..writeByte(17)
      ..write(obj.framesOfBees)
      ..writeByte(18)
      ..write(obj.honeySurplus)
      ..writeByte(19)
      ..write(obj.supplementalFeed)
      ..writeByte(20)
      ..write(obj.feedProduct)
      ..writeByte(21)
      ..write(obj.feedVolumeLiters)
      ..writeByte(22)
      ..write(obj.miteCount)
      ..writeByte(23)
      ..write(obj.finalStrength)
      ..writeByte(24)
      ..write(obj.primaryTodo)
      ..writeByte(25)
      ..write(obj.photoWebViewLink)
      ..writeByte(26)
      ..write(obj.aiSummary)
      ..writeByte(27)
      ..write(obj.synced);
  }
}
