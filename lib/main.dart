// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/role_check_screen.dart';
import 'screens/customer_home.dart';
import 'screens/salon_owner_home.dart';
import 'screens/profile_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MySalonApp());
}

class MySalonApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Salon',
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => LoginScreen(),
        '/signup': (context) => SignupScreen(),
        '/roleCheck': (context) => RoleCheckScreen(),
        '/customerHome': (context) => CustomerHomeScreen(),
        '/salonHome': (context) => SalonOwnerHomeScreen(),
        '/profile': (context) => ProfileScreen(),
      },
    );
  }
}
