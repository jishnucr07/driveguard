// // import 'package:flutter/material.dart';
// // import 'package:flutter_map/flutter_map.dart';
// // import 'package:latlong2/latlong.dart';
// // import 'package:geolocator/geolocator.dart';
// // import 'package:http/http.dart' as http;
// // import 'dart:convert';
// // import 'dart:async';
// // import 'package:flutter_tts/flutter_tts.dart';

// // class NavigationApp extends StatefulWidget {
// //   const NavigationApp({super.key});

// //   @override
// //   _NavigationAppState createState() => _NavigationAppState();
// // }

// // class _NavigationAppState extends State<NavigationApp> {
// //   final MapController mapController = MapController();
// //   LatLng? currentLocation;
// //   LatLng? destination;
// //   List<LatLng> routePoints = [];
// //   List<Instruction> instructions = [];
// //   int currentInstructionIndex = 0;
// //   bool isNavigating = false;
// //   final FlutterTts flutterTts = FlutterTts();
// //   Timer? locationUpdateTimer;
// //   final TextEditingController destinationController = TextEditingController();

// //   @override
// //   void initState() {
// //     super.initState();
// //     _getCurrentLocation();
// //     _initTts();
// //   }

// //   @override
// //   void dispose() {
// //     locationUpdateTimer?.cancel();
// //     destinationController.dispose();
// //     super.dispose();
// //   }

// //   void _initTts() async {
// //     await flutterTts.setLanguage("en-US");
// //     await flutterTts.setSpeechRate(0.5);
// //   }

// //   Future<void> _getCurrentLocation() async {
// //     bool serviceEnabled;
// //     LocationPermission permission;

// //     // Check if location services are enabled
// //     serviceEnabled = await Geolocator.isLocationServiceEnabled();
// //     if (!serviceEnabled) {
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         SnackBar(content: Text('Location services are disabled')),
// //       );
// //       return;
// //     }

// //     // Check for location permissions
// //     permission = await Geolocator.checkPermission();
// //     if (permission == LocationPermission.denied) {
// //       permission = await Geolocator.requestPermission();
// //       if (permission == LocationPermission.denied) {
// //         ScaffoldMessenger.of(context).showSnackBar(
// //           SnackBar(content: Text('Location permissions are denied')),
// //         );
// //         return;
// //       }
// //     }

// //     // Get current position
// //     Position position = await Geolocator.getCurrentPosition(
// //       desiredAccuracy: LocationAccuracy.high,
// //     );

// //     setState(() {
// //       currentLocation = LatLng(position.latitude, position.longitude);
// //       // Move map to current location using the correct mapController method
// //       mapController.move(currentLocation!, 15.0);
// //     });
// //   }

// //   void _startLocationUpdates() {
// //     locationUpdateTimer = Timer.periodic(Duration(seconds: 3), (timer) async {
// //       Position position = await Geolocator.getCurrentPosition(
// //         desiredAccuracy: LocationAccuracy.high,
// //       );

// //       setState(() {
// //         currentLocation = LatLng(position.latitude, position.longitude);
// //         mapController.move(currentLocation!, 15.0);
// //       });

// //       if (isNavigating) {
// //         _updateNavigation();
// //       }
// //     });
// //   }

// //   void _updateNavigation() {
// //     if (routePoints.isEmpty || currentLocation == null) return;

// //     // Find the closest point on the route to current location
// //     LatLng closestPoint = _findClosestPointOnRoute();
// //     int closestPointIndex = routePoints.indexOf(closestPoint);

// //     // Determine which instruction to show based on progress
// //     for (int i = 0; i < instructions.length; i++) {
// //       if (closestPointIndex < instructions[i].pointIndex) {
// //         if (i != currentInstructionIndex) {
// //           setState(() {
// //             currentInstructionIndex = i > 0 ? i - 1 : 0;
// //           });

// //           // Speak the instruction
// //           _speakInstruction(instructions[currentInstructionIndex]);
// //         }
// //         break;
// //       }
// //     }

// //     // Check if we've reached the destination
// //     double distanceToDestination =
// //         Distance().as(LengthUnit.Meter, currentLocation!, destination!);

// //     if (distanceToDestination < 20) {
// //       _endNavigation("You have reached your destination");
// //     }
// //   }

// //   LatLng _findClosestPointOnRoute() {
// //     double minDistance = double.infinity;
// //     LatLng closestPoint = routePoints.first;

// //     for (var point in routePoints) {
// //       double distance =
// //           Distance().as(LengthUnit.Meter, currentLocation!, point);
// //       if (distance < minDistance) {
// //         minDistance = distance;
// //         closestPoint = point;
// //       }
// //     }

// //     return closestPoint;
// //   }

// //   void _speakInstruction(Instruction instruction) {
// //     flutterTts.speak(instruction.text);
// //   }

// //   Future<void> _searchDestination(String query) async {
// //     final response = await http.get(
// //       Uri.parse(
// //           'https://nominatim.openstreetmap.org/search?format=json&q=$query'),
// //       headers: {'Accept': 'application/json'},
// //     );

// //     if (response.statusCode == 200) {
// //       final List data = json.decode(response.body);
// //       if (data.isNotEmpty) {
// //         setState(() {
// //           destination = LatLng(
// //               double.parse(data[0]['lat']), double.parse(data[0]['lon']));
// //         });
// //         _getRoute();
// //       } else {
// //         ScaffoldMessenger.of(context).showSnackBar(
// //           SnackBar(content: Text('Location not found')),
// //         );
// //       }
// //     }
// //   }

// //   Future<void> _getRoute() async {
// //     if (currentLocation == null || destination == null) return;

// //     final String baseUrl = 'https://router.project-osrm.org/route/v1/driving/';
// //     final String url =
// //         '$baseUrl${currentLocation!.longitude},${currentLocation!.latitude};${destination!.longitude},${destination!.latitude}?overview=full&steps=true&geometries=geojson';

// //     final response = await http.get(Uri.parse(url));

// //     if (response.statusCode == 200) {
// //       final data = json.decode(response.body);

// //       if (data['routes'] != null && data['routes'].isNotEmpty) {
// //         // Parse route geometry
// //         List<LatLng> points = [];
// //         List<dynamic> coordinates =
// //             data['routes'][0]['geometry']['coordinates'];
// //         for (var coord in coordinates) {
// //           points
// //               .add(LatLng(coord[1], coord[0])); // Note: GeoJSON uses [lng, lat]
// //         }

// //         // Parse instructions
// //         List<Instruction> routeInstructions = [];
// //         List<dynamic> steps = data['routes'][0]['legs'][0]['steps'];

// //         int pointIndex = 0;
// //         for (var step in steps) {
// //           String maneuver = step['maneuver']['type'];
// //           String direction = step['maneuver']['modifier'] ?? '';
// //           double distance = step['distance'].toDouble();
// //           int stepPointCount = step['geometry']['coordinates'].length;
// //           pointIndex += stepPointCount;

// //           String instructionText =
// //               _formatInstruction(maneuver, direction, distance);

// //           routeInstructions.add(
// //             Instruction(
// //               text: instructionText,
// //               distance: distance,
// //               pointIndex: pointIndex,
// //             ),
// //           );
// //         }

// //         setState(() {
// //           routePoints = points;
// //           instructions = routeInstructions;
// //           currentInstructionIndex = 0;
// //           isNavigating = true;
// //         });

// //         // Fit map to show route - using correct approach for newer flutter_map
// //         _fitMapToRoute();

// //         // Start location updates
// //         _startLocationUpdates();

// //         // Speak first instruction
// //         if (instructions.isNotEmpty) {
// //           _speakInstruction(instructions[0]);
// //         }
// //       }
// //     }
// //   }

// //   String _formatInstruction(
// //       String maneuver, String direction, double distance) {
// //     String distanceText = '';
// //     if (distance >= 1000) {
// //       distanceText = '${(distance / 1000).toStringAsFixed(1)} kilometers';
// //     } else {
// //       distanceText =
// //           '${distance.round()} meters'; // Fixed using round() instead of toInt()
// //     }

// //     String action = '';
// //     if (maneuver == 'turn') {
// //       action = 'Turn $direction in $distanceText';
// //     } else if (maneuver == 'continue') {
// //       action = 'Continue straight for $distanceText';
// //     } else if (maneuver == 'roundabout') {
// //       action = 'Take the roundabout $direction in $distanceText';
// //     } else if (maneuver == 'arrive') {
// //       action = 'Arrive at your destination';
// //     } else {
// //       action = '$maneuver $direction in $distanceText';
// //     }

// //     return action;
// //   }

// //   void _fitMapToRoute() {
// //     if (routePoints.isEmpty) return;

// //     double minLat = routePoints.first.latitude;
// //     double maxLat = routePoints.first.latitude;
// //     double minLng = routePoints.first.longitude;
// //     double maxLng = routePoints.first.longitude;

// //     for (var point in routePoints) {
// //       if (point.latitude < minLat) minLat = point.latitude;
// //       if (point.latitude > maxLat) maxLat = point.latitude;
// //       if (point.longitude < minLng) minLng = point.longitude;
// //       if (point.longitude > maxLng) maxLng = point.longitude;
// //     }

// //     // Create bounds and calculate center and zoom level manually
// //     LatLngBounds bounds = LatLngBounds(
// //       LatLng(minLat - 0.01, minLng - 0.01),
// //       LatLng(maxLat + 0.01, maxLng + 0.01),
// //     );

// //     // Instead of using fitBounds (which might not be available),
// //     // calculate center point and set appropriate zoom
// //     LatLng center = LatLng(
// //       (minLat + maxLat) / 2,
// //       (minLng + maxLng) / 2,
// //     );

// //     // A simple zoom calculation - you might want to improve this based on the bounds size
// //     double zoom = 12.0;
// //     mapController.move(center, zoom);
// //   }

// //   void _endNavigation(String message) {
// //     flutterTts.speak(message);
// //     setState(() {
// //       isNavigating = false;
// //       routePoints = [];
// //       instructions = [];
// //     });
// //     locationUpdateTimer?.cancel();
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: Text('Turn-by-Turn Navigation'),
// //         backgroundColor: Colors.blue,
// //       ),
// //       body: Stack(
// //         children: [
// //           FlutterMap(
// //             mapController: mapController,
// //             options: MapOptions(
// //               initialCenter: currentLocation ??
// //                   LatLng(0, 0), // Using initialCenter instead of center
// //               initialZoom: 15.0, // Using initialZoom instead of zoom
// //             ),
// //             children: [
// //               TileLayer(
// //                 urlTemplate:
// //                     'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
// //                 subdomains: const ['a', 'b', 'c'],
// //               ),
// //               // Route Polyline
// //               if (routePoints.isNotEmpty)
// //                 PolylineLayer(
// //                   polylines: [
// //                     Polyline(
// //                       points: routePoints,
// //                       strokeWidth: 4.0,
// //                       color: Colors.blue,
// //                     ),
// //                   ],
// //                 ),
// //               // Markers
// //               MarkerLayer(
// //                 markers: [
// //                   if (currentLocation != null)
// //                     Marker(
// //                       point: currentLocation!,
// //                       width: 40.0,
// //                       height: 40.0,
// //                       child: const Icon(
// //                         Icons.navigation,
// //                         color: Colors.blue,
// //                         size: 40.0,
// //                       ),
// //                     ),
// //                   if (destination != null)
// //                     Marker(
// //                       point: destination!,
// //                       width: 40.0,
// //                       height: 40.0,
// //                       child: const Icon(
// //                         Icons.location_on,
// //                         color: Colors.red,
// //                         size: 40.0,
// //                       ),
// //                     ),
// //                 ],
// //               ),
// //             ],
// //           ),
// //           // Destination search bar
// //           Positioned(
// //             top: 10,
// //             left: 10,
// //             right: 10,
// //             child: Container(
// //               padding: EdgeInsets.symmetric(horizontal: 10),
// //               decoration: BoxDecoration(
// //                 color: Colors.white,
// //                 borderRadius: BorderRadius.circular(5),
// //                 boxShadow: [
// //                   BoxShadow(
// //                     color: Colors.black26,
// //                     blurRadius: 5,
// //                     offset: Offset(0, 2),
// //                   ),
// //                 ],
// //               ),
// //               child: Row(
// //                 children: [
// //                   Expanded(
// //                     child: TextField(
// //                       controller: destinationController,
// //                       decoration: InputDecoration(
// //                         hintText: 'Enter destination',
// //                         border: InputBorder.none,
// //                       ),
// //                       onSubmitted: _searchDestination,
// //                     ),
// //                   ),
// //                   IconButton(
// //                     icon: Icon(Icons.search),
// //                     onPressed: () =>
// //                         _searchDestination(destinationController.text),
// //                   ),
// //                 ],
// //               ),
// //             ),
// //           ),
// //           // Navigation instructions panel
// //           if (isNavigating && instructions.isNotEmpty)
// //             Positioned(
// //               bottom: 20,
// //               left: 10,
// //               right: 10,
// //               child: Container(
// //                 padding: EdgeInsets.all(15),
// //                 decoration: BoxDecoration(
// //                   color: Colors.white,
// //                   borderRadius: BorderRadius.circular(10),
// //                   boxShadow: [
// //                     BoxShadow(
// //                       color: Colors.black26,
// //                       blurRadius: 5,
// //                       offset: Offset(0, 2),
// //                     ),
// //                   ],
// //                 ),
// //                 child: Column(
// //                   crossAxisAlignment: CrossAxisAlignment.start,
// //                   children: [
// //                     Text(
// //                       currentInstructionIndex < instructions.length
// //                           ? instructions[currentInstructionIndex].text
// //                           : 'Navigating...',
// //                       style: TextStyle(
// //                         fontSize: 18,
// //                         fontWeight: FontWeight.bold,
// //                       ),
// //                     ),
// //                     SizedBox(height: 5),
// //                     if (currentInstructionIndex + 1 < instructions.length)
// //                       Text(
// //                         'Next: ${instructions[currentInstructionIndex + 1].text}',
// //                         style: TextStyle(fontSize: 14),
// //                       ),
// //                     SizedBox(height: 10),
// //                     Row(
// //                       mainAxisAlignment: MainAxisAlignment.end,
// //                       children: [
// //                         ElevatedButton(
// //                           onPressed: () =>
// //                               _endNavigation('Navigation cancelled'),
// //                           child: Text('End Navigation'),
// //                           style: ButtonStyle(
// //                             backgroundColor:
// //                                 MaterialStateProperty.all<Color>(Colors.red),
// //                           ),
// //                         ),
// //                       ],
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //             ),
// //         ],
// //       ),
// //       floatingActionButton: currentLocation == null
// //           ? FloatingActionButton(
// //               onPressed: _getCurrentLocation,
// //               child: Icon(Icons.my_location),
// //             )
// //           : null,
// //     );
// //   }
// // }

// // class Instruction {
// //   final String text;
// //   final double distance;
// //   final int pointIndex;

// //   Instruction({
// //     required this.text,
// //     required this.distance,
// //     required this.pointIndex,
// //   });
// // }

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:flutter_tts/flutter_tts.dart';

class NavigationApp extends StatefulWidget {
  final String destinationName;
  final LatLng destinationLocation;
  const NavigationApp(
      {super.key,
      required this.destinationName,
      required this.destinationLocation});

  @override
  _NavigationAppState createState() => _NavigationAppState();
}

class _NavigationAppState extends State<NavigationApp> {
  final MapController mapController = MapController();
  LatLng? currentLocation;
  LatLng? destination;
  List<LatLng> originalRoutePoints = []; // Stores the complete original route
  List<LatLng> remainingRoutePoints =
      []; // Only stores points not yet traversed
  List<Instruction> instructions = [];
  int currentInstructionIndex = 0;
  bool isNavigating = false;
  final FlutterTts flutterTts = FlutterTts();
  Timer? locationUpdateTimer;
  final TextEditingController destinationController = TextEditingController();
  int lastPassedPointIndex = -1;

  @override
  void initState() {
    super.initState();

    _getCurrentLocation();
    _searchDestination(widget.destinationName);
    _initTts();
  }

  @override
  void dispose() {
    locationUpdateTimer?.cancel();
    destinationController.dispose();
    super.dispose();
  }

  void _initTts() async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setSpeechRate(0.5);
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Location services are disabled')),
      );
      return;
    }

    // Check for location permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Location permissions are denied')),
        );
        return;
      }
    }

    // Get current position
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      currentLocation = LatLng(position.latitude, position.longitude);
      mapController.move(currentLocation!, 15.0);
    });
  }

  void _startLocationUpdates() {
    locationUpdateTimer = Timer.periodic(Duration(seconds: 3), (timer) async {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      LatLng newLocation = LatLng(position.latitude, position.longitude);

      setState(() {
        currentLocation = newLocation;
        mapController.move(currentLocation!, 15.0);
      });

      if (isNavigating) {
        _updateNavigation();
      }
    });
  }

  void _updateNavigation() {
    if (originalRoutePoints.isEmpty || currentLocation == null) return;

    // Find the closest point on the route to current location
    int closestPointIndex = _findClosestPointIndexOnRoute();

    // Check if user progressed on the route
    if (closestPointIndex > lastPassedPointIndex) {
      // Update the route by removing passed segments
      setState(() {
        lastPassedPointIndex = closestPointIndex;
        remainingRoutePoints =
            List.from(originalRoutePoints.sublist(closestPointIndex));
      });
    }

    // Determine which instruction to show based on progress
    for (int i = 0; i < instructions.length; i++) {
      if (closestPointIndex < instructions[i].pointIndex) {
        if (i != currentInstructionIndex) {
          setState(() {
            currentInstructionIndex = i > 0 ? i - 1 : 0;
          });

          // Speak the instruction
          _speakInstruction(instructions[currentInstructionIndex]);
        }
        break;
      }
    }

    // Check if we've reached the destination
    if (destination != null) {
      double distanceToDestination =
          Distance().as(LengthUnit.Meter, currentLocation!, destination!);

      if (distanceToDestination < 20) {
        _endNavigation("You have reached your destination");
      }
    }
  }

  int _findClosestPointIndexOnRoute() {
    if (originalRoutePoints.isEmpty) return -1;

    double minDistance = double.infinity;
    int closestIndex = 0;

    for (int i = 0; i < originalRoutePoints.length; i++) {
      double distance = Distance()
          .as(LengthUnit.Meter, currentLocation!, originalRoutePoints[i]);
      if (distance < minDistance) {
        minDistance = distance;
        closestIndex = i;
      }
    }

    return closestIndex;
  }

  void _speakInstruction(Instruction instruction) {
    flutterTts.speak(instruction.text);
  }

  Future<void> _searchDestination(String query) async {
    final response = await http.get(
      Uri.parse(
          'https://nominatim.openstreetmap.org/search?format=json&q=$query'),
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      if (data.isNotEmpty) {
        setState(() {
          destination = LatLng(
              double.parse(data[0]['lat']), double.parse(data[0]['lon']));
        });
        _getRoute();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Location not found')),
        );
      }
    }
  }

  Future<void> _getRoute() async {
    if (currentLocation == null || destination == null) return;

    final String baseUrl = 'https://router.project-osrm.org/route/v1/driving/';
    final String url =
        '$baseUrl${currentLocation!.longitude},${currentLocation!.latitude};${destination!.longitude},${destination!.latitude}?overview=full&steps=true&geometries=geojson';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data['routes'] != null && data['routes'].isNotEmpty) {
        // Parse route geometry
        List<LatLng> points = [];
        List<dynamic> coordinates =
            data['routes'][0]['geometry']['coordinates'];
        for (var coord in coordinates) {
          points
              .add(LatLng(coord[1], coord[0])); // Note: GeoJSON uses [lng, lat]
        }

        // Parse instructions
        List<Instruction> routeInstructions = [];
        List<dynamic> steps = data['routes'][0]['legs'][0]['steps'];

        int pointIndex = 0;
        for (var step in steps) {
          String maneuver = step['maneuver']['type'];
          String direction = step['maneuver']['modifier'] ?? '';
          double distance = step['distance'].toDouble();
          int stepPointCount = step['geometry']['coordinates'].length;
          pointIndex += stepPointCount;

          String instructionText =
              _formatInstruction(maneuver, direction, distance);

          routeInstructions.add(
            Instruction(
              text: instructionText,
              distance: distance,
              pointIndex: pointIndex,
            ),
          );
        }

        setState(() {
          originalRoutePoints = points;
          remainingRoutePoints = List.from(points); // Start with all points
          instructions = routeInstructions;
          currentInstructionIndex = 0;
          isNavigating = true;
          lastPassedPointIndex = -1;
        });

        // Fit map to show route
        _fitMapToRoute();

        // Start location updates
        _startLocationUpdates();

        // Speak first instruction
        if (instructions.isNotEmpty) {
          _speakInstruction(instructions[0]);
        }
      }
    }
  }

  String _formatInstruction(
      String maneuver, String direction, double distance) {
    String distanceText = '';
    if (distance >= 1000) {
      distanceText = '${(distance / 1000).toStringAsFixed(1)} kilometers';
    } else {
      distanceText = '${distance.round()} meters';
    }

    String action = '';
    if (maneuver == 'turn') {
      action = 'Turn $direction in $distanceText';
    } else if (maneuver == 'continue') {
      action = 'Continue straight for $distanceText';
    } else if (maneuver == 'roundabout') {
      action = 'Take the roundabout $direction in $distanceText';
    } else if (maneuver == 'arrive') {
      action = 'Arrive at your destination';
    } else {
      action = '$maneuver $direction in $distanceText';
    }

    return action;
  }

  void _fitMapToRoute() {
    if (originalRoutePoints.isEmpty) return;

    double minLat = originalRoutePoints.first.latitude;
    double maxLat = originalRoutePoints.first.latitude;
    double minLng = originalRoutePoints.first.longitude;
    double maxLng = originalRoutePoints.first.longitude;

    for (var point in originalRoutePoints) {
      if (point.latitude < minLat) minLat = point.latitude;
      if (point.latitude > maxLat) maxLat = point.latitude;
      if (point.longitude < minLng) minLng = point.longitude;
      if (point.longitude > maxLng) maxLng = point.longitude;
    }

    // Calculate center point
    LatLng center = LatLng(
      (minLat + maxLat) / 2,
      (minLng + maxLng) / 2,
    );

    // Calculate appropriate zoom level
    double latDelta = (maxLat - minLat) * 1.1; // Add 10% padding
    double lngDelta = (maxLng - minLng) * 1.1;
    double maxDelta = latDelta > lngDelta ? latDelta : lngDelta;

    // Simple zoom calculation - adjust this based on your needs
    double zoom = 15.0;
    if (maxDelta > 0.1) zoom = 10.0;
    if (maxDelta > 0.5) zoom = 8.0;
    if (maxDelta > 2.0) zoom = 6.0;

    mapController.move(center, zoom);
  }

  void _endNavigation(String message) {
    flutterTts.speak(message);
    setState(() {
      isNavigating = false;
      originalRoutePoints = [];
      remainingRoutePoints = [];
      instructions = [];
      lastPassedPointIndex = -1;
    });
    locationUpdateTimer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    print(widget.destinationLocation);
    print(widget.destinationName);
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              initialCenter: currentLocation ?? LatLng(0, 0),
              initialZoom: 25.0,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: const ['a', 'b', 'c'],
              ),
              // Route Polyline - only showing remaining route
              if (remainingRoutePoints.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: remainingRoutePoints,
                      strokeWidth: 4.0,
                      color: Colors.blue,
                    ),
                  ],
                ),
              // Markers
              MarkerLayer(
                markers: [
                  if (currentLocation != null)
                    Marker(
                      point: currentLocation!,
                      width: 40.0,
                      height: 40.0,
                      child: const Icon(
                        Icons.navigation,
                        color: Colors.blue,
                        size: 40.0,
                      ),
                    ),
                  if (destination != null)
                    Marker(
                      point: destination!,
                      width: 40.0,
                      height: 40.0,
                      child: const Icon(
                        Icons.location_on,
                        color: Colors.red,
                        size: 40.0,
                      ),
                    ),
                ],
              ),
            ],
          ),
          //! Destination search bar
          Positioned(
            top: 10,
            left: 10,
            right: 10,
            child: IconButton(
              icon: Icon(Icons.refresh),
              onPressed: () => _searchDestination(widget.destinationName),
            ),
          ),
          //! Navigation instructions panel
          if (isNavigating && instructions.isNotEmpty)
            Positioned(
              bottom: 20,
              left: 10,
              right: 10,
              child: Container(
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 5,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentInstructionIndex < instructions.length
                          ? instructions[currentInstructionIndex]
                              .text
                              .toUpperCase()
                          : 'Navigating...',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 5),
                    if (currentInstructionIndex + 1 < instructions.length)
                      Text(
                        'Next: ${instructions[currentInstructionIndex + 1].text}',
                        style: TextStyle(fontSize: 14),
                      ),
                    // SizedBox(height: 10),
                    // Distance to next turn
                    // if (currentInstructionIndex < instructions.length &&
                    //     remainingRoutePoints.isNotEmpty)
                    //   Text(
                    //     'Distance to next turn: ${_calculateDistanceToNextTurn()} meters',
                    //     style: TextStyle(
                    //         fontSize: 14, fontWeight: FontWeight.bold),
                    //   ),
                    // SizedBox(height: 10),
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.end,
                    //   children: [
                    //     ElevatedButton(
                    //       onPressed: () =>
                    //           _endNavigation('Navigation cancelled'),
                    //       child: Text('End Navigation'),
                    //       style: ButtonStyle(
                    //         backgroundColor:
                    //             MaterialStateProperty.all<Color>(Colors.red),
                    //       ),
                    //     ),
                    //   ],
                    // ),
                  ],
                ),
              ),
            ),
          // Speed display
          if (isNavigating)
            Positioned(
              top: 70,
              right: 10,
              child: Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 5,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      'ETA',
                      style: TextStyle(fontSize: 12),
                    ),
                    Text(
                      _calculateETA(),
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),

          Positioned(
            top: 70,
            left: 10,
            child: Container(
              height: 60,
              width: 60,
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 5,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    '50 ',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Kmph',
                    style: TextStyle(
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: currentLocation == null
          ? FloatingActionButton(
              onPressed: _getCurrentLocation,
              child: Icon(Icons.my_location),
            )
          : null,
    );
  }

  String _calculateDistanceToNextTurn() {
    if (currentLocation == null ||
        remainingRoutePoints.isEmpty ||
        currentInstructionIndex >= instructions.length - 1) {
      return "0";
    }

    // Find the point corresponding to the next instruction
    int nextInstructionPointIndex =
        instructions[currentInstructionIndex + 1].pointIndex;

    // Convert to index in remainingRoutePoints
    int adjustedIndex = nextInstructionPointIndex - lastPassedPointIndex - 1;

    // Make sure index is valid
    if (adjustedIndex < 0 || adjustedIndex >= remainingRoutePoints.length) {
      return "calculating...";
    }

    LatLng nextTurnPoint = remainingRoutePoints[adjustedIndex];

    // Calculate distance
    double distance =
        Distance().as(LengthUnit.Meter, currentLocation!, nextTurnPoint);

    return distance.round().toString();
  }

  String _calculateETA() {
    if (remainingRoutePoints.isEmpty) return "--:--";

    // Assuming average speed of 40 km/h for demonstration
    // In a real app, you would calculate this based on road types and traffic
    double averageSpeedKmh = 40.0;

    // Calculate total remaining distance
    double totalDistance = 0;
    for (int i = 0; i < remainingRoutePoints.length - 1; i++) {
      totalDistance += Distance().as(LengthUnit.Kilometer,
          remainingRoutePoints[i], remainingRoutePoints[i + 1]);
    }

    // Calculate time in hours
    double timeInHours = totalDistance / averageSpeedKmh;

    // Calculate arrival time
    DateTime now = DateTime.now();
    DateTime arrivalTime =
        now.add(Duration(minutes: (timeInHours * 60).round()));

    // Format to HH:MM
    String hour = arrivalTime.hour.toString().padLeft(2, '0');
    String minute = arrivalTime.minute.toString().padLeft(2, '0');

    return "$hour:$minute";
  }
}

class Instruction {
  final String text;
  final double distance;
  final int pointIndex;

  Instruction({
    required this.text,
    required this.distance,
    required this.pointIndex,
  });
}

//! CENTRED ONE
// import 'package:flutter/material.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:latlong2/latlong.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'dart:async';
// import 'package:flutter_tts/flutter_tts.dart';

// class NavigationApp extends StatefulWidget {
//   const NavigationApp({super.key});

//   @override
//   _NavigationAppState createState() => _NavigationAppState();
// }

// class _NavigationAppState extends State<NavigationApp> {
//   final MapController mapController = MapController();
//   LatLng? currentLocation;
//   LatLng? destination;
//   List<LatLng> originalRoutePoints = [];
//   List<LatLng> remainingRoutePoints = [];
//   List<Instruction> instructions = [];
//   int currentInstructionIndex = 0;
//   bool isNavigating = false;
//   final FlutterTts flutterTts = FlutterTts();
//   Timer? locationUpdateTimer;
//   final TextEditingController destinationController = TextEditingController();
//   int lastPassedPointIndex = -1;
//   bool isMapCentered = true; // Track if the map is centered on the user

//   @override
//   void initState() {
//     super.initState();
//     _getCurrentLocation();
//     _initTts();
//   }

//   @override
//   void dispose() {
//     locationUpdateTimer?.cancel();
//     destinationController.dispose();
//     super.dispose();
//   }

//   void _initTts() async {
//     await flutterTts.setLanguage("en-US");
//     await flutterTts.setSpeechRate(0.5);
//   }

//   Future<void> _getCurrentLocation() async {
//     bool serviceEnabled;
//     LocationPermission permission;

//     // Check if location services are enabled
//     serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Location services are disabled')),
//       );
//       return;
//     }

//     // Check for location permissions
//     permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Location permissions are denied')),
//         );
//         return;
//       }
//     }

//     // Get current position
//     Position position = await Geolocator.getCurrentPosition(
//       desiredAccuracy: LocationAccuracy.high,
//     );

//     setState(() {
//       currentLocation = LatLng(position.latitude, position.longitude);
//       if (isMapCentered) {
//         _recenterMap();
//       }
//     });
//   }

//   void _recenterMap() {
//     if (currentLocation != null) {
//       // Smoothly move the map to the current location with animation
//       mapController.move(currentLocation!, 15.0);
//     }
//   }

//   void _startLocationUpdates() {
//     locationUpdateTimer = Timer.periodic(Duration(seconds: 3), (timer) async {
//       Position position = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high,
//       );

//       LatLng newLocation = LatLng(position.latitude, position.longitude);

//       setState(() {
//         currentLocation = newLocation;
//         if (isMapCentered) {
//           _recenterMap();
//         }
//       });

//       if (isNavigating) {
//         _updateNavigation();
//       }
//     });
//   }

//   // Rest of your existing code...

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Turn-by-Turn Navigation'),
//         backgroundColor: Colors.blue,
//       ),
//       body: Stack(
//         children: [
//           FlutterMap(
//             mapController: mapController,
//             options: MapOptions(
//               initialCenter: currentLocation ?? LatLng(0, 0),
//               initialZoom: 15.0,
//             ),
//             children: [
//               TileLayer(
//                 urlTemplate:
//                     'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
//                 subdomains: const ['a', 'b', 'c'],
//               ),
//               if (remainingRoutePoints.isNotEmpty)
//                 PolylineLayer(
//                   polylines: [
//                     Polyline(
//                       points: remainingRoutePoints,
//                       strokeWidth: 4.0,
//                       color: Colors.blue,
//                     ),
//                   ],
//                 ),
//               MarkerLayer(
//                 markers: [
//                   if (currentLocation != null)
//                     Marker(
//                       point: currentLocation!,
//                       width: 40.0,
//                       height: 40.0,
//                       child: const Icon(
//                         Icons.navigation,
//                         color: Colors.blue,
//                         size: 40.0,
//                       ),
//                     ),
//                   if (destination != null)
//                     Marker(
//                       point: destination!,
//                       width: 40.0,
//                       height: 40.0,
//                       child: const Icon(
//                         Icons.location_on,
//                         color: Colors.red,
//                         size: 40.0,
//                       ),
//                     ),
//                 ],
//               ),
//             ],
//           ),
//           // Destination search bar
//           Positioned(
//             top: 10,
//             left: 10,
//             right: 10,
//             child: Container(
//               padding: EdgeInsets.symmetric(horizontal: 10),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(5),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black26,
//                     blurRadius: 5,
//                     offset: Offset(0, 2),
//                   ),
//                 ],
//               ),
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: TextField(
//                       controller: destinationController,
//                       decoration: InputDecoration(
//                         hintText: 'Enter destination',
//                         border: InputBorder.none,
//                       ),
//                       onSubmitted: _searchDestination,
//                     ),
//                   ),
//                   IconButton(
//                     icon: Icon(Icons.search),
//                     onPressed: () =>
//                         _searchDestination(destinationController.text),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           // Recenter button
//           Positioned(
//             bottom: 100,
//             right: 10,
//             child: FloatingActionButton(
//               onPressed: () {
//                 setState(() {
//                   isMapCentered = true; // Enable auto-recentering
//                 });
//                 _recenterMap();
//               },
//               child: Icon(Icons.my_location),
//               backgroundColor: Colors.blue,
//             ),
//           ),
//           // Navigation instructions panel
//           if (isNavigating && instructions.isNotEmpty)
//             Positioned(
//               bottom: 20,
//               left: 10,
//               right: 10,
//               child: Container(
//                 padding: EdgeInsets.all(15),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(10),
//                   boxShadow: [
//                     BoxShadow(
//                         color: Colors.black26,
//                         blurRadius: 5,
//                         offset: Offset(0, 2)),
//                   ],
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       currentInstructionIndex < instructions.length
//                           ? instructions[currentInstructionIndex].text
//                           : 'Navigating...',
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     SizedBox(height: 5),
//                     if (currentInstructionIndex + 1 < instructions.length)
//                       Text(
//                         'Next: ${instructions[currentInstructionIndex + 1].text}',
//                         style: TextStyle(fontSize: 14),
//                       ),
//                     SizedBox(height: 10),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.end,
//                       children: [
//                         ElevatedButton(
//                           onPressed: () =>
//                               _endNavigation('Navigation cancelled'),
//                           child: Text('End Navigation'),
//                           style: ButtonStyle(
//                             backgroundColor:
//                                 MaterialStateProperty.all<Color>(Colors.red),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//         ],
//       ),
//       floatingActionButton: currentLocation == null
//           ? FloatingActionButton(
//               onPressed: _getCurrentLocation,
//               child: Icon(Icons.my_location),
//             )
//           : null,
//     );
//   }
// }
