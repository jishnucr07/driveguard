import 'package:http/http.dart' as http;
import 'dart:convert';

class PredictionService {
  static const String serverUrl = 'http://192.168.185.113:5000/send_data';

  static Future<void> sendSensorData(List<List<double>> data) async {
    try {
      // Ensure the data has the correct shape (10 time steps, 14 features)
      if (data.length != 10 || data.any((row) => row.length != 14)) {
        throw Exception('Invalid data shape. Expected (10, 14).');
      }

      final response = await http.post(
        Uri.parse(serverUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'data': data,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to send data: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error sending data: $e');
    }
  }

  static Future<double> calculateDriverScore() async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.185.113:5000/calculate_score'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return responseData['driver_score'];
      } else {
        throw Exception('Failed to calculate score: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error calculating score: $e');
    }
  }
}
