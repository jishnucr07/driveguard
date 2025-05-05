import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RoadDetailsWidget extends StatelessWidget {
  final String roadType;
  final String roadSurface;
  const RoadDetailsWidget(
      {super.key, required this.roadType, required this.roadSurface});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      width: double.infinity,
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
      child: Padding(
        padding: const EdgeInsets.all(13.0).copyWith(left: 23),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
                height: 50,
                width: 50,
                child: Image.asset('assets/png/icons/road.png')),
            Padding(
              padding: const EdgeInsets.all(10.0).copyWith(left: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Surface',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    roadSurface.toUpperCase(),
                    style: GoogleFonts.poppins(
                        fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              width: 1,
              height: 60,
              color: Colors.grey,
            ),
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Type',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    formatRoadType(roadType),
                    style: GoogleFonts.poppins(
                        fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String formatRoadType(String roadType) {
    return roadType
        .replaceAll('_', ' ') // Replace underscores with spaces
        .split(' ') // Split into words
        .map((word) =>
            word[0].toUpperCase() + word.substring(1)) // Capitalize each word
        .join(' '); // Join words back into a string
  }
}
