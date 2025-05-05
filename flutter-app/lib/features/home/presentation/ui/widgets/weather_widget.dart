import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WeatherWidget extends StatelessWidget {
  final String weatherCondition;
  final num temperature; // Change to num

  const WeatherWidget({
    super.key,
    required this.weatherCondition,
    required this.temperature,
  });

  // Function to get the appropriate icon based on the weather condition
  IconData _getWeatherIcon(String condition) {
    switch (condition.toLowerCase()) {
      case 'sunny':
        return Icons.wb_sunny;
      case 'cloudy':
        return Icons.cloud;
      case 'rainy':
        return Icons.beach_access;
      case 'snowy':
        return Icons.ac_unit;
      case 'thunderstorm':
        return Icons.flash_on;
      case 'windy':
        return Icons.air;
      default:
        return Icons.wb_cloudy; // Default icon for unknown conditions
    }
  }

  @override
  Widget build(BuildContext context) {
    double dh = MediaQuery.of(context).size.height;
    double dw = MediaQuery.of(context).size.width;

    return Container(
      height: dh * 0.08,
      width: dw * 0.35,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3), // Shadow for elevation
          ),
        ],
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            Colors.grey.shade100, // Highlight for 3D effect
          ],
        ),
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getWeatherIcon(weatherCondition), // Dynamically choose icon
              size: 40,
              color: Colors.blue, // Customize icon color
            ),
            const SizedBox(
              width: 8,
            ),
            Text(
              '${temperature.toDouble().toStringAsFixed(0)}°C', // Convert to double
              style: GoogleFonts.ptSans(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
