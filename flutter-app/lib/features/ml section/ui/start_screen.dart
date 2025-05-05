// import 'dart:async';
// import 'package:driveguard/features/history/presentation/end_page.dart';
// import 'package:driveguard/features/home/presentation/ui/home_page.dart';
// import 'package:driveguard/features/ml%20section/logic/cubit/sensor_data_cubit_cubit.dart';
// import 'package:driveguard/features/ml%20section/ui/widgets/hourly_weather.dart';
// import 'package:driveguard/features/ml%20section/ui/widgets/map_turn_by_turn.dart';
// import 'package:driveguard/features/ml%20section/ui/widgets/speed_tile.dart';
// import 'package:driveguard/features/widgets/home_slider.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:latlong2/latlong.dart';
// import 'package:sensors_plus/sensors_plus.dart';

// class StartScreen extends StatefulWidget {
//   final String destinationName;
//   final LatLng destinationLocation;
//   final Map<String, dynamic> weather;
//   final Map<String, dynamic> roads;
//   final LatLng startPos;
//   final double accidentPred;
//   const StartScreen({
//     super.key,
//     required this.destinationName,
//     required this.destinationLocation,
//     required this.weather,
//     required this.roads,
//     required this.startPos,
//     required this.accidentPred,
//   });

//   @override
//   State<StartScreen> createState() => _StartScreenState();
// }

// class _StartScreenState extends State<StartScreen> {
//   String _drivingBehavior = "Unknown";
//   double _driverScore = 0.0;
//   bool _isLoading = false;
//   List<List<double>> _sensorData = [];
//   double speedLimit = 50;
//   double _maxSpeed = 0.0; // Track maximum speed

//   StreamSubscription? _accelerometerSubscription;
//   StreamSubscription? _gyroscopeSubscription;

//   // Server IP (Update this with your correct IP)
//   final String serverIp = "192.168.209.113";

//   @override
//   void initState() {
//     super.initState();
//     if (mounted) {
//       _startSensorCollection();
//     }
//   }

//   @override
//   void dispose() {
//     _accelerometerSubscription?.cancel();
//     _gyroscopeSubscription?.cancel();
//     super.dispose();
//   }

//   // Start collecting accelerometer & gyroscope data
//   void _startSensorCollection() {
//     List<List<double>> tempData = [];

//     _accelerometerSubscription =
//         accelerometerEvents.listen((AccelerometerEvent event) {
//       if (tempData.length < 10) {
//         // Add 14 features (6 from sensors, 8 placeholders)
//         tempData
//             .add([event.x, event.y, event.z, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]);
//       }
//     });

//     _gyroscopeSubscription = gyroscopeEvents.listen((GyroscopeEvent event) {
//       if (tempData.isNotEmpty && tempData.length <= 10) {
//         int lastIndex = tempData.length - 1;
//         // Update gyroscope data (features 3, 4, 5)
//         tempData[lastIndex][3] = event.x;
//         tempData[lastIndex][4] = event.y;
//         tempData[lastIndex][5] = event.z;
//       }

//       if (tempData.length == 10) {
//         setState(() {
//           _sensorData = tempData;
//         });
//         if (mounted) {
//           context.read<SensorDataCubitCubit>().sendSensorData(_sensorData);
//         }
//         tempData = []; // Reset after sending
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     double dh = MediaQuery.of(context).size.height;
//     double dw = MediaQuery.of(context).size.width;

//     return Scaffold(
//       body: BlocConsumer<SensorDataCubitCubit, SensorDataCubitState>(
//         listener: (context, state) {
//           // Handle state changes if needed
//         },
//         builder: (context, state) {
//           // Check if the driving behavior is aggressive
//           bool isAggressiveDriving = state is SensorDatasentSuceessState &&
//               state.behaviour == 'Aggressive Driving';

//           return Stack(
//             children: [
//               // Main Content
//               Padding(
//                 padding: const EdgeInsets.all(25.0),
//                 child: Column(
//                   children: [
//                     const SizedBox(height: 50),
//                     WeatherForecastWidget(dh: dh),
//                     const SizedBox(height: 20),
//                     Container(
//                       height: dh * 0.20,
//                       width: double.infinity,
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(20),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.grey.withOpacity(0.5),
//                             spreadRadius: 2,
//                             blurRadius: 5,
//                             offset: const Offset(0, 3),
//                           ),
//                         ],
//                       ),
//                       child: Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 12.0),
//                         child: Column(
//                           children: [
//                             SpeedTile(
//                               onSpeedUpdate: (double speed) {
//                                 // Update max speed if current speed exceeds it
//                                 if (speed > _maxSpeed) {
//                                   setState(() {
//                                     _maxSpeed = speed;
//                                   });
//                                 }
//                               },
//                             ),
//                             const SizedBox(height: 10),
//                             if (state is SensorDataFail)
//                               Text(
//                                 '${state.error}',
//                                 style: GoogleFonts.actor(
//                                     fontSize: 35,
//                                     fontStyle: FontStyle.italic,
//                                     color: Colors.green),
//                               ),
//                             if (state is SensorDataInprogress)
//                               const CircularProgressIndicator(),
//                             if (state is SensorDatasentSuceessState)
//                               Text(
//                                 '${state.behaviour}',
//                                 style: GoogleFonts.actor(
//                                     fontSize: 35,
//                                     fontStyle: FontStyle.italic,
//                                     color: isAggressiveDriving
//                                         ? Colors.red
//                                         : Colors.green),
//                               ),
//                           ],
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 30),
//                     MapWidgetTurnByTurn(
//                       destinationName: widget.destinationName,
//                       destinationLocation: widget.destinationLocation,
//                       dh: dh,
//                     ),
//                     const Expanded(child: SizedBox()),
//                   ],
//                 ),
//               ),

//               // Red Border for Aggressive Driving
//               if (isAggressiveDriving)
//                 AnimatedContainer(
//                   duration: const Duration(milliseconds: 300),
//                   decoration: BoxDecoration(
//                     border: Border.all(
//                       color: Colors.red,
//                       width: 10,
//                     ),
//                   ),
//                 ),
//             ],
//           );
//         },
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           print('max speed = $_maxSpeed');
//           // End tracking and navigate to the next screen
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(
//               builder: (context) => EndPage(
//                   weather: widget.weather,
//                   roads: widget.roads,
//                   accidentPred: widget.accidentPred,
//                   speedLimit:
//                       double.tryParse(widget.roads['speed_limit'].toString()) ??
//                           0,
//                   destinationName: widget.destinationName,
//                   startPos: widget.startPos,
//                   maxSpeed: _maxSpeed),
//             ),
//           );
//         },
//         child: const Icon(Icons.stop), // Stop icon
//         backgroundColor: Colors.red, // Red color for visibility
//       ),
//     );
//   }
// }

import 'dart:async';
import 'dart:math';
import 'package:driveguard/features/history/presentation/end_page.dart';
import 'package:driveguard/features/home/presentation/ui/home_page.dart';
import 'package:driveguard/features/ml%20section/logic/cubit/sensor_data_cubit_cubit.dart';
import 'package:driveguard/features/ml%20section/ui/widgets/hourly_weather.dart';
import 'package:driveguard/features/ml%20section/ui/widgets/map_turn_by_turn.dart';
import 'package:driveguard/features/ml%20section/ui/widgets/speed_tile.dart';
import 'package:driveguard/features/widgets/home_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vibration/vibration.dart';

class StartScreen extends StatefulWidget {
  final String destinationName;
  final LatLng destinationLocation;
  final Map<String, dynamic> weather;
  final Map<String, dynamic> roads;
  final LatLng startPos;
  final double accidentPred;
  const StartScreen({
    super.key,
    required this.destinationName,
    required this.destinationLocation,
    required this.weather,
    required this.roads,
    required this.startPos,
    required this.accidentPred,
  });

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  String _drivingBehavior = "Unknown";
  double _driverScore = 0.0;
  bool _isLoading = false;
  List<List<double>> _sensorData = [];
  double speedLimit = 50;
  double _maxSpeed = 0.0; // Track maximum speed

  // Emergency feature variables
  bool _crashDetected = false;
  int _countdownSeconds = 15;
  Timer? _emergencyTimer;
  Timer? _countdownTimer;

  // Threshold values for crash detection
  final double _accelerationThreshold = 20.0; // G-force threshold
  final double _rotationThreshold = 15.0; // rad/s threshold

  StreamSubscription? _accelerometerSubscription;
  StreamSubscription? _gyroscopeSubscription;

  // Emergency number
  final String emergencyNumber = "132";

  // Server IP (Update this with your correct IP)
  final String serverIp = "192.168.209.113";

  @override
  void initState() {
    super.initState();
    if (mounted) {
      _startSensorCollection();
    }
  }

  @override
  void dispose() {
    _accelerometerSubscription?.cancel();
    _gyroscopeSubscription?.cancel();
    _emergencyTimer?.cancel();
    _countdownTimer?.cancel();
    super.dispose();
  }

  // Start collecting accelerometer & gyroscope data
  void _startSensorCollection() {
    List<List<double>> tempData = [];

    _accelerometerSubscription =
        accelerometerEvents.listen((AccelerometerEvent event) {
      // Check for potential crash based on acceleration
      double acceleration = _calculateMagnitude(event.x, event.y, event.z);

      if (tempData.length < 10) {
        // Add 14 features (6 from sensors, 8 placeholders)
        tempData
            .add([event.x, event.y, event.z, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]);
      }

      // Check for crash based on acceleration
      if (acceleration > _accelerationThreshold && !_crashDetected) {
        _handlePotentialCrash();
      }
    });

    _gyroscopeSubscription = gyroscopeEvents.listen((GyroscopeEvent event) {
      // Check for potential crash based on rotation
      double rotation = _calculateMagnitude(event.x, event.y, event.z);

      if (tempData.isNotEmpty && tempData.length <= 10) {
        int lastIndex = tempData.length - 1;
        // Update gyroscope data (features 3, 4, 5)
        tempData[lastIndex][3] = event.x;
        tempData[lastIndex][4] = event.y;
        tempData[lastIndex][5] = event.z;
      }

      if (tempData.length == 10) {
        setState(() {
          _sensorData = tempData;
        });
        if (mounted) {
          context.read<SensorDataCubitCubit>().sendSensorData(_sensorData);
        }
        tempData = []; // Reset after sending
      }

      // Check for crash based on gyroscope
      if (rotation > _rotationThreshold && !_crashDetected) {
        _handlePotentialCrash();
      }
    });
  }

  // Calculate magnitude of a 3D vector
  double _calculateMagnitude(double x, double y, double z) {
    return sqrt(x * x + y * y + z * z);
  }

  // Handle potential crash event
  void _handlePotentialCrash() {
    if (_crashDetected) return; // Prevent multiple triggers

    setState(() {
      _crashDetected = true;
    });

    // Play alert sound and vibrate
    _playEmergencyAlert();

    // Start countdown timer
    _startEmergencyCountdown();
  }

  // Play alert sound and vibration
  void _playEmergencyAlert() {
    // Vibrate in pattern
    if (Vibration.hasVibrator() != null) {
      Vibration.vibrate(pattern: [500, 1000, 500, 1000], repeat: 0);
    }
  }

  // Stop alert sounds and vibration
  void _stopEmergencyAlert() {
    Vibration.cancel();
  }

  // Start emergency countdown
  void _startEmergencyCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_countdownSeconds > 0) {
          _countdownSeconds--;
        } else {
          _countdownTimer?.cancel();
          _makeEmergencyCall();
        }
      });
    });
  }

  // Cancel emergency process
  void _cancelEmergency() {
    setState(() {
      _crashDetected = false;
      _countdownSeconds = 15;
    });
    _countdownTimer?.cancel();
    _stopEmergencyAlert();
  }

  // Make emergency call
  void _makeEmergencyCall() async {
    final Uri phoneUri = Uri(scheme: "tel", path: emergencyNumber);
    try {
      await launchUrl(phoneUri);
    } catch (e) {
      print("Could not make emergency call: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    double dh = MediaQuery.of(context).size.height;
    double dw = MediaQuery.of(context).size.width;

    return Scaffold(
      body: BlocConsumer<SensorDataCubitCubit, SensorDataCubitState>(
        listener: (context, state) {
          // Handle state changes if needed
        },
        builder: (context, state) {
          // Check if the driving behavior is aggressive
          bool isAggressiveDriving = state is SensorDatasentSuceessState &&
              state.behaviour == 'Aggressive Driving';

          return Stack(
            children: [
              // Main Content
              Padding(
                padding: const EdgeInsets.all(25.0),
                child: Column(
                  children: [
                    const SizedBox(height: 50),
                    WeatherForecastWidget(dh: dh),
                    const SizedBox(height: 20),
                    Container(
                      height: dh * 0.20,
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
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: Column(
                          children: [
                            SpeedTile(
                              onSpeedUpdate: (double speed) {
                                // Update max speed if current speed exceeds it
                                if (speed > _maxSpeed) {
                                  setState(() {
                                    _maxSpeed = speed;
                                  });
                                }
                              },
                            ),
                            const SizedBox(height: 10),
                            if (state is SensorDataFail)
                              Text(
                                '${state.error}',
                                style: GoogleFonts.actor(
                                    fontSize: 35,
                                    fontStyle: FontStyle.italic,
                                    color: Colors.green),
                              ),
                            if (state is SensorDataInprogress)
                              const CircularProgressIndicator(),
                            if (state is SensorDatasentSuceessState)
                              Text(
                                '${state.behaviour}',
                                style: GoogleFonts.actor(
                                    fontSize: 35,
                                    fontStyle: FontStyle.italic,
                                    color: isAggressiveDriving
                                        ? Colors.red
                                        : Colors.green),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    MapWidgetTurnByTurn(
                      destinationName: widget.destinationName,
                      destinationLocation: widget.destinationLocation,
                      dh: dh,
                    ),
                    const Expanded(child: SizedBox()),
                  ],
                ),
              ),

              // Red Border for Aggressive Driving
              if (isAggressiveDriving)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.red,
                      width: 10,
                    ),
                  ),
                ),

              // Emergency countdown overlay
              if (_crashDetected)
                Container(
                  color: Colors.black.withOpacity(0.8),
                  width: double.infinity,
                  height: double.infinity,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "CRASH DETECTED",
                        style: GoogleFonts.roboto(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "Calling emergency services in",
                        style: GoogleFonts.roboto(
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.red, width: 5),
                        ),
                        child: Center(
                          child: Text(
                            "$_countdownSeconds",
                            style: GoogleFonts.roboto(
                              fontSize: 60,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      ElevatedButton(
                        onPressed: _cancelEmergency,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 50,
                            vertical: 15,
                          ),
                        ),
                        child: Text(
                          "I'm OK",
                          style: GoogleFonts.roboto(
                            fontSize: 20,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          print('max speed = $_maxSpeed');
          // End tracking and navigate to the next screen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => EndPage(
                  weather: widget.weather,
                  roads: widget.roads,
                  accidentPred: widget.accidentPred,
                  speedLimit:
                      double.tryParse(widget.roads['speed_limit'].toString()) ??
                          1,
                  destinationName: widget.destinationName,
                  startPos: widget.startPos,
                  maxSpeed: _maxSpeed),
            ),
          );
        },
        child: const Icon(Icons.stop), // Stop icon
        backgroundColor: Colors.red, // Red color for visibility
      ),
    );
  }
}
