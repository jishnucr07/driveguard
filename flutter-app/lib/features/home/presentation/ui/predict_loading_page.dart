import 'package:driveguard/features/home/presentation/ui/accident_prediction_page.dart';
import 'package:driveguard/features/home/presentation/ui/accident_translater.dart';
import 'package:driveguard/features/home/presentation/ui/services/cubit/road_cubit.dart';
import 'package:driveguard/features/home/presentation/ui/services/cubit/weather_cubit.dart';
import 'package:driveguard/features/ml%20section/logic/cubit/accident_pred.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';

class PredictLoadingPage extends StatefulWidget {
  final String destinationName;
  final LatLng destinationLocation;
  final int passengers;
  final String vehicle;
  final LatLng startPos;

  const PredictLoadingPage({
    Key? key,
    required this.destinationName,
    required this.destinationLocation,
    required this.passengers,
    required this.vehicle,
    required this.startPos,
  }) : super(key: key);

  @override
  _PredictLoadingPageState createState() => _PredictLoadingPageState();
}

class _PredictLoadingPageState extends State<PredictLoadingPage> {
  @override
  void initState() {
    super.initState();
    print(widget.destinationLocation);
    context.read<WeatherCubit>().fetchWeather(
          widget.destinationLocation.latitude,
          widget.destinationLocation.longitude,
        );
    context.read<RoadCubit>().fetchRoadData(
          widget.destinationLocation.latitude,
          widget.destinationLocation.longitude,
        );
  }

  late Map<String, dynamic> weather = {};
  late Map<String, dynamic> roads = {};
  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<WeatherCubit, WeatherState>(
          listener: (context, state) {
            if (state is WeatherLoading) {
              print('Weather Loading');
            }
            if (state is WeatherError) {
              print('Weather ${state.message}');
            }
            if (state is WeatherLoaded) {
              setState(() {
                weather = state.weather;
              });
            }
            print('$weather is loaded');
          },
        ),
        BlocListener<RoadCubit, RoadState>(
          listener: (context, state) {
            if (state is RoadLoading) {
              print('Road Loading');
            }
            if (state is RoadError) {
              print('Road ${state.message}');
            }
            if (state is RoadLoaded) {
              setState(() {
                roads = state.road;
              });
              print('$roads is loaded');
              if (roads.isNotEmpty && weather.isNotEmpty) {
                //! remove after test
                // Navigator.of(context).push(MaterialPageRoute(
                //     builder: (context) => AccidentPredictionPage(
                //         weather: weather,
                //         roads: roads,
                //         destinationName: widget.destinationName,
                //         destinationLocation: widget.destinationLocation)));
                //!

                final now = DateTime.now();
                final hour = now.hour;
                // Get current time
                final tnow = DateTime.now();
                final thour = now.hour; // This is already in 24-hour format

// Determine day/night
                final timeOfDay = (thour >= 18 || thour <= 6) ? "Night" : "Day";

// Format time as 24-hour string (HH:MM:SS)
                final time24hFormat = '${now.hour.toString().padLeft(2, '0')}:'
                    '${now.minute.toString().padLeft(2, '0')}:'
                    '${now.second.toString().padLeft(2, '0')}';
                final roadLightCondition =
                    (timeOfDay == "Night") ? "Street Lights" : "Daylight";

                Map<String, dynamic> inputData2 = {
                  "Speed_Limit":
                      int.tryParse(roads['speed_limit'].toString()) ?? 0,
                  "Number_of_Vehicles": 1,
                  "Driver_Age": 30,
                  "Driver_Experience": 5,
                  "Weather": weather['weather']?[0]['description'] ?? "Unknown",
                  "Road_Type": roads['road_type'] ?? "City Road",
                  "Time_of_Day": time24hFormat,
                  "Traffic_Density": 1,
                  "Accident_Severity": "Minor",
                  "Road_Condition": roads['surface'] ?? "Unknown",
                  "Vehicle_Type": widget.vehicle,
                  "Road_Light_Condition": timeOfDay.toLowerCase(),
                };

                // print('Input data : $inputData');
// //!EXTREME
                // Map<String, dynamic> inputData2 = {
                //   "Speed_Limit": 120, // Extremely high speed
                //   "Number_of_Vehicles": 5, // Heavy traffic
                //   "Driver_Age": 18, // Youngest legal driver
                //   "Driver_Experience": 0, // Just got license
                //   "Weather": "thunderstorm with heavy rain",
                //   "Road_Type": "mountain_pass", // Dangerous road
                //   "Time_of_Day": "23:45:00", // Nighttime
                //   "Traffic_Density": 3, // Heavy traffic
                //   "Accident_Severity": "Fatal", // Worst severity
                //   "Road_Condition": "icy", // Most dangerous condition
                //   "Vehicle_Type": "motorcycle", // Least protected
                //   "Road_Light_Condition": "night", // Poor visibility
                // };
// //!uRBAN
                // Map<String, dynamic> inputData2 = {
                //   "Speed_Limit": 50,
                //   "Number_of_Vehicles": 2,
                //   "Driver_Age": 35,
                //   "Driver_Experience": 10,
                //   "Weather": "clear sky",
                //   "Road_Type": "city_road",
                //   "Time_of_Day": "09:00:00", // Morning
                //   "Traffic_Density": 1,
                //   "Accident_Severity": "Minor",
                //   "Road_Condition": "dry",
                //   "Vehicle_Type": "car",
                //   "Road_Light_Condition": "day",
                // };
// //!Rainy
                // Map<String, dynamic> inputData2 = {
                //   "Speed_Limit": 70,
                //   "Number_of_Vehicles": 4,
                //   "Driver_Age": 40,
                //   "Driver_Experience": 15,
                //   "Weather": "light rain",
                //   "Road_Type": "highway",
                //   "Time_of_Day": "18:30:00", // Evening
                //   "Traffic_Density": 2,
                //   "Accident_Severity": "Moderate",
                //   "Road_Condition": "wet",
                //   "Vehicle_Type": "SUV",
                //   "Road_Light_Condition": "dusk",
                // };
// //!Night
                // Map<String, dynamic> inputData2 = {
                //   "Speed_Limit": 110,
                //   "Number_of_Vehicles": 4,
                //   "Driver_Age": 18,
                //   "Driver_Experience": 0,
                //   "Weather": "thunderstorm with heavy rain",
                //   "Road_Type": "mountain_pass",
                //   "Time_of_Day": "23:50:00",
                //   "Traffic_Density": 3,
                //   "Road_Condition": "icy",
                //   "Vehicle_Type": "motorcycle",
                //   "Road_Light_Condition": "night",
                // };
                Map<String, dynamic> inputData =
                    AccidentInputTranslator.translateAccidentInput(inputData2);
                print(inputData);
                context.read<AccidentPredCubit>().accidentPrediction(inputData);
              } else {
                print("road = $roads weather = $weather");
              }
            }
          },
        )
      ],
      child: Scaffold(
        body:

            // Text('$roads, $weather')

            BlocListener<AccidentPredCubit, AccidentPredState>(
          listener: (context, state) {
            if (state is AccidentPredSuccessState) {
              print('Accident prediction = ${state.accidentPred}');
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (context) => AccidentPredictionPage(
                      startPos: widget.startPos,
                      accidentPred: state.accidentPred,
                      weather: weather,
                      roads: roads,
                      destinationName: widget.destinationName,
                      destinationLocation: widget.destinationLocation)));
            }
          },
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }
}
