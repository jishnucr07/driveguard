import 'package:hive/hive.dart';
import 'package:latlong2/latlong.dart';

part 'trip_data_hive_model.g.dart';

@HiveType(typeId: 1)
class TripData extends HiveObject {
  @HiveField(0)
  final String destinationName;

  @HiveField(1)
  final double maxSpeed;

  @HiveField(2)
  final double speedLimit;

  @HiveField(3)
  final double latStart;

  @HiveField(4)
  final double lngStart;

  @HiveField(5)
  final Map<String, dynamic> weather;

  @HiveField(6)
  final Map<String, dynamic> roads;

  @HiveField(7)
  final double accidentPred;

  @HiveField(8)
  final double drivingScore;

  @HiveField(9)
  final DateTime timestamp;

  TripData({
    required this.destinationName,
    required this.maxSpeed,
    required this.speedLimit,
    required this.latStart,
    required this.lngStart,
    required this.weather,
    required this.roads,
    required this.accidentPred,
    required this.drivingScore,
    required this.timestamp,
  });

  // Helper method to convert stored lat/lng to LatLng object
  LatLng get startPos => LatLng(latStart, lngStart);
}
