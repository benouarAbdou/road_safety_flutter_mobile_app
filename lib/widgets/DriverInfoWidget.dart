import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_pfe/controllers/FirebaseController.dart';

class DriverInfoWidget extends StatelessWidget {
  final FirebaseController firebaseController;

  const DriverInfoWidget({
    super.key,
    required this.firebaseController,
  });

  Widget _buildInfoCard(String label, String value) {
    return ListTile(
        title: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(value.isNotEmpty == true ? value : "N/A"));
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      debugPrint(
          'Building DriverInfo: isLoading=${firebaseController.isLoadingDriverInfo.value}, '
          'driverInfo=${firebaseController.driverInfo.value}, '
          'vehicleInfo=${firebaseController.vehicleInfo.value}');

      if (firebaseController.isLoadingDriverInfo.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (firebaseController.driverInfo.value.isEmpty &&
          firebaseController.vehicleInfo.value.isEmpty) {
        debugPrint('No driver or vehicle data available');
        return const Center(
          child: Text(
            'Failed to load driver or vehicle information. Please try again.',
            style: TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        );
      }

      final driverInfo = firebaseController.driverInfo.value;
      final vehicleInfo = firebaseController.vehicleInfo.value;

      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Driver Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoCard('Full Name', driverInfo['fullName'] ?? 'N/A'),
            _buildInfoCard('Phone Number', driverInfo['phoneNumber'] ?? 'N/A'),
            _buildInfoCard('Address', driverInfo['address'] ?? 'N/A'),
            const SizedBox(height: 24),
            const Text(
              'Vehicle Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoCard('Model', vehicleInfo['model'] ?? 'N/A'),
            _buildInfoCard(
                'Registration', vehicleInfo['registration'] ?? 'N/A'),
            _buildInfoCard('Type', vehicleInfo['type'] ?? 'N/A'),
          ],
        ),
      );
    });
  }
}
