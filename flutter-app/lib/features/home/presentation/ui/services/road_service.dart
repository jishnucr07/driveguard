import 'package:http/http.dart' as http;
import 'dart:convert';

class RoadService {
  Future<Map<String, dynamic>> getRoadData(double lat, double lon) async {
    final overpassUrl = "https://overpass-api.de/api/interpreter";
    final query = '''
      [out:json][timeout:25];
      way(around:50, $lat, $lon)[highway];
      out body;
      >;
      out skel qt;
    ''';

    final response = await http.post(Uri.parse(overpassUrl), body: query);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      for (var element in data['elements']) {
        if (element['tags'] != null) {
          return {
            'road_type': element['tags']['highway'],
            'speed_limit': element['tags']['maxspeed'],
            'surface': element['tags']['surface'],
          };
        }
      }
    }
    throw Exception('Failed to load road data');
  }
}
