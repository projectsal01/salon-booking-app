import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddServiceScreen extends StatefulWidget {
  const AddServiceScreen({Key? key}) : super(key: key);

  @override
  State<AddServiceScreen> createState() => _AddServiceScreenState();
}

class _AddServiceScreenState extends State<AddServiceScreen> {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _durationController = TextEditingController();
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  void _saveService() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final name = _nameController.text.trim();
    final price = int.tryParse(_priceController.text.trim());
    final duration = _durationController.text.trim();

    if (name.isEmpty || price == null || duration.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields correctly')),
      );
      return;
    }

    await _firestore.collection('salons').doc(uid).collection('services').add({
      'name': name,
      'price': price,
      'duration': duration,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Service added')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Service')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Service Name'),
            ),
            TextField(
              controller: _priceController,
              decoration: const InputDecoration(labelText: 'Price'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _durationController,
              decoration:
                  const InputDecoration(labelText: 'Duration (e.g. 30 min)'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveService,
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
