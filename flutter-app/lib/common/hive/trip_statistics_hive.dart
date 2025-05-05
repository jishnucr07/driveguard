import 'package:driveguard/common/hive/trip_data_hive_model.dart';
import 'package:hive/hive.dart';

class TripStatisticsService {
  // Get the highest max speed from all stored trips
  static double getHighestMaxSpeed() {
    final tripHistoryBox = Hive.box<TripData>('trip_history');

    if (tripHistoryBox.isEmpty) {
      return 0.0; // Return default if no trips are stored
    }

    double highestSpeed = 0.0;

    for (int i = 0; i < tripHistoryBox.length; i++) {
      final trip = tripHistoryBox.getAt(i);
      if (trip != null && trip.maxSpeed > highestSpeed) {
        highestSpeed = trip.maxSpeed;
      }
    }

    return highestSpeed;
  }

  // Get the best driving score
  static double getBestDrivingScore() {
    final tripHistoryBox = Hive.box<TripData>('trip_history');

    if (tripHistoryBox.isEmpty) {
      return 0.0;
    }

    double bestScore = 0.0;

    for (int i = 0; i < tripHistoryBox.length; i++) {
      final trip = tripHistoryBox.getAt(i);
      if (trip != null && trip.drivingScore > bestScore) {
        bestScore = trip.drivingScore;
      }
    }

    return bestScore;
  }

  // Get total number of trips
  static int getTotalTrips() {
    final tripHistoryBox = Hive.box<TripData>('trip_history');
    return tripHistoryBox.length;
  }
}
