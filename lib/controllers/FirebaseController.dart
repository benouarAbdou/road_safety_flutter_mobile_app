import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class FirebaseController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Update user position and speed in Firestore using the user's document ID
  Future<void> updateUserPositionAndSpeed({
    required String userId, // This is the auth UID (e.g., from FirebaseAuth)
    required LatLng position,
    required double speed,
  }) async {
    try {
      // Find the driver document where authId matches userId
      QuerySnapshot driverQuery = await _firestore
          .collection('drivers')
          .where('authId', isEqualTo: userId)
          .limit(1)
          .get();

      if (driverQuery.docs.isNotEmpty) {
        String driverDocId = driverQuery.docs.first.id;
        await _firestore.collection('drivers').doc(driverDocId).update({
          'position': '${position.latitude},${position.longitude}',
          'speed': speed,
          'lastUpdated': FieldValue.serverTimestamp(),
        });
      } else {
        debugPrint('No driver found with authId: $userId');
      }
    } catch (e) {
      debugPrint('Error updating position and speed: $e');
    }
  }

  // Add an event tied to the driver's document ID
  Future<void> addEvent({
    required String driverId,
    required String position,
    required double driverSpeed,
    required double roadSpeedLimit,
  }) async {
    try {
      final eventDateTime = DateTime.now();
      final eventData = {
        'driverId': driverId, // Use document ID instead of authId
        'position': position,
        'driverSpeed': driverSpeed,
        'roadSpeedLimit': roadSpeedLimit,
        'eventDateTime': eventDateTime.toIso8601String(),
      };

      await _firestore.collection('events').add(eventData);
      debugPrint('Event added successfully for driverDocId: $driverId');
    } catch (e) {
      debugPrint('Error adding event: $e');
    }
  }

  // Helper method to get driver document ID from authId
  Future<String?> getDriverDocId(String authId) async {
    try {
      QuerySnapshot driverQuery = await _firestore
          .collection('drivers')
          .where('authId', isEqualTo: authId)
          .limit(1)
          .get();
      return driverQuery.docs.isNotEmpty ? driverQuery.docs.first.id : null;
    } catch (e) {
      debugPrint('Error fetching driver doc ID: $e');
      return null;
    }
  }
}
