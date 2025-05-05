import 'package:http/http.dart' as http;
import 'dart:convert';

class WeatherService {
  final String apiKey;

  WeatherService(this.apiKey);

  Future<Map<String, dynamic>> getWeather(double lat, double lon) async {
    final url = Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$apiKey&units=metric');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    throw Exception('Failed to load weather data');
  }

  Future<Map<String, dynamic>> getHourlyWeather(double lat, double lon) async {
    final url = Uri.parse(
        'https://api.openweathermap.org/data/2.5/forecast?lat=$lat&lon=$lon&appid=$apiKey&units=metric');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    throw Exception('Failed to load weather data');
  }
}
