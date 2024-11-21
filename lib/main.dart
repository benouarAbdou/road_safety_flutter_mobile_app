import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Car Speed Tracker',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Car Speed Tracker'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late StreamSubscription<Position> _positionStream;
  double _speed = 0.0;

  @override
  void initState() {
    super.initState();
    _startTracking();
  }

  void _startTracking() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return; // Location services are not enabled
    }

    // Check location permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return; // Permissions are denied
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return; // Permissions are permanently denied
    }

    // Start listening to position updates
    _positionStream = Geolocator.getPositionStream(
      locationSettings: AndroidSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 1,
        forceLocationManager: true,
        intervalDuration: const Duration(seconds: 1),
      ),
    ).listen((Position? position) {
      if (position != null) {
        _onSpeedChange((position.speed * 18) / 5); // Convert m/s to km/h
      }
    });
  }

  void _onSpeedChange(double newSpeed) {
    setState(() {
      _speed = newSpeed;
    });
  }

  @override
  void dispose() {
    _positionStream.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Current_Speed:',
              style: TextStyle(fontSize: 20),
            ),
            Text(
              '${_speed.toStringAsFixed(0)} km/h',
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
