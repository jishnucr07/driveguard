import 'package:driveguard/features/home/presentation/ui/widgets/chart.dart';
import 'package:driveguard/features/home/presentation/ui/widgets/map_widget_notnav.dart';
import 'package:driveguard/features/home/presentation/ui/widgets/road_details_widget.dart';
import 'package:driveguard/features/home/presentation/ui/widgets/speed_limit.dart';
import 'package:driveguard/features/home/presentation/ui/widgets/weather_widget.dart';
import 'package:driveguard/features/map/map_page.dart';
import 'package:driveguard/features/ml%20section/ui/start_screen.dart';
import 'package:driveguard/features/widgets/home_slider.dart';
import 'package:flutter/material.dart';
import 'package:forked_slider_button/forked_slider_button.dart';
import 'package:latlong2/latlong.dart';

class AccidentPredictionPage extends StatefulWidget {
  final String destinationName;
  final LatLng destinationLocation;
  final Map<String, dynamic> weather;
  final Map<String, dynamic> roads;
  final double accidentPred;
  final LatLng startPos;

  const AccidentPredictionPage({
    Key? key,
    required this.destinationName,
    required this.destinationLocation,
    required this.weather,
    required this.roads,
    required this.accidentPred,
    required this.startPos,
  }) : super(key: key);

  @override
  State<AccidentPredictionPage> createState() => _AccidentPredictionPageState();
}

class _AccidentPredictionPageState extends State<AccidentPredictionPage> {
  @override
  void initState() {
    super.initState();
    // Fetch weather and road data
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildLoadedUI(
        context,
        widget.weather,
        widget.roads,
      ),
    );
  }

  Widget _buildLoadedUI(
    BuildContext context,
    Map<String, dynamic> weather,
    Map<String, dynamic> road,
  ) {
    final dh = MediaQuery.of(context).size.height;
    final dw = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.all(25.0),
      child: Column(
        children: [
          const SizedBox(height: 50),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
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
            ],
          ),
          const SizedBox(height: 20),
          MapWidgetNotNav(
            destinationLocation: widget.destinationLocation,
            destinationName: widget.destinationName,
            dh: dh,
          ),

          const SizedBox(height: 20),

          //! The row of widgets
          Row(
            children: [
              EventPieChart(
                eventPercentage: widget.accidentPred * 100,
              ),
              const SizedBox(width: 11),
              Column(
                children: [
                  SpeedLimitWidget(
                    speedLimit: road['speed_limit'] as String? ?? 'nil',
                  ),
                  const SizedBox(height: 20),
                  WeatherWidget(
                    temperature:
                        (weather['main'] as Map<String, dynamic>)?['temp'] ??
                            '0',
                    weatherCondition: (weather['weather'] as List<dynamic>)?[0]
                                ?['description']
                            ?.toString() ??
                        'Unknown',
                  ),
                ],
              )
            ],
          ),

          const SizedBox(height: 20),
          RoadDetailsWidget(
              roadType: road['road_type'] as String? ?? 'Unknown',
              roadSurface: road['surface'] as String? ?? 'Unknown'),

          const SizedBox(height: 20),
          CustomSliderButton2(
            title: 'Swipe to Start Tracking',
            imagePath: 'assets/png/icons/previous.png',
            func: () async {
              await Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (context) => StartScreen(
                        accidentPred: widget.accidentPred,
                        destinationLocation: widget.destinationLocation,
                        destinationName: widget.destinationName,
                        roads: widget.roads,
                        weather: widget.weather,
                        startPos: widget.startPos,
                      )));
            },
          ),
        ],
      ),
    );
  }
}

class CustomSliderButton2 extends StatelessWidget {
  final Future<bool?> Function() func;
  final String title;
  final String imagePath;
  const CustomSliderButton2({
    super.key,
    required this.title,
    required this.func,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return SliderButton(
      dismissible: false,
      width: 300,
      height: 80,
      action: func,
      label: Text(
        title,
        style: const TextStyle(
          color: Color(0xff4a4a4a),
          fontWeight: FontWeight.w500,
          fontSize: 17,
        ),
      ),
      icon: SizedBox(
        height: 20,
        width: 20,
        child: Image.asset(imagePath),
      ),
    );
  }
}
