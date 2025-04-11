import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:my_pfe/controllers/AuthController.dart';
import 'package:my_pfe/pages/HomePage.dart';

class NavigationMenu extends StatelessWidget {
  final String userId; // Add userId parameter

  const NavigationMenu({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final controller =
        Get.put(NavigationController(userId: userId)); // Pass userId
    final authController = Get.put(FirebaseAuthController());
    return Scaffold(
      appBar: AppBar(
        title: const Text("Car Speed Tracker"),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            onPressed: () {
              authController.logout();
            },
            icon: const Icon(Iconsax.logout),
          )
        ],
      ),
      /*bottomNavigationBar: Obx(
        () => NavigationBar(
          height: 80,
          elevation: 0,
          backgroundColor: Colors.white,
          indicatorColor: Colors.black.withOpacity(0.1),
          selectedIndex: controller.selectedIndex.value,
          onDestinationSelected: (value) =>
              controller.selectedIndex.value = value,
          destinations: const [
            NavigationDestination(icon: Icon(Iconsax.map), label: "Map"),
            NavigationDestination(
                icon: Icon(Iconsax.profile_2user), label: "Profile"),
            NavigationDestination(
                icon: Icon(Iconsax.setting), label: "Settings"),
          ],
        ),
      ),*/
      body: Obx(() => controller.screens[controller.selectedIndex.value]),
    );
  }
}

class NavigationController extends GetxController {
  final String userId; // Store userId
  NavigationController({required this.userId});

  static NavigationController get instance => Get.find();
  final Rx<int> selectedIndex = 0.obs;

  late final List<Widget> screens = [
    MyHomePage(title: "Car Speed Tracker", userId: userId), // Pass userId
    const Center(child: Text("Profile")),
    const Center(child: Text("Settings")),
  ];
}
