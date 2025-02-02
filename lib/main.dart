import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:get/get.dart';
import 'package:my_pfe/controllers/FirebaseController.dart';
import 'package:my_pfe/helpers/ToastHelper.dart'; // Import GetX package

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase
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
  LatLng _currentPosition = const LatLng(0, 0);
  final Completer<GoogleMapController> _controller = Completer();
  final FirebaseController _firebaseController = Get.put(FirebaseController());

  // Marker for the user's current position
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

    // Set a fallback location (e.g., city center)
    setState(() {
      _currentPosition =
          const LatLng(36.737232, 3.086472); // Example: Algiers, Algeria
      _isLoading = true;
    });

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ToastHelper.showErrorToast(
        context,
        'GPS is not enabled. Please activate GPS.',
      );
      setState(() {
        _isLoading = false; // Stop loading if GPS is not enabled
      });
      return;
    }

    // Check location permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ToastHelper.showErrorToast(
          context,
          'Location permissions are denied.',
        );
        setState(() {
          _isLoading = false; // Stop loading if permissions are denied
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ToastHelper.showErrorToast(
        context,
        'Location permissions are permanently denied.',
      );
      setState(() {
        _isLoading =
            false; // Stop loading if permissions are permanently denied
      });
      return;
    }

    // Start listening to position updates
    _positionStream = Geolocator.getPositionStream(
      locationSettings: AndroidSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 1,
        forceLocationManager: true,
        intervalDuration: const Duration(seconds: 2),
      ),
    ).listen(
      (Position? position) {
        if (position != null) {
          _onPositionChange(position);
        }
      },
      onError: (error) {
        ToastHelper.showErrorToast(
          context,
          'Error getting location: $error',
        );
        setState(() {
          _isLoading = false; // Stop loading on error
        });
      },
      onDone: () {
        ToastHelper.showWarningToast(
          context,
          'GPS connection lost.',
        );
        setState(() {
          _isLoading = false; // Stop loading if GPS connection is lost
        });
      },
    );
  }

  void _onPositionChange(Position position) {
    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
      _speed = (position.speed * 18) / 5; // Convert m/s to km/h

      // Update the marker position
      _userMarker = Marker(
        markerId: const MarkerId('user_location'),
        position: _currentPosition,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: const InfoWindow(
          title: 'Your Location',
        ),
      );

      // Move the camera to the updated position
      _mapController.animateCamera(
        CameraUpdate.newLatLng(_currentPosition),
      );

      // Update the Firebase Realtime Database
      _firebaseController.updateUserPositionAndSpeed(
        userId: 'user1', // Replace with your actual user ID logic
        position: _currentPosition,
        speed: _speed,
      );

      // Stop loading
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
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
              _mapController = controller;
            },
          ),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(
                color: Colors.deepPurple,
              ),
            ),
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
