import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RoleCheckScreen extends StatefulWidget {
  const RoleCheckScreen({super.key});

  @override
  State<RoleCheckScreen> createState() => _RoleCheckScreenState();
}

class _RoleCheckScreenState extends State<RoleCheckScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    checkUserRole();
  }

  Future<void> checkUserRole() async {
    try {
      final user = _auth.currentUser;

      if (user == null) {
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }

      final userDoc = await _firestore.collection('users').doc(user.uid).get();

      if (!userDoc.exists) {
        _showError("User data not found.");
        return;
      }

      final data = userDoc.data();
      if (data == null || !data.containsKey('userType')) {
        _showError("User type not found.");
        return;
      }

      final String userType = data['userType'];

      if (!mounted) return;

      if (userType == 'customer') {
        Navigator.pushReplacementNamed(context, '/customerHome');
      } else if (userType == 'salon_owner') {
        Navigator.pushReplacementNamed(context, '/salonOwnerHome');
      } else {
        _showError("Unknown user type: $userType");
      }
    } catch (e) {
      _showError("Error checking user role: $e");
    }
  }

  void _showError(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );

    // fallback to login after showing error
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/login');
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
