import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class OSMMapPage extends StatefulWidget {
  final String destinationName;
  final LatLng destinationLocation;

  const OSMMapPage({
    Key? key,
    required this.destinationName,
    required this.destinationLocation,
  }) : super(key: key);

  @override
  State<OSMMapPage> createState() => _OSMMapPageState();
}

class _OSMMapPageState extends State<OSMMapPage> {
  final MapController _mapController = MapController();

  LatLng? _currentLocation;
  List<LatLng> _routePoints = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoading = true;
    });

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
        _isLoading = false;
      });

      _mapController.move(_currentLocation!, 15.0);

      // Get the route once we have the current location
      _getRoute();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error getting location: $e')),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _getRoute() async {
    if (_currentLocation == null) return;

    setState(() {
      _isLoading = true;
      _routePoints = [];
    });

    try {
      // Make a request to the OSRM API to get an actual route
      final response = await http.get(
        Uri.parse('https://router.project-osrm.org/route/v1/driving/'
            '${_currentLocation!.longitude},${_currentLocation!.latitude};'
            '${widget.destinationLocation.longitude},${widget.destinationLocation.latitude}'
            '?overview=full&geometries=polyline'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['routes'] != null && data['routes'].isNotEmpty) {
          final route = data['routes'][0];
          final String encodedPolyline = route['geometry'];

          // Decode the polyline to get the route coordinates
          final List<LatLng> decodedPoints = _decodePolyline(encodedPolyline);

          setState(() {
            _routePoints = decodedPoints;
          });

          _fitMapToRoute();
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to fetch route')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error getting route: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Function to decode Google's encoded polyline
  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> poly = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      double latD = lat / 1e5;
      double lngD = lng / 1e5;

      poly.add(LatLng(latD, lngD));
    }

    return poly;
  }

  void _fitMapToRoute() {
    if (_routePoints.isEmpty) return;

    double minLat = _routePoints[0].latitude;
    double maxLat = _routePoints[0].latitude;
    double minLng = _routePoints[0].longitude;
    double maxLng = _routePoints[0].longitude;

    for (var point in _routePoints) {
      if (point.latitude < minLat) minLat = point.latitude;
      if (point.latitude > maxLat) maxLat = point.latitude;
      if (point.longitude < minLng) minLng = point.longitude;
      if (point.longitude > maxLng) maxLng = point.longitude;
    }

    // Add padding
    minLat -= 0.02;
    maxLat += 0.02;
    minLng -= 0.02;
    maxLng += 0.02;

    // Calculate center
    double centerLat = (minLat + maxLat) / 2;
    double centerLng = (minLng + maxLng) / 2;

    // Move the map
    _mapController.move(LatLng(centerLat, centerLng), 12);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Route Navigation'),
      //   backgroundColor: Colors.blue,
      // ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentLocation ?? const LatLng(0, 0),
              initialZoom: 25.0,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: const ['a', 'b', 'c'],
                userAgentPackageName: 'com.example.app',
              ),
              CurrentLocationLayer(
                style: LocationMarkerStyle(
                  marker: const DefaultLocationMarker(
                    color: Colors.blue,
                    child: Icon(
                      Icons.my_location,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                  markerSize: const Size(24, 24),
                  accuracyCircleColor: Colors.blue.withOpacity(0.2),
                  headingSectorColor: Colors.blue.withOpacity(0.8),
                  headingSectorRadius: 60,
                ),
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: widget.destinationLocation,
                    width: 40,
                    height: 40,
                    child: Column(
                      children: [
                        const Icon(
                          Icons.location_on,
                          color: Colors.red,
                          size: 30,
                        ),
                        Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            widget.destinationName.split(',').first,
                            style: const TextStyle(
                                fontSize: 10, fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              PolylineLayer(
                polylines: [
                  if (_routePoints.isNotEmpty)
                    Polyline(
                      points: _routePoints,
                      strokeWidth: 4.0,
                      color: Colors.blue,
                    ),
                ],
              ),
            ],
          ),
          // Destination info card
          // Positioned(
          //   top: 10,
          //   left: 10,
          //   right: 10,
          //   child: Container(
          //     padding: const EdgeInsets.all(10),
          //     decoration: BoxDecoration(
          //       color: Colors.white,
          //       borderRadius: BorderRadius.circular(8),
          //       boxShadow: [
          //         BoxShadow(
          //           color: Colors.black26,
          //           blurRadius: 4,
          //           offset: const Offset(0, 2),
          //         ),
          //       ],
          //     ),
          //     child: Column(
          //       crossAxisAlignment: CrossAxisAlignment.start,
          //       children: [
          //         Text(
          //           'Destination:',
          //           style: TextStyle(fontWeight: FontWeight.bold),
          //         ),
          //         Text(
          //           widget.destinationName,
          //           style: TextStyle(fontSize: 14),
          //           maxLines: 2,
          //           overflow: TextOverflow.ellipsis,
          //         ),
          //       ],
          //     ),
          //   ),
          // ),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }
}
