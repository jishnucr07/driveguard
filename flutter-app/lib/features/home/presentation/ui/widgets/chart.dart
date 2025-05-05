import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';

class EventPieChart extends StatelessWidget {
  final double eventPercentage; // Pass the event percentage (e.g., 40)
  final bool isEnd;
  const EventPieChart(
      {super.key, required this.eventPercentage, this.isEnd = false});

  @override
  Widget build(BuildContext context) {
    double remainingPercentage = 100 - eventPercentage;

    return Container(
      height: MediaQuery.of(context).size.height *
          0.26, // Keep container size the same
      width: MediaQuery.of(context).size.width * 0.5,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
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
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 16, top: 16),
            child: isEnd
                ? Text(
                    'Driving Score',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  )
                : Text(
                    'Predicted Accident Probability', // Title of the chart
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black, // Match the event color
                    ),
                  ),
          ),
          Expanded(
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 0,
                      centerSpaceRadius: 35, // Reduced center space radius
                      startDegreeOffset: 180,
                      sections: [
                        PieChartSectionData(
                          color: Colors.blue, // Color for the event percentage
                          value: eventPercentage,
                          radius: 40, // Reduced radius of the chart sections
                          title: '0',
                          titleStyle: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        PieChartSectionData(
                          color: Colors
                              .grey[200], // Color for the remaining percentage
                          value: remainingPercentage,
                          radius: 30, // Reduced radius of the chart sections
                          title: '',
                        ),
                      ],
                    ),
                    swapAnimationDuration: Duration(milliseconds: 500),
                    swapAnimationCurve: Curves.easeInOut,
                  ),
                ),
                Center(
                  child: Container(
                    width: 70, // Reduced size of the center circle
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Center(
                      child: isEnd
                          ? Text(
                              eventPercentage.toStringAsFixed(0),
                              style: TextStyle(
                                fontSize: 23, // Slightly smaller font size
                                fontWeight: FontWeight.bold,
                                color: Colors.blue, // Match the event color
                              ),
                            )
                          : Text(
                              '${eventPercentage.toStringAsFixed(1)}%',
                              style: TextStyle(
                                fontSize: 20, // Slightly smaller font size
                                fontWeight: FontWeight.bold,
                                color: Colors.blue, // Match the event color
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
