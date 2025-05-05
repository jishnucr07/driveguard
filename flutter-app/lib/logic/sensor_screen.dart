import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:http/http.dart' as http;

class SensorScreen extends StatefulWidget {
  const SensorScreen({super.key});

  @override
  State<SensorScreen> createState() => _SensorScreenState();
}

class _SensorScreenState extends State<SensorScreen> {
  List<List<double>> sensorData = [];
  StreamSubscription? accelerometerSubscription;
  StreamSubscription? gyroscopeSubscription;

  @override
  void initState() {
    super.initState();
    startListeningToSensors();
  }

  void startListeningToSensors() {
    List<double> currentRow =
        List.filled(14, 0.0); // Initialize a row with 14 zeros

    accelerometerSubscription = accelerometerEvents.listen((event) {
      // Update the first 3 values of the current row with accelerometer data
      currentRow[0] = event.x;
      currentRow[1] = event.y;
      currentRow[2] = event.z;
    });

    gyroscopeSubscription = gyroscopeEvents.listen((event) {
      // Update the next 3 values of the current row with gyroscope data
      currentRow[3] = event.x;
      currentRow[4] = event.y;
      currentRow[5] = event.z;

      // Add the completed row to sensorData if it doesn't already have 10 rows
      if (sensorData.length < 10) {
        sensorData
            .add(List.from(currentRow)); // Create a copy to avoid overwriting
      }
    });
  }

  Future<void> sendDataToServer() async {
    print("Sensor Data: $sensorData"); // Debugging

    // Ensure the data has 10 time steps with 14 features each.
    if (sensorData.length != 10 || sensorData.any((row) => row.length != 14)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Not enough data collected yet!')),
      );
      return;
    }

    final url = Uri.parse('http://192.168.1.70:5000/send_data');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'data': sensorData}),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        String drivingBehavior = responseData["driving_behavior"];
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Driving Behavior: $drivingBehavior',
              style: TextStyle(
                color: drivingBehavior == "Aggressive Driving"
                    ? Colors.red
                    : Colors.green,
              ),
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send data: $e')),
      );
    }

    // Clear collected data after sending.
    sensorData.clear();
  }

  @override
  void dispose() {
    accelerometerSubscription?.cancel();
    gyroscopeSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Driving Behavior Detection')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Collecting Accelerometer and Gyroscope Data...',
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: sendDataToServer,
              child: Text('Send Data to Server'),
            ),
          ],
        ),
      ),
    );
  }
}
