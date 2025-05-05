import 'dart:convert';
import 'package:hive/hive.dart';

// Type adapter for storing Map<String, dynamic> in Hive
class MapAdapter extends TypeAdapter<Map<String, dynamic>> {
  @override
  final int typeId = 2; // Different from TripData's typeId

  @override
  Map<String, dynamic> read(BinaryReader reader) {
    final jsonString = reader.readString();
    return json.decode(jsonString) as Map<String, dynamic>;
  }

  @override
  void write(BinaryWriter writer, Map<String, dynamic> obj) {
    writer.writeString(json.encode(obj));
  }
}

// Add this to your main.dart initialization:
// Hive.registerAdapter(MapAdapter());
