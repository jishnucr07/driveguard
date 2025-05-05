// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trip_data_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TripDataAdapter extends TypeAdapter<TripData> {
  @override
  final int typeId = 1;

  @override
  TripData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TripData(
      destinationName: fields[0] as String,
      maxSpeed: fields[1] as double,
      speedLimit: fields[2] as double,
      latStart: fields[3] as double,
      lngStart: fields[4] as double,
      weather: (fields[5] as Map).cast<String, dynamic>(),
      roads: (fields[6] as Map).cast<String, dynamic>(),
      accidentPred: fields[7] as double,
      drivingScore: fields[8] as double,
      timestamp: fields[9] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, TripData obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.destinationName)
      ..writeByte(1)
      ..write(obj.maxSpeed)
      ..writeByte(2)
      ..write(obj.speedLimit)
      ..writeByte(3)
      ..write(obj.latStart)
      ..writeByte(4)
      ..write(obj.lngStart)
      ..writeByte(5)
      ..write(obj.weather)
      ..writeByte(6)
      ..write(obj.roads)
      ..writeByte(7)
      ..write(obj.accidentPred)
      ..writeByte(8)
      ..write(obj.drivingScore)
      ..writeByte(9)
      ..write(obj.timestamp);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TripDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
