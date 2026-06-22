// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schedule_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ScheduleModelAdapter extends TypeAdapter<ScheduleModel> {
  @override
  final int typeId = 1;

  @override
  ScheduleModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ScheduleModel(
      id: fields[0] as String?,
      date: fields[1] as DateTime,
      tasks: (fields[2] as List).cast<TaskModel>(),
      totalTasks: fields[3] as int,
      completedTasks: fields[4] as int,
      pendingTasks: fields[5] as int,
      missedTasks: fields[6] as int,
      completionPercentage: fields[7] as double,
      totalDuration: fields[8] as int,
      productiveHours: fields[9] as int,
      breakHours: fields[10] as int,
      createdAt: fields[11] as DateTime?,
      updatedAt: fields[12] as DateTime?,
      isAIGenerated: fields[13] as bool,
      aiPrompt: fields[14] as String?,
      aiProvider: fields[15] as String?,
      metadata: (fields[16] as Map?)?.cast<String, dynamic>(),
      notes: (fields[17] as List?)?.cast<String>(),
      tags: (fields[18] as List?)?.cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, ScheduleModel obj) {
    writer
      ..writeByte(19)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.tasks)
      ..writeByte(3)
      ..write(obj.totalTasks)
      ..writeByte(4)
      ..write(obj.completedTasks)
      ..writeByte(5)
      ..write(obj.pendingTasks)
      ..writeByte(6)
      ..write(obj.missedTasks)
      ..writeByte(7)
      ..write(obj.completionPercentage)
      ..writeByte(8)
      ..write(obj.totalDuration)
      ..writeByte(9)
      ..write(obj.productiveHours)
      ..writeByte(10)
      ..write(obj.breakHours)
      ..writeByte(11)
      ..write(obj.createdAt)
      ..writeByte(12)
      ..write(obj.updatedAt)
      ..writeByte(13)
      ..write(obj.isAIGenerated)
      ..writeByte(14)
      ..write(obj.aiPrompt)
      ..writeByte(15)
      ..write(obj.aiProvider)
      ..writeByte(16)
      ..write(obj.metadata)
      ..writeByte(17)
      ..write(obj.notes)
      ..writeByte(18)
      ..write(obj.tags);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScheduleModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
