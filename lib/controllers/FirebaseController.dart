import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class FirebaseController extends GetxController {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  void updateUserPositionAndSpeed({
    required String userId, // e.g., 'user1'
    required LatLng position,
    required double speed,
  }) {
    try {
      _database.child("user1").update({
        'position':
            '${position.latitude},${position.longitude}', // Store as a string
        'speed': speed.toStringAsFixed(2), // Store speed as a string
      });
    } catch (e) {
      debugPrint('Error updating position and speed: $e');
    }
  }
}
