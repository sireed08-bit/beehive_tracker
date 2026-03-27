// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inspection.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class InspectionAdapter extends TypeAdapter<Inspection> {
  @override
  final int typeId = 0;

  @override
  Inspection read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Inspection()
      ..date = fields[0] as String
      ..hiveId = fields[1] as String
      ..location = fields[2] as String
      ..isSynced = fields[3] as bool
      ..heaveTest = fields[4] as int?
      ..activity = fields[5] as int?
      ..temperament = fields[6] as String?
      ..sting = fields[7] as int?
      ..hang = fields[8] as int?
      ..run = fields[9] as int?
      ..fly = fields[10] as int?
      ..hardwareNotes = fields[11] as String?
      ..queenSeen = fields[12] as bool?
      ..eggs = fields[13] as bool?
      ..cells = fields[14] as bool?
      ..fob = fields[15] as int?
      ..surplusFrames = fields[16] as int?
      ..feeding = fields[17] as bool?
      ..feedProd = fields[18] as String?
      ..feedVol = fields[19] as double?
      ..miteCount = fields[20] as int?
      ..strength = fields[21] as String?
      ..nextVisit = fields[22] as String?
      ..broodPattern = fields[23] as String?
      ..swarmSigns = fields[24] as String?;
  }

  @override
  void write(BinaryWriter writer, Inspection obj) {
    writer
      ..writeByte(25)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.hiveId)
      ..writeByte(2)
      ..write(obj.location)
      ..writeByte(3)
      ..write(obj.isSynced)
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
      ..write(obj.hardwareNotes)
      ..writeByte(12)
      ..write(obj.queenSeen)
      ..writeByte(13)
      ..write(obj.eggs)
      ..writeByte(14)
      ..write(obj.cells)
      ..writeByte(15)
      ..write(obj.fob)
      ..writeByte(16)
      ..write(obj.surplusFrames)
      ..writeByte(17)
      ..write(obj.feeding)
      ..writeByte(18)
      ..write(obj.feedProd)
      ..writeByte(19)
      ..write(obj.feedVol)
      ..writeByte(20)
      ..write(obj.miteCount)
      ..writeByte(21)
      ..write(obj.strength)
      ..writeByte(22)
      ..write(obj.nextVisit)
      ..writeByte(23)
      ..write(obj.broodPattern)
      ..writeByte(24)
      ..write(obj.swarmSigns);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InspectionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
