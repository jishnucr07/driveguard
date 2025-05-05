import 'package:driveguard/common/hive/trip_data_hive_model.dart';
import 'package:driveguard/features/home/presentation/ui/widgets/chart.dart';
import 'package:driveguard/features/home/presentation/ui/widgets/map_widget_notnav.dart';
import 'package:driveguard/features/home/presentation/ui/widgets/road_details_widget.dart';
import 'package:driveguard/features/home/presentation/ui/widgets/speed_limit.dart';
import 'package:driveguard/features/home/presentation/ui/widgets/weather_widget.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  int _selectedTripIndex = 0;
  late Box<TripData> _tripHistoryBox;

  @override
  void initState() {
    super.initState();
    _tripHistoryBox = Hive.box<TripData>('trip_history');
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            'History',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.white,
        ),
        drawer: _buildHistoryDrawer(),
        body: _tripHistoryBox.isEmpty
            ? const Center(
                child: Text('No trip history available'),
              )
            : _buildTripDetails(_tripHistoryBox.getAt(_selectedTripIndex)!),
      ),
    );
  }

  Widget _buildHistoryDrawer() {
    return Drawer(
      child: Column(
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Center(
              child: Text(
                'DriveGuard History',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
          ),
          Expanded(
            child: _tripHistoryBox.isEmpty
                ? const Center(child: Text('No trips saved'))
                : ListView.builder(
                    itemCount: _tripHistoryBox.length,
                    itemBuilder: (context, index) {
                      final trip = _tripHistoryBox.getAt(index)!;
                      final formattedDate = DateFormat('MMM d, y - h:mm a')
                          .format(trip.timestamp);

                      return ListTile(
                        selected: _selectedTripIndex == index,
                        leading: const Icon(Icons.directions_car),
                        title: Text(trip.destinationName),
                        subtitle: Text(formattedDate),
                        trailing: Text(
                          'Score: ${trip.drivingScore.toStringAsFixed(1)}',
                          style: TextStyle(
                            color: _getScoreColor(trip.drivingScore),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onTap: () {
                          setState(() {
                            _selectedTripIndex = index;
                          });
                          Navigator.pop(context); // Close drawer
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }

  Widget _buildTripDetails(TripData trip) {
    double dh = MediaQuery.of(context).size.height;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      trip.destinationName,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium!
                          .copyWith(color: Colors.black),
                    ),
                    Text(
                      DateFormat('MMM d, y - h:mm a').format(trip.timestamp),
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: const Color.fromARGB(255, 111, 111, 111),
                          ),
                    ),
                  ],
                ),
                // Chip(
                //   label: Text(
                //     'Score: ${trip.drivingScore.toStringAsFixed(1)}',
                //     style: const TextStyle(
                //       color: Colors.white,
                //       fontWeight: FontWeight.bold,
                //     ),
                //   ),
                //   backgroundColor: _getScoreColor(trip.drivingScore),
                // ),
              ],
            ),
            const SizedBox(height: 20),

            // Map
            MapWidgetNotNav(
              destinationLocation: trip.startPos,
              destinationName: trip.destinationName,
              dh: dh,
            ),

            const SizedBox(height: 20),

            // Row of widgets
            Row(
              children: [
                EventPieChart(
                  isEnd: true,
                  eventPercentage: trip.drivingScore,
                ),
                const SizedBox(width: 11),
                Column(
                  children: [
                    SpeedLimitWidget2(
                      maxSpeed:
                          (trip.maxSpeed.ceil() < 1 ? 0 : trip.maxSpeed.ceil())
                              .toString(),
                    ),
                    const SizedBox(height: 20),
                    WeatherWidget(
                      temperature: trip.weather['main']?['temp'] ?? 0,
                      weatherCondition: trip.weather['weather']?[0]
                              ['description'] ??
                          'Unknown',
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Road details
            RoadDetailsWidget(
              roadType: trip.roads['road_type'] ?? 'Unknown',
              roadSurface: trip.roads['surface'] ?? 'Unknown',
            ),

            const SizedBox(height: 20),

            // Additional trip info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.speed),
                      title: const Text('Speed Limit'),
                      subtitle: Text(
                          'Limit: ${trip.speedLimit.toStringAsFixed(0)} km/h'),
                      // trailing: Text(
                      //     'Limit: ${trip.speedLimit.toStringAsFixed(0)} km/h'),
                    ),
                    ListTile(
                      leading: const Icon(Icons.warning),
                      title: const Text('Accident Prediction'),
                      subtitle: Text(
                          '${(trip.accidentPred * 100).toStringAsFixed(1)}%'),
                      trailing: Icon(
                        Icons.circle,
                        color: trip.accidentPred < 0.3
                            ? Colors.green
                            : trip.accidentPred < 0.6
                                ? Colors.orange
                                : Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
