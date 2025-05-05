import 'package:driveguard/common/hive/trip_data_hive_model.dart';
import 'package:driveguard/features/history/presentation/history_page.dart';
import 'package:driveguard/features/home/presentation/ui/accident_prediction_page.dart';
import 'package:driveguard/features/home/presentation/ui/home_page.dart';
import 'package:driveguard/features/home/presentation/ui/widgets/chart.dart';
import 'package:driveguard/features/home/presentation/ui/widgets/map_widget_notnav.dart';
import 'package:driveguard/features/home/presentation/ui/widgets/speed_limit.dart';
import 'package:driveguard/features/home/presentation/ui/widgets/weather_widget.dart';
import 'package:driveguard/features/ml%20section/logic/cubit/driving_score_cubit.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forked_slider_button/forked_slider_button.dart';
import 'package:hive/hive.dart';
import 'package:latlong2/latlong.dart';

import '../../home/presentation/ui/widgets/road_details_widget.dart';

class EndPage extends StatefulWidget {
  final String destinationName;
  final double maxSpeed;
  final double speedLimit;
  final LatLng startPos;
  final Map<String, dynamic> weather;
  final Map<String, dynamic> roads;
  final double accidentPred;

  const EndPage({
    Key? key,
    required this.destinationName,
    required this.startPos,
    required this.weather,
    required this.roads,
    required this.accidentPred,
    required this.maxSpeed,
    required this.speedLimit,
  }) : super(key: key);

  @override
  State<EndPage> createState() => _EndPageState();
}

class _EndPageState extends State<EndPage> {
  bool _dataSaved = false;

  @override
  void initState() {
    super.initState();
    context.read<DrivingScoreCubit>().calculateScore(
          maxSpeed: widget.maxSpeed,
          speedLimit: widget.speedLimit,
          accidentPercentage: widget.accidentPred,
        );
  }

  Future<void> _saveDataToHive(double drivingScore) async {
    if (_dataSaved) return; // Prevent duplicate saves

    final tripHistoryBox = Hive.box<TripData>('trip_history');

    final tripData = TripData(
      destinationName: widget.destinationName,
      maxSpeed: widget.maxSpeed,
      speedLimit: widget.speedLimit,
      latStart: widget.startPos.latitude,
      lngStart: widget.startPos.longitude,
      weather: widget.weather,
      roads: widget.roads,
      accidentPred: widget.accidentPred,
      drivingScore: drivingScore,
      timestamp: DateTime.now(),
    );

    await tripHistoryBox.add(tripData);
    _dataSaved = true;

    // Optional: Show a snackbar to confirm data was saved
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Trip data saved!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DrivingScoreCubit, DrivingScoreState>(
      builder: (context, state) {
        if (state is DrivingScoreLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (state is DrivingScoreSuccess) {
          return Scaffold(
            body: _buildLoadedUI(
              context,
              widget.weather,
              widget.roads,
              state.drivingScore,
            ),
          );
        }
        return const Scaffold(
          body: Center(child: Text("Something went wrong!")),
        );
      },
    );
  }

  Widget _buildLoadedUI(
    BuildContext context,
    Map<String, dynamic> weather,
    Map<String, dynamic> road,
    double? drivingScore,
  ) {
    double dh = MediaQuery.of(context).size.height;
    double dw = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.all(25.0),
      child: Column(
        children: [
          const SizedBox(height: 50),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'DriveGuard',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Text(
                    'Lets Drive Safer',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: const Color.fromARGB(255, 111, 111, 111),
                        ),
                  ),
                ],
              ),
              // Add a button to navigate to history
              ElevatedButton.icon(
                icon: const Icon(Icons.history),
                label: const Text('History'),
                onPressed: () async {
                  // Save data before navigating if not saved already
                  if (!_dataSaved &&
                      drivingScore != null &&
                      !drivingScore.isNaN) {
                    await _saveDataToHive(drivingScore);
                  }
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const HistoryPage()),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          MapWidgetNotNav(
            destinationLocation: widget.startPos,
            destinationName: widget.destinationName,
            dh: dh,
          ),

          const SizedBox(height: 20),

          //! The row of widgets
          Row(
            children: [
              // EventPieChart with null check
              drivingScore == null || drivingScore.isNaN
                  ? const CircularProgressIndicator()
                  : EventPieChart(
                      isEnd: true,
                      eventPercentage: drivingScore,
                    ),
              const SizedBox(width: 11),
              Column(
                children: [
                  // SpeedLimitWidget with null check
                  widget.maxSpeed.isNaN
                      ? const CircularProgressIndicator()
                      : SpeedLimitWidget2(
                          maxSpeed: (widget.maxSpeed.ceil() < 1
                                  ? 0
                                  : widget.maxSpeed.ceil())
                              .toString(),
                        ),
                  const SizedBox(height: 20),
                  // WeatherWidget with null check
                  weather['main']?['temp'] == null ||
                          weather['weather']?[0]['description'] == null
                      ? const CircularProgressIndicator()
                      : WeatherWidget(
                          temperature: weather['main']?['temp'] ?? 0,
                          weatherCondition: weather['weather']?[0]
                                  ['description'] ??
                              'Unknown',
                        ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 20),
          // RoadDetailsWidget with null check
          road['road_type'] == null || road['surface'] == null
              ? const CircularProgressIndicator()
              : RoadDetailsWidget(
                  roadType: road['road_type'] ?? 'Unknown',
                  roadSurface: road['surface'] ?? 'Unknown',
                ),

          const SizedBox(height: 35),
          CustomSliderButton2(
            title: 'Swipe for home',
            imagePath: 'assets/png/icons/previous.png',
            func: () async {
              // Save data when slider button is clicked
              if (drivingScore != null && !drivingScore.isNaN) {
                await _saveDataToHive(drivingScore);
              }

              await Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                    builder: (context) => HomePage()), // Push HomePage
                (Route<dynamic> route) => false, // Remove all routes
              );
            },
          ),
          const Expanded(child: SizedBox()),
        ],
      ),
    );
  }
}
