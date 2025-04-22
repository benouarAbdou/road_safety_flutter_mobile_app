import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:my_pfe/controllers/AuthController.dart';
import 'package:my_pfe/pages/ActivityPage.dart';
import 'package:my_pfe/pages/HomePage.dart';

class NavigationMenu extends StatelessWidget {
  final String userId;

  const NavigationMenu({super.key, required this.userId});

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Logout'),
          content: const Text('Are you sure you want to log out?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(), // Cancel
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Get.find<FirebaseAuthController>()
                    .logout(); // Proceed with logout
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Get.to(() => ActivityPage(userId: userId));
          },
          icon: const Icon(Iconsax.activity),
        ),
        title: const Text("Car Speed Tracker"),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            onPressed: () => _showLogoutConfirmation(context),
            icon: const Icon(Iconsax.logout),
          ),
        ],
      ),
      body: MyHomePage(title: 'Car Speed Tracker', userId: userId),
    );
  }
}
