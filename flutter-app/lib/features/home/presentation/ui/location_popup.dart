import 'dart:async';
import 'dart:convert';
import 'package:driveguard/features/home/presentation/ui/predict_loading_page.dart';
import 'package:driveguard/features/home/presentation/ui/services/cubit/road_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:driveguard/features/home/presentation/ui/accident_prediction_page.dart';

class LocationBottomSheet extends StatefulWidget {
  const LocationBottomSheet({super.key});

  @override
  _LocationBottomSheetState createState() => _LocationBottomSheetState();
}

class _LocationBottomSheetState extends State<LocationBottomSheet> {
  int _selectedPassengers = 1;
  final List<int> _passengerOptions = [1, 2, 3, 4, 5, 6];

  final List<Map<String, dynamic>> _travelOptions = [
    {'icon': Icons.directions_car, 'label': 'Car'},
    {'icon': Icons.directions_bike, 'label': 'Motor-Bike'},
    {'icon': Icons.directions_transit, 'label': 'Truck'},
    {'icon': Icons.three_k_outlined, 'label': 'Auto'},
  ];
  String vehicle = 'Car';

  final TextEditingController _destinationController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  List<Map<String, dynamic>> _suggestions = [];
  bool _isLoading = false;
  String _currentLocation = 'Fetching location...';
  Map<String, dynamic>? _selectedPlace;
  LatLng? _currentLocationCoords;

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _destinationController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  // Improved location permission check
  Future<bool> _checkLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Location services are disabled. Please enable location services.')),
      );
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permission denied')),
        );
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Location permissions are permanently denied. Please enable in settings.'),
          duration: Duration(seconds: 3),
        ),
      );
      return false;
    }

    return true;
  }

  // Improved current location function with fallbacks
  Future<void> _getCurrentLocation() async {
    setState(() {
      _currentLocation = 'Fetching location...';
    });

    bool permissionGranted = await _checkLocationPermission();
    if (!permissionGranted) {
      setState(() {
        _currentLocation = 'Location permission not available';
      });
      return;
    }

    try {
      // First try with high accuracy but with timeout
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () => throw TimeoutException('Location request timed out'),
      );

      _processLocation(position);
    } catch (highAccuracyError) {
      print('High accuracy location error: $highAccuracyError');

      try {
        // Try with last known position
        Position? lastPosition = await Geolocator.getLastKnownPosition();
        if (lastPosition != null) {
          _processLocation(lastPosition, " (Last known)");
          return;
        }

        // If last known position is not available, try with lower accuracy
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.reduced,
          timeLimit: const Duration(seconds: 5),
        );

        _processLocation(position, " (Approx.)");
      } catch (e) {
        print('Location fallback error: $e');
        setState(() {
          _currentLocation = 'Unable to fetch location';
        });
      }
    }
  }

  // Helper method to process location data
  void _processLocation(Position position, [String suffix = ""]) async {
    try {
      String locationName = await _reverseGeocode(position);
      setState(() {
        _currentLocation = locationName + suffix;
        _locationController.text = locationName;
        _currentLocationCoords = LatLng(position.latitude, position.longitude);
      });
    } catch (e) {
      print('Error processing location: $e');
      setState(() {
        _currentLocation = 'Location found but address unavailable';
        _locationController.text = 'Location found';
        _currentLocationCoords = LatLng(position.latitude, position.longitude);
      });
    }
  }

  // Improved reverse geocoding with better error handling
  Future<String> _reverseGeocode(Position position) async {
    try {
      final response = await http.get(
        Uri.parse(
            'https://nominatim.openstreetmap.org/reverse?format=json&lat=${position.latitude}&lon=${position.longitude}&zoom=18&addressdetails=1'),
        headers: {
          'Accept': 'application/json',
          'User-Agent':
              'DriveGuard-App', // Adding a user-agent to avoid being blocked
        },
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data.containsKey('display_name') && data['display_name'] != null) {
          return data['display_name'];
        } else if (data.containsKey('address')) {
          // Try to form an address from components if display_name is not available
          final address = data['address'];
          List<String> addressParts = [];

          if (address.containsKey('road')) addressParts.add(address['road']);
          if (address.containsKey('city') || address.containsKey('town')) {
            addressParts.add(address['city'] ?? address['town']);
          }
          if (address.containsKey('state')) addressParts.add(address['state']);
          if (address.containsKey('country'))
            addressParts.add(address['country']);

          return addressParts.join(', ');
        }
      }
    } catch (e) {
      print('Error reverse geocoding: $e');
      throw e; // Re-throw to be handled by calling function
    }
    return '${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}';
  }

  // Search for places based on the query
  Future<void> _searchPlaces(String query) async {
    if (query.length < 3) {
      setState(() {
        _suggestions = [];
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse(
            'https://nominatim.openstreetmap.org/search?format=json&q=$query&limit=5'),
        headers: {
          'Accept': 'application/json',
          'User-Agent':
              'DriveGuard-App', // Adding a user-agent to avoid being blocked
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _suggestions = data
              .map((place) => {
                    'name': place['display_name'],
                    'lat': double.parse(place['lat']),
                    'lon': double.parse(place['lon']),
                  })
              .toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _suggestions = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error searching places: $e');
      setState(() {
        _suggestions = [];
        _isLoading = false;
      });
    }
  }

  // Navigate to the AccidentPredictionPage
  void _navigateToMapPage(Map<String, dynamic> place) {
    if (place.isNotEmpty && _currentLocationCoords != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => PredictLoadingPage(
            startPos: _currentLocationCoords!,
            vehicle: vehicle,
            passengers: _selectedPassengers,
            destinationName: place['name'],
            destinationLocation: LatLng(place['lat'], place['lon']),
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to determine your location')),
      );
    }
  }

  // Build the location and destination input fields
  Widget _buildLocationInputFields() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          TextField(
            readOnly: true,
            controller: _locationController,
            decoration: InputDecoration(
              hintText: 'Your location',
              prefixIcon: Icon(Icons.my_location, color: Colors.blue),
              border: InputBorder.none,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              suffixIcon: IconButton(
                icon: Icon(Icons.refresh, color: Colors.blue),
                onPressed: _getCurrentLocation,
                tooltip: 'Refresh location',
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 14),
            child: Row(
              children: [
                Icon(Icons.arrow_downward, color: Colors.blue),
              ],
            ),
          ),
          TextField(
            controller: _destinationController,
            decoration: const InputDecoration(
              hintText: 'Enter destination',
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16),
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: _searchPlaces,
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          if (_suggestions.isNotEmpty)
            SizedBox(
              height: 200,
              child: ListView.builder(
                itemCount: _suggestions.length,
                itemBuilder: (context, index) {
                  final place = _suggestions[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      leading:
                          const Icon(Icons.location_on, color: Colors.blue),
                      title: Text(
                        place['name'],
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                      onTap: () {
                        setState(() {
                          _selectedPlace = place;
                          _destinationController.text = place['name'];
                          _suggestions = []; // Clear suggestions
                        });
                      },
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  // Build the passenger dropdown
  Widget _buildPassengerDropdown() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: _selectedPassengers,
          hint: Text(
            'Number of passengers',
            style: TextStyle(color: Colors.black),
          ),
          onChanged: (int? value) {
            if (value != null) {
              setState(() {
                _selectedPassengers = value;
              });
            }
          },
          items: _passengerOptions.map((int passengers) {
            return DropdownMenuItem<int>(
              value: passengers,
              child: Text(
                '$passengers passenger${passengers > 1 ? 's' : ''}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // Build the travel options grid
  Widget _buildTravelOptionsGrid() {
    return GridView.count(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      crossAxisCount: 4,
      childAspectRatio: 1.0,
      padding: EdgeInsets.all(4.0),
      mainAxisSpacing: 8.0,
      crossAxisSpacing: 8.0,
      children: _travelOptions.map((option) {
        bool isSelected = vehicle == option['label'];
        return InkWell(
          onTap: () {
            setState(() {
              vehicle = option['label'];
            });
          },
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: isSelected ? Colors.blue : Colors.grey.shade300,
                width: isSelected ? 2.0 : 1.0,
              ),
              borderRadius: BorderRadius.circular(8),
              color: isSelected ? Colors.blue.withOpacity(0.1) : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  option['icon'],
                  size: 24,
                  color: isSelected ? Colors.blue : null,
                ),
                SizedBox(height: 4),
                Text(
                  option['label'],
                  style: TextStyle(
                    fontSize: 12,
                    color: isSelected ? Colors.blue : null,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // Build the action buttons
  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Cancel'),
        ),
        SizedBox(width: 8),
        ElevatedButton(
          onPressed: () {
            if (_selectedPlace != null) {
              _navigateToMapPage(_selectedPlace!);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please select a destination')),
              );
            }
          },
          child: Text('Confirm'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            _buildLocationInputFields(),
            SizedBox(height: 16),
            _buildPassengerDropdown(),
            SizedBox(height: 16),
            _buildTravelOptionsGrid(),
            SizedBox(height: 16),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }
}
