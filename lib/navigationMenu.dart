import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:my_pfe/controllers/AuthController.dart';
import 'package:my_pfe/pages/ActivityPage.dart';
import 'package:my_pfe/pages/HomePage.dart';

class NavigationMenu extends StatelessWidget {
  final String userId; // Add userId parameter

  const NavigationMenu({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final authController = Get.put(FirebaseAuthController());
    return Scaffold(
      appBar: AppBar(
        title: const Text("Car Speed Tracker"),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
              onPressed: () {
                Get.to(() => ActivityPage(userId: userId));
              },
              icon: const Icon(Iconsax.activity)),
          IconButton(
            onPressed: () {
              authController.logout();
            },
            icon: const Icon(Iconsax.logout),
          )
        ],
      ),
      body: MyHomePage(title: 'Car Speed Tracker', userId: userId),
    );
  }
}
