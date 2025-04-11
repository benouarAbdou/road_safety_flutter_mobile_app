import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class FirebaseController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  var isDriving = true.obs; // Reactive variable to track isDriving state
  var isLoadingIsDriving = true.obs;

  Future<void> fetchIsDriving(String userId) async {
    try {
      QuerySnapshot driverQuery = await _firestore
          .collection('drivers')
          .where('authId', isEqualTo: userId)
          .limit(1)
          .get();

      if (driverQuery.docs.isNotEmpty) {
        bool currentIsDriving =
            driverQuery.docs.first.get('isDriving') ?? false;
        isDriving.value = currentIsDriving;
        debugPrint('Fetched isDriving: ${isDriving.value}');
      } else {
        debugPrint('No driver found with authId: $userId');
        isDriving.value = false; // Default to false if no driver document
      }

      isLoadingIsDriving.value = false;
    } catch (e) {
      debugPrint('Error fetching isDriving: $e');
      isDriving.value = false; // Default to false on error
      isLoadingIsDriving.value = false;
    }
  }

  // Update user position and speed in Firestore using the user's document ID
  Future<void> updateUserPositionAndSpeed({
    required String userId,
    required LatLng position,
    required double speed,
  }) async {
    try {
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
        'driverId': driverId,
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

  // Toggle isDriving field in Firestore and update local state
  Future<void> toggleIsDriving(String userId) async {
    try {
      QuerySnapshot driverQuery = await _firestore
          .collection('drivers')
          .where('authId', isEqualTo: userId)
          .limit(1)
          .get();

      if (driverQuery.docs.isNotEmpty) {
        String driverDocId = driverQuery.docs.first.id;
        bool currentIsDriving =
            driverQuery.docs.first.get('isDriving') ?? false;
        await _firestore.collection('drivers').doc(driverDocId).update({
          'isDriving': !currentIsDriving,
        });
        isDriving.value = !currentIsDriving;
        debugPrint('isDriving toggled to: ${isDriving.value}');
      } else {
        debugPrint('No driver found with authId: $userId');
      }
    } catch (e) {
      debugPrint('Error toggling isDriving: $e');
    }
  }
}
