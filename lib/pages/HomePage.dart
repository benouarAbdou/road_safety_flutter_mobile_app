import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:my_pfe/controllers/FirebaseController.dart';
import 'package:my_pfe/helpers/ApiHelper.dart';
import 'package:my_pfe/helpers/ToastHelper.dart';
import 'package:my_pfe/helpers/functionsHelper.dart';
import 'package:my_pfe/widgets/speedLimitWidget.dart';
import 'package:my_pfe/widgets/speedWidget.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title, required this.userId});

  final String title;
  final String userId;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  StreamSubscription<Position>? _positionStream;
  late GoogleMapController _mapController;
  double _speed = 0.0;
  late int speedLimit = 0;
  LatLng _currentPosition = const LatLng(0, 0);
  final Completer<GoogleMapController> _controller = Completer();
  final FirebaseController _firebaseController = Get.put(FirebaseController());
  Marker? _userMarker;
  bool _isLoading = true;
  late Uint8List markerIcon;
  DateTime? _lastPositionUpdateTime; // ⏱️ Add cooldown timer

  @override
  void initState() {
    super.initState();
    _startTracking();
    _firebaseController.fetchIsDriving(widget.userId);
  }

  void _startTracking() async {
    bool serviceEnabled;
    LocationPermission permission;

    markerIcon = await getBytesFromAsset('assets/marker.png', 100);
    setState(() {
      _currentPosition = const LatLng(36.737232, 3.086472);
      _isLoading = true;
    });

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ToastHelper.showErrorToast(
          context, 'GPS is not enabled. Please activate GPS.');
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
          context, 'Location permissions are permanently denied.');
      setState(() => _isLoading = false);
      return;
    }

    try {
      Position initialPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      ).timeout(const Duration(seconds: 30), onTimeout: () {
        throw TimeoutException('Failed to get location within 10 seconds');
      });
      await _onPositionChange(initialPosition);
    } catch (e) {
      ToastHelper.showErrorToast(context, 'Error getting initial position: $e');
      setState(() => _isLoading = false);
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
    int? limit;
    if (_firebaseController.isDriving.value) {
      limit = await getSpeedLimit(position.latitude, position.longitude);
    }

    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
      _speed = (position.speed * 18) / 5;
      _speed = _speed < 5 ? 0 : _speed;
      speedLimit = limit ?? 0;

      if (_firebaseController.isDriving.value &&
          _speed > speedLimit &&
          speedLimit != 0) {
        ToastHelper.showWarningToast(
          context,
          'Slow down! Speed limit: $speedLimit km/h',
        );
        _firebaseController.getDriverDocId(widget.userId).then((driverDocId) {
          if (driverDocId != null) {
            _firebaseController.addEvent(
              driverId: driverDocId,
              position: '${position.latitude},${position.longitude}',
              driverSpeed: _speed,
              roadSpeedLimit: speedLimit.toDouble(),
            );
          }
        });
      }

      _userMarker = Marker(
        markerId: const MarkerId('user_location'),
        position: _currentPosition,
        icon: BitmapDescriptor.fromBytes(markerIcon),
        infoWindow: const InfoWindow(title: 'Your Location'),
      );

      _mapController.animateCamera(
        CameraUpdate.newLatLng(_currentPosition),
      );

      if (_firebaseController.isDriving.value) {
        final now = DateTime.now();
        if (_lastPositionUpdateTime == null ||
            now.difference(_lastPositionUpdateTime!).inMinutes >= 5) {
          _firebaseController.updateUserPositionAndSpeed(
            userId: widget.userId,
            position: _currentPosition,
            speed: _speed,
          );
          _lastPositionUpdateTime = now;
        }
      }

      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _positionStream?.cancel();
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
            bottom: 20,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SpeedCircle(width: 75, speed: _speed),
                  SpeedLimitCircle(width: 75, speedLimit: speedLimit),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 30,
            left: MediaQuery.of(context).size.width / 2 - 37.5,
            child: Obx(() => Container(
                  width: 75,
                  height: 75,
                  decoration: BoxDecoration(
                    color: !_firebaseController.isLoadingIsDriving.value
                        ? _firebaseController.isDriving.value
                            ? Colors.red
                            : Colors.green
                        : Colors.grey,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(
                      _firebaseController.isLoadingIsDriving.value
                          ? Icons.circle_outlined
                          : _firebaseController.isDriving.value
                              ? Icons.stop
                              : Icons.play_arrow,
                      color: Colors.white,
                      size: 40,
                    ),
                    onPressed: !_firebaseController.isLoadingIsDriving.value
                        ? () =>
                            _firebaseController.toggleIsDriving(widget.userId)
                        : null,
                  ),
                )),
          ),
        ],
      ),
    );
  }
}
