import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:my_pfe/pages/LoginPage.dart';
import 'package:my_pfe/navigationMenu.dart'; // Import NavigationMenu
import 'package:my_pfe/theme/theme.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Car Speed Tracker',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: my_pfe_Theme.lightTheme,
      darkTheme: my_pfe_Theme.darkTheme,
      home:
          const AuthCheck(), // Use AuthCheck widget to determine the initial page
    );
  }
}

// New widget to check authentication state
class AuthCheck extends StatelessWidget {
  const AuthCheck({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show a loading indicator while checking auth state
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasData && snapshot.data != null) {
          // User is logged in, go to NavigationMenu
          return NavigationMenu(userId: snapshot.data!.uid);
        }
        // User is not logged in, go to LoginPage
        return LoginPage();
      },
    );
  }
}
