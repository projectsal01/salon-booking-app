// lib/screens/role_check_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'customer_home.dart';
import 'salon_owner_home.dart';

class RoleCheckScreen extends StatefulWidget {
  @override
  _RoleCheckScreenState createState() => _RoleCheckScreenState();
}

class _RoleCheckScreenState extends State<RoleCheckScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? role;

  @override
  void initState() {
    super.initState();
    checkUserRole();
  }

  Future<void> checkUserRole() async {
    User? user = _auth.currentUser;
    if (user == null) return;

    try {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(user.uid).get();

      if (userDoc.exists && userDoc['userType'] != null) {
        String userType = userDoc['userType'];

        if (userType == 'customer') {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => CustomerHomeScreen()));
        } else if (userType == 'salon_owner') {
          // fixed here
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => SalonOwnerHomeScreen()));
        } else {
          setState(() {
            role = 'Unknown';
          });
        }
      } else {
        setState(() {
          role = 'Unknown';
        });
      }
    } catch (e) {
      setState(() {
        role = 'Error';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: role == null
            ? CircularProgressIndicator()
            : Text('Unknown role or error: $role'),
      ),
    );
  }
}
