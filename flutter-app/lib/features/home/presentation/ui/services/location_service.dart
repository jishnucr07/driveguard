import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LocationService {
  Future<Position> getCurrentLocation() async {
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  Future<String> reverseGeocode(Position position) async {
    try {
      final response = await http.get(
        Uri.parse(
            'https://nominatim.openstreetmap.org/reverse?format=json&lat=${position.latitude}&lon=${position.longitude}&zoom=18&addressdetails=1'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data['display_name'] ?? 'Unknown location';
      }
    } catch (e) {
      print('Error reverse geocoding: $e');
    }
    return 'Unknown location';
  }

  Future<List<Map<String, dynamic>>> searchPlaces(String query) async {
    if (query.length < 3) return [];

    try {
      final response = await http.get(
        Uri.parse(
            'https://nominatim.openstreetmap.org/search?format=json&q=$query&limit=5'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data
            .map((place) => {
                  'name': place['display_name'],
                  'lat': double.parse(place['lat']),
                  'lon': double.parse(place['lon']),
                })
            .toList();
      }
    } catch (e) {
      print('Error searching places: $e');
    }
    return [];
  }
}
