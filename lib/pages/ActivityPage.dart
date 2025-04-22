import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_pfe/widgets/DriverInfoWidget.dart';
import 'package:my_pfe/widgets/SpeedingEventsWidget.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:my_pfe/controllers/ActivityController.dart';
import 'package:my_pfe/controllers/FirebaseController.dart';

class ActivityPage extends StatelessWidget {
  final String userId;

  ActivityPage({super.key, required this.userId});

  final ActivityController controller = Get.put(ActivityController());
  final FirebaseController firebaseController = Get.put(FirebaseController());

  @override
  Widget build(BuildContext context) {
    final RxInt selectedIndex = 0.obs;

    // Trigger fetch immediately
    debugPrint(
        'ActivityPage build: Triggering fetchDriverAndVehicleInfo for userId: $userId');
    firebaseController.fetchDriverAndVehicleInfo(userId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            child: ToggleSwitch(
              minWidth: double.infinity,
              initialLabelIndex: selectedIndex.value,
              cornerRadius: 20.0,
              activeFgColor: Colors.white,
              inactiveBgColor: Colors.grey[300],
              inactiveFgColor: Colors.black,
              totalSwitches: 2,
              labels: const ['Driver Info', 'Speeding Events'],
              activeBgColor: [Theme.of(context).colorScheme.primary],
              onToggle: (index) {
                selectedIndex.value = index!;
                debugPrint('ToggleSwitch changed to index: $index');
                controller.toggleView(index == 1);
                if (index == 1) {
                  debugPrint('Switched to Driver Info: Triggering fetch again');
                  firebaseController.fetchDriverAndVehicleInfo(userId);
                }
              },
            ),
          ),
          Expanded(
            child: Obx(() {
              if (selectedIndex.value == 0) {
                return Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return DriverInfoWidget(
                      firebaseController: firebaseController);
                });
              } else {
                return SpeedingEventsWidget(
                    controller: controller, userId: userId);
              }
            }),
          ),
        ],
      ),
    );
  }
}
