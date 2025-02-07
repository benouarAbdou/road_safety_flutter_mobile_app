import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:get/get.dart';
import 'package:my_pfe/controllers/FirebaseController.dart';
import 'package:my_pfe/helpers/ApiHelper.dart';
import 'package:my_pfe/helpers/ToastHelper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Car Speed Tracker',
      debugShowCheckedModeBanner: false,
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
  late GoogleMapController _mapController;
  double _speed = 0.0;
  late int speedLimit = 0;
  LatLng _currentPosition = const LatLng(0, 0);
  final Completer<GoogleMapController> _controller = Completer();
  final FirebaseController _firebaseController = Get.put(FirebaseController());
  Marker? _userMarker;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _startTracking();
  }

  void _startTracking() async {
    bool serviceEnabled;
    LocationPermission permission;

    setState(() {
      _currentPosition = const LatLng(36.737232, 3.086472);
      _isLoading = true;
    });

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ToastHelper.showErrorToast(
        context,
        'GPS is not enabled. Please activate GPS.',
      );
      setState(() => _isLoading = false);
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ToastHelper.showErrorToast(context, 'Location permissions are denied.');
        setState(() => _isLoading = false);
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ToastHelper.showErrorToast(
        context,
        'Location permissions are permanently denied.',
      );
      setState(() => _isLoading = false);
      return;
    }

    _positionStream = Geolocator.getPositionStream(
      locationSettings: AndroidSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 1,
        forceLocationManager: true,
        intervalDuration: const Duration(seconds: 2),
      ),
    ).listen(
      (Position? position) async {
        if (position != null) {
          await _onPositionChange(position);
        }
      },
      onError: (error) {
        ToastHelper.showErrorToast(context, 'Error getting location: $error');
        setState(() => _isLoading = false);
      },
    );
  }

  Future<void> _onPositionChange(Position position) async {
    // Fetch speed limit first
    final int? limit = await getSpeedLimit(
      position.latitude,
      position.longitude,
    );

    // Now update state synchronously
    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
      _speed = (position.speed * 18) / 5;
      speedLimit = limit ?? 0;

      if (_speed > speedLimit) {
        ToastHelper.showWarningToast(
          context,
          'Slow down! Speed limit: $speedLimit km/h',
        );
      }

      _userMarker = Marker(
        markerId: const MarkerId('user_location'),
        position: _currentPosition,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: const InfoWindow(title: 'Your Location'),
      );

      _mapController.animateCamera(
        CameraUpdate.newLatLng(_currentPosition),
      );

      _firebaseController.updateUserPositionAndSpeed(
        userId: 'user1',
        position: _currentPosition,
        speed: _speed,
      );

      _isLoading = false;
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
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _currentPosition,
              zoom: 16,
            ),
            markers: _userMarker != null ? {_userMarker!} : {},
            myLocationEnabled: false,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            onMapCreated: (controller) {
              _controller.complete(controller);
              _mapController = controller;
            },
          ),
          if (_isLoading)
            const Center(
                child: CircularProgressIndicator(color: Colors.deepPurple)),
          Positioned(
            top: 40,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  const Text(
                    'Current Speed:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  Text(
                    '${_speed.toStringAsFixed(0)} km/h',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                  Text(
                    'Limit: $speedLimit km/h',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
