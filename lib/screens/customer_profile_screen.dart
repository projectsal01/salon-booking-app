import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CustomerProfileScreen extends StatefulWidget {
  const CustomerProfileScreen({super.key});

  @override
  State<CustomerProfileScreen> createState() => _CustomerProfileScreenState();
}

class _CustomerProfileScreenState extends State<CustomerProfileScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  final nameController = TextEditingController();
  final genderController = TextEditingController();
  final dobController = TextEditingController();

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final userDoc = await _firestore.collection('users').doc(uid).get();
    final data = userDoc.data();
    if (data != null) {
      nameController.text = data['name'] ?? '';
      genderController.text = data['gender'] ?? '';

      final rawDob = data['dob'];
      if (rawDob != null && rawDob.isNotEmpty) {
        DateTime dob = DateTime.tryParse(rawDob) ?? DateTime.now();
        dobController.text = '${dob.day}/${dob.month}/${dob.year}';
      }
    }

    setState(() => isLoading = false);
  }

  Future<void> saveProfile() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    try {
      final parsedDob = DateFormat('d/M/yyyy').parse(dobController.text.trim());

      await _firestore.collection('users').doc(uid).set({
        'name': nameController.text.trim(),
        'gender': genderController.text.trim(),
        'dob': parsedDob.toIso8601String(),
      }, SetOptions(merge: true));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving profile: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Customer Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: genderController,
                decoration: const InputDecoration(labelText: 'Gender'),
              ),
              TextField(
                controller: dobController,
                decoration: const InputDecoration(
                    labelText: 'Date of Birth (dd/mm/yyyy)'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: saveProfile,
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
