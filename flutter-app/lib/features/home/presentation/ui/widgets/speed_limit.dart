import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SpeedLimitWidget extends StatelessWidget {
  final String speedLimit;

  const SpeedLimitWidget({
    super.key,
    required this.speedLimit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120, // Size of the rounded square
      height: 120,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20), // Rounded corners
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ) // Shadow for elevation
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer ring
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.red, // Ring color
                width: 4, // Ring thickness
              ),
            ),
          ),
          // Speed limit text
          Text(
            speedLimit,
            style: GoogleFonts.ptSans(
              fontSize: 45,
              fontWeight: FontWeight.bold,
              color: Colors.black, // Text color
            ),
          ),
        ],
      ),
    );
  }
}

class SpeedLimitWidget2 extends StatelessWidget {
  final String maxSpeed;

  const SpeedLimitWidget2({
    super.key,
    required this.maxSpeed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120, // Size of the rounded square
      height: 120,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20), // Rounded corners
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ), // Shadow for elevation
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Max Speed',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8), // Spacing between text and value
            Text(
              maxSpeed, // Replace with your dynamic value
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.blue[800],
              ),
            ),
            const SizedBox(height: 4), // Spacing between value and unit
            Text(
              'km/h', // Unit for the max limit
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
