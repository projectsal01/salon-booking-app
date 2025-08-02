// lib/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? _gender;
  DateTime? _dob;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    User? user = _auth.currentUser;
    if (user == null) return;

    try {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        setState(() {
          _gender = userDoc['gender'];
          _dob = userDoc['dob'] != null ? DateTime.parse(userDoc['dob']) : null;
          _loading = false;
        });
      }
    } catch (e) {
      print('Error loading profile: $e');
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _selectDate() async {
    DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dob ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (picked != null && picked != _dob) {
      setState(() {
        _dob = picked;
      });
    }
  }

  Future<void> _saveProfile() async {
    User? user = _auth.currentUser;
    if (user == null) return;

    try {
      await _firestore.collection('users').doc(user.uid).update({
        'gender': _gender,
        'dob': _dob != null ? _dob!.toIso8601String() : null,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile updated')),
      );
    } catch (e) {
      print('Error saving profile: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          DropdownButtonFormField<String>(
            value: _gender,
            hint: Text('Select Gender'),
            items: ['Male', 'Female', 'Other']
                .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                .toList(),
            onChanged: (value) => setState(() => _gender = value),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Text(_dob == null
                  ? 'No date selected'
                  : 'DOB: ${DateFormat('yyyy-MM-dd').format(_dob!)}'),
              Spacer(),
              ElevatedButton(
                onPressed: _selectDate,
                child: Text('Pick Date'),
              ),
            ],
          ),
          SizedBox(height: 32),
          ElevatedButton(
            onPressed: _saveProfile,
            child: Text('Save'),
          ),
        ],
      ),
    );
  }
}
