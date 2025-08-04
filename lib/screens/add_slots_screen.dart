import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../widgets/app_widgets.dart'; // for emptyMessage, loadingSpinner

class AddSlotsScreen extends StatefulWidget {
  const AddSlotsScreen({super.key});

  @override
  State<AddSlotsScreen> createState() => _AddSlotsScreenState();
}

class _AddSlotsScreenState extends State<AddSlotsScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  DateTime? _selectedDate;
  final List<Map<String, dynamic>> _slots = [];

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 30)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<TimeOfDay?> _pickTime(TimeOfDay? initialTime) async {
    return await showTimePicker(
      context: context,
      initialTime: initialTime ?? TimeOfDay.now(),
    );
  }

  void _addSlot() async {
    TimeOfDay? start = await _pickTime(null);
    if (start == null) return;

    TimeOfDay? end = await _pickTime(start);
    if (end == null) return;

    final String formatted =
        "${start.format(context)} - ${end.format(context)}";

    setState(() {
      _slots.add({
        'startTime': start.format(context),
        'endTime': end.format(context),
        'timeRange': formatted,
        'isBooked': false,
      });
    });
  }

  Future<void> _saveSlots() async {
    if (_selectedDate == null || _slots.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select date and add slots")),
      );
      return;
    }

    final uid = _auth.currentUser!.uid;
    final String dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate!);
    final batch = _firestore.batch();

    for (var slot in _slots) {
      final newDoc = _firestore
          .collection('salons')
          .doc(uid)
          .collection('slots')
          .doc(); // auto-generated ID

      batch.set(newDoc, {
        'date': dateStr,
        'startTime': slot['startTime'],
        'endTime': slot['endTime'],
        'isBooked': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();

    setState(() {
      _slots.clear();
      _selectedDate = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Slots saved successfully")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Available Slots")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton.icon(
              onPressed: _pickDate,
              icon: const Icon(Icons.calendar_today),
              label: Text(_selectedDate == null
                  ? "Pick Date"
                  : "Date: ${DateFormat.yMMMMd().format(_selectedDate!)}"),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _addSlot,
              icon: const Icon(Icons.add),
              label: const Text("Add Time Slot"),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _slots.isEmpty
                  ? emptyMessage("No slots added yet.")
                  : ListView.builder(
                      itemCount: _slots.length,
                      itemBuilder: (context, index) {
                        final slot = _slots[index];
                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: ListTile(
                            leading: const Icon(Icons.access_time),
                            title: Text(slot['timeRange']),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                setState(() {
                                  _slots.removeAt(index);
                                });
                              },
                            ),
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _saveSlots,
              icon: const Icon(Icons.save),
              label: const Text("Save All Slots"),
            ),
          ],
        ),
      ),
    );
  }
}
