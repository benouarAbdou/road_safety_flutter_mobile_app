import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class FirebaseController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  var isDriving = true.obs;
  var isLoadingIsDriving = true.obs;
  var isLoadingDriverInfo = true.obs;
  var driverInfo = {}.obs;
  var vehicleInfo = {}.obs;

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
        log('Fetched isDriving: ${isDriving.value}');
      } else {
        log('No driver found with authId: $userId');
        isDriving.value = false;
      }

      isLoadingIsDriving.value = false;
    } catch (e) {
      log('Error fetching isDriving: $e');
      isDriving.value = false;
      isLoadingIsDriving.value = false;
    }
  }

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

  Future<void> addEvent({
    required String driverId,
    required String position,
    required double driverSpeed,
    required double roadSpeedLimit,
    required int duration,
  }) async {
    try {
      DocumentSnapshot driverDoc =
          await _firestore.collection('drivers').doc(driverId).get();
      String? vehicleId = driverDoc.get('vehicleId');

      final eventDateTime = DateTime.now();
      final eventData = {
        'driverId': driverId,
        'position': position,
        'driverSpeed': driverSpeed,
        'roadSpeedLimit': roadSpeedLimit,
        'eventDateTime': eventDateTime.toIso8601String(),
        'duration': duration,
        'vehicleId': vehicleId,
      };

      DocumentReference docRef =
          await _firestore.collection('events').add(eventData);
      log('Event added successfully with ID: ${docRef.id}');
      debugPrint(
          'Event added successfully for driverDocId: $driverId with duration: $duration seconds and vehicleId: $vehicleId');
    } catch (e) {
      debugPrint('Error adding event: $e');
    }
  }

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

  Future<void> fetchDriverAndVehicleInfo(String userId) async {
    log('Starting fetchDriverAndVehicleInfo for userId: $userId');
    try {
      isLoadingDriverInfo.value = true;

      // Fetch driver info with timeout
      log('Fetching driver info for authId: $userId');
      QuerySnapshot driverQuery = await _firestore
          .collection('drivers')
          .where('authId', isEqualTo: userId)
          .limit(1)
          .get()
          .timeout(const Duration(seconds: 10), onTimeout: () {
        log('Driver query timed out for userId: $userId');
        throw TimeoutException('Driver query timed out');
      });

      if (driverQuery.docs.isNotEmpty) {
        log('Driver found for userId: $userId');
        var driverData = driverQuery.docs.first.data() as Map<String, dynamic>;
        driverInfo.value = {
          'fullName': driverData['fullName'] ?? 'N/A',
          'phoneNumber': driverData['phoneNumber'] ?? 'N/A',
          'address': driverData['address'] ?? 'N/A',
          'vehicleId': driverData['vehicleId'] ?? '',
        };

        // Fetch vehicle info if vehicleId exists
        String? vehicleId = driverData['vehicleId'];
        if (vehicleId != null && vehicleId.isNotEmpty) {
          log('Fetching vehicle info for vehicleId: $vehicleId');
          DocumentSnapshot vehicleDoc = await _firestore
              .collection('vehicles')
              .doc(vehicleId)
              .get()
              .timeout(const Duration(seconds: 10), onTimeout: () {
            log('Vehicle query timed out for vehicleId: $vehicleId');
            throw TimeoutException('Vehicle query timed out');
          });
          if (vehicleDoc.exists) {
            var vehicleData = vehicleDoc.data() as Map<String, dynamic>;
            vehicleInfo.value = {
              'model': vehicleData['model'] ?? 'N/A',
              'registration': vehicleData['registration'] ?? 'N/A',
              'type': vehicleData['type'] ?? 'N/A',
            };
          } else {
            log('No vehicle found for vehicleId: $vehicleId');
            vehicleInfo.value = {
              'model': 'N/A',
              'registration': 'N/A',
              'type': 'N/A',
            };
          }
        } else {
          log('No vehicleId found for driver');
          vehicleInfo.value = {
            'model': 'N/A',
            'registration': 'N/A',
            'type': 'N/A',
          };
        }
      } else {
        log('No driver found for authId: $userId');
        driverInfo.value = {
          'fullName': 'N/A',
          'phoneNumber': 'N/A',
          'address': 'N/A',
          'vehicleId': '',
        };
        vehicleInfo.value = {
          'model': 'N/A',
          'registration': 'N/A',
          'type': 'N/A',
        };
      }

      isLoadingDriverInfo.value = false;
      log('fetchDriverAndVehicleInfo completed successfully');
    } catch (e) {
      log('Error in fetchDriverAndVehicleInfo: $e');
      driverInfo.value = {
        'fullName': 'N/A',
        'phoneNumber': 'N/A',
        'address': 'N/A',
        'vehicleId': '',
      };
      vehicleInfo.value = {
        'model': 'N/A',
        'registration': 'N/A',
        'type': 'N/A',
      };
      isLoadingDriverInfo.value = false;
    }
  }
}
