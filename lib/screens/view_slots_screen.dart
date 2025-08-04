import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'booking_confirmation_screen.dart'; // ✅ Import the new confirmation screen

class ViewSlotsScreen extends StatefulWidget {
  final String salonId;

  const ViewSlotsScreen({Key? key, required this.salonId}) : super(key: key);

  @override
  State<ViewSlotsScreen> createState() => _ViewSlotsScreenState();
}

class _ViewSlotsScreenState extends State<ViewSlotsScreen> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  bool isBooking = false;

  Future<void> bookSlot(String slotId) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    setState(() {
      isBooking = true;
    });

    try {
      final slotRef = _firestore
          .collection('salons')
          .doc(widget.salonId)
          .collection('slots')
          .doc(slotId);

      final slotDoc = await slotRef.get();
      final data = slotDoc.data();

      if (data != null && !(data['isBooked'] ?? true)) {
        await slotRef.update({
          'isBooked': true,
          'bookedBy': uid,
        });

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => BookingConfirmationScreen(
              salonId: widget.salonId,
              slotId: slotId,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('This slot is already booked.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error booking slot: $e')),
      );
    } finally {
      setState(() {
        isBooking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final slotStream = _firestore
        .collection('salons')
        .doc(widget.salonId)
        .collection('slots')
        .where('isBooked', isEqualTo: false)
        .orderBy('startTime')
        .snapshots();

    return Scaffold(
      appBar: AppBar(title: const Text('Available Slots')),
      body: StreamBuilder<QuerySnapshot>(
        stream: slotStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final slots = snapshot.data?.docs ?? [];

          if (slots.isEmpty) {
            return const Center(child: Text('No available slots.'));
          }

          return ListView.builder(
            itemCount: slots.length,
            itemBuilder: (context, index) {
              final slot = slots[index];
              final data = slot.data() as Map<String, dynamic>;
              final startTime = (data['startTime'] as Timestamp).toDate();
              final endTime = (data['endTime'] as Timestamp).toDate();

              return ListTile(
                title: Text(
                  '${DateFormat.jm().format(startTime)} - ${DateFormat.jm().format(endTime)}',
                ),
                trailing: ElevatedButton(
                  onPressed: isBooking ? null : () => bookSlot(slot.id),
                  child: const Text('Book'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
