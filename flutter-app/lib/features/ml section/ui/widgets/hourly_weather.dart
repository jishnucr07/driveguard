import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart'; // For 12-hour time format

class WeatherForecastWidget extends StatefulWidget {
  final double dh; // Device height for responsive design

  const WeatherForecastWidget({super.key, required this.dh});

  @override
  _WeatherForecastWidgetState createState() => _WeatherForecastWidgetState();
}

class _WeatherForecastWidgetState extends State<WeatherForecastWidget> {
  List<Map<String, dynamic>> _forecastData = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchWeatherData();
    _startPeriodicUpdate();
  }

  // Fetch weather data based on current location
  Future<void> _fetchWeatherData() async {
    try {
      // Get current location
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      // Fetch weather data
      final response = await http.get(Uri.parse(
          'https://api.openweathermap.org/data/2.5/forecast?lat=${position.latitude}&lon=${position.longitude}&appid=f61e8249ba643a28748205d6a232b577&units=metric'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _forecastData = List<Map<String, dynamic>>.from(data['list']);
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load weather data');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  // Start periodic updates every 10 minutes
  void _startPeriodicUpdate() {
    Timer.periodic(const Duration(minutes: 10), (timer) {
      _fetchWeatherData();
    });
  }

  // Check if the weather is dangerous for driving
  bool _isDangerousWeather(String weatherName) {
    const dangerousWeathers = ['Rain', 'Snow', 'Thunderstorm', 'Drizzle'];
    return dangerousWeathers.contains(weatherName);
  }

  // Check if the weather name is different from the previous one and dangerous
  bool _shouldHighlightWeather(int index) {
    if (index > 0) {
      String currentWeather = _forecastData[index]['weather'][0]['main'];
      String previousWeather = _forecastData[index - 1]['weather'][0]['main'];
      return currentWeather != previousWeather &&
          _isDangerousWeather(currentWeather);
    }
    return false;
  }

  // Split the forecast data into chunks of 6 items for pagination
  List<List<Map<String, dynamic>>> _chunkForecastData() {
    List<List<Map<String, dynamic>>> chunks = [];
    for (var i = 0; i < _forecastData.length; i += 6) {
      chunks.add(_forecastData.sublist(
          i, i + 6 > _forecastData.length ? _forecastData.length : i + 6));
    }
    return chunks;
  }

  @override
  Widget build(BuildContext context) {
    final chunks = _chunkForecastData();

    return Container(
      height: widget.dh * 0.2, // Increased height to accommodate weather name
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage))
              : PageView.builder(
                  itemCount: chunks.length,
                  itemBuilder: (context, pageIndex) {
                    final chunk = chunks[pageIndex];
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: chunk.map((forecast) {
                        final time = DateTime.fromMillisecondsSinceEpoch(
                            forecast['dt'] * 1000);
                        final weatherIcon = forecast['weather'][0]['icon'];
                        final weatherName = forecast['weather'][0]['main'];
                        final temperature = forecast['main']['temp'].round();
                        final shouldHighlight = _shouldHighlightWeather(
                            _forecastData.indexOf(forecast));

                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              weatherName, // Weather name (e.g., "Clear", "Clouds")
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: shouldHighlight
                                    ? Colors.red
                                    : Colors
                                        .black, // Only change color for dangerous weather changes
                              ),
                            ),
                            const SizedBox(height: 5),
                            Image.network(
                              'https://openweathermap.org/img/wn/$weatherIcon@2x.png',
                              width: 60, // Larger icons
                              height: 60,
                            ),
                            const SizedBox(height: 5),
                            Text(
                              DateFormat('h a').format(time), // 12-hour format
                              style: const TextStyle(
                                fontWeight: FontWeight.normal,
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              '$temperature°C',
                              style: const TextStyle(
                                fontWeight: FontWeight.normal,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    );
                  },
                ),
    );
  }
}
