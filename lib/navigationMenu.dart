import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:my_pfe/main.dart';

class NavigationMenu extends StatelessWidget {
  const NavigationMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NavigationController());
    return Scaffold(
      bottomNavigationBar: Obx(
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
      ),
      body: Obx(() => controller.screens[controller.selectedIndex.value]),
    );
  }
}

class NavigationController extends GetxController {
  static NavigationController get instance => Get.find();
  final Rx<int> selectedIndex = 0.obs;

  final screens = [
    const MyHomePage(title: "Car Speed Tracker"),
    const MyHomePage(title: "Car Speed Tracker"),
    const MyHomePage(title: "Car Speed Tracker"),
  ];
}
