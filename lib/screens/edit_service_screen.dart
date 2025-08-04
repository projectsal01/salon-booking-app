import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditServiceScreen extends StatefulWidget {
  final String serviceId;
  final Map<String, dynamic> currentData;

  const EditServiceScreen({
    Key? key,
    required this.serviceId,
    required this.currentData,
  }) : super(key: key);

  @override
  State<EditServiceScreen> createState() => _EditServiceScreenState();
}

class _EditServiceScreenState extends State<EditServiceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  late TextEditingController nameController;
  late TextEditingController priceController;
  late TextEditingController durationController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.currentData['name']);
    priceController =
        TextEditingController(text: widget.currentData['price'].toString());
    durationController =
        TextEditingController(text: widget.currentData['duration']);
  }

  Future<void> _updateService() async {
    if (!_formKey.currentState!.validate()) return;

    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    await _firestore
        .collection('salons')
        .doc(uid)
        .collection('services')
        .doc(widget.serviceId)
        .update({
      'name': nameController.text.trim(),
      'price': double.tryParse(priceController.text.trim()) ?? 0.0,
      'duration': durationController.text.trim(),
    });

    Navigator.pop(context); // Go back after updating
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Service')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Service Name'),
                validator: (value) => value == null || value.isEmpty
                    ? 'Enter service name'
                    : null,
              ),
              TextFormField(
                controller: priceController,
                decoration: const InputDecoration(labelText: 'Price (₹)'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter price' : null,
              ),
              TextFormField(
                controller: durationController,
                decoration:
                    const InputDecoration(labelText: 'Duration (e.g. 30 mins)'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter duration' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updateService,
                child: const Text('Update Service'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
