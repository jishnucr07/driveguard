import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart';

// class SpeedTile extends StatefulWidget {
//   const SpeedTile({
//     super.key,
//   });

//   @override
//   State<SpeedTile> createState() => _SpeedTileState();
// }

// class _SpeedTileState extends State<SpeedTile> {
//   double _currentSpeed = 0.0;
//   bool _isTracking = false;

//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     _checkLocationPermission();
//   }

//   Future<void> _checkLocationPermission() async {
//     bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       // Location services are disabled
//       return;
//     }

//     LocationPermission permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) {
//         // Permissions are denied
//         return;
//       }
//     }

//     if (permission == LocationPermission.deniedForever) {
//       // Permissions are permanently denied
//       return;
//     }

//     // Start tracking speed
//     _startSpeedTracking();
//   }

//   void _startSpeedTracking() {
//     setState(() {
//       _isTracking = true;
//     });

//     Geolocator.getPositionStream().listen((Position position) {
//       setState(() {
//         _currentSpeed = position.speed; // Speed in meters per second
//       });
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     double dh = MediaQuery.of(context).size.height;

//     double dw = MediaQuery.of(context).size.width;
//     return Container(
//       height: dh * 0.06,
//       width: dw * 0.33,
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(25),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(8.0).copyWith(left: 20),
//         child: Row(
//           children: [
//             SizedBox(
//                 height: dh * 0.038,
//                 width: dh * 0.038,
//                 child: Image.asset('assets/png/icons/meter.png')),
//             SizedBox(
//               width: 10,
//             ),
//             Text(
//               //! This controls the decimal pointers of speed
//               (_currentSpeed * 3.6).toStringAsFixed(0),
//               style:
//                   Theme.of(context).textTheme.bodyLarge!.copyWith(fontSize: 20),
//             ),
//             SizedBox(
//               width: 5,
//             ),
//             Text(
//               'Km/h',
//               style: Theme.of(context)
//                   .textTheme
//                   .titleSmall!
//                   .copyWith(fontSize: 12),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }

class SpeedTile extends StatefulWidget {
  final Function(double)? onSpeedUpdate; // Callback for speed updates
  const SpeedTile({super.key, this.onSpeedUpdate});

  @override
  State<SpeedTile> createState() => _SpeedTileState();
}

class _SpeedTileState extends State<SpeedTile> {
  double _currentSpeed = 0.0;
  bool _isTracking = false;
  StreamSubscription<Position>?
      _positionStreamSubscription; // Store the stream subscription

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
  }

  @override
  void dispose() {
    // Cancel the stream subscription when the widget is disposed
    _positionStreamSubscription?.cancel();
    super.dispose();
  }

  Future<void> _checkLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return;
    }

    _startSpeedTracking();
  }

  void _startSpeedTracking() {
    setState(() {
      _isTracking = true;
    });

    // Listen to the position stream
    _positionStreamSubscription =
        Geolocator.getPositionStream().listen((Position position) {
      if (mounted) {
        // Check if the widget is still mounted
        setState(() {
          _currentSpeed = position.speed; // Speed in meters per second
          // Notify parent widget about speed updates
          if (widget.onSpeedUpdate != null) {
            widget.onSpeedUpdate!(_currentSpeed * 3.6); // Convert to km/h
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double dh = MediaQuery.of(context).size.height;
    double dw = MediaQuery.of(context).size.width;

    return Container(
      height: dh * 0.06,
      width: dw * 0.33,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0).copyWith(left: 20),
        child: Row(
          children: [
            SizedBox(
                height: dh * 0.038,
                width: dh * 0.038,
                child: Image.asset('assets/png/icons/meter.png')),
            const SizedBox(width: 10),
            Text(
              (_currentSpeed * 3.6)
                  .toStringAsFixed(0), // Convert to km/h and format
              style:
                  Theme.of(context).textTheme.bodyLarge!.copyWith(fontSize: 20),
            ),
            const SizedBox(width: 5),
            Text(
              'Km/h',
              style: Theme.of(context)
                  .textTheme
                  .titleSmall!
                  .copyWith(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
