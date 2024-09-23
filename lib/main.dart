import 'package:flutter/material.dart';

import 'geospatial_arcore.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  // Removing 'const' since we'll have mutable state
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GeospatialARCoreApi _geospatialApi = GeospatialARCoreApi();
  double latitude = 0;
  double longitude = 0;
  double altitude = 0;

  Future<void> _startGeospatialSession() async {
    try {
      final coordinate = await _geospatialApi.startGeospatialARCoreSession();
      setState(() {
        latitude = coordinate.latitude;
        longitude = coordinate.longitude;
        altitude = coordinate.altitude;
      });
    } catch (e) {
      print("Error starting Geospatial ARCore session: $e");
    }
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
            appBar: AppBar(
              title: const Text('Geospatial ARCore Demo'),
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text('Latitude: $latitude'),
                  Text('Longitude: $longitude'),
                  Text('Altitude: $altitude'),
                  ElevatedButton(
                    onPressed: _startGeospatialSession,
                    child: const Text('Start Geospatial ARCore Session'),
                  ),
                ],
              ),
            )));
  }
}
