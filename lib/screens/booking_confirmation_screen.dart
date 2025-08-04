import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BookingConfirmationScreen extends StatefulWidget {
  final String salonId;
  final String slotId;

  const BookingConfirmationScreen({
    super.key,
    required this.salonId,
    required this.slotId,
  });

  @override
  State<BookingConfirmationScreen> createState() =>
      _BookingConfirmationScreenState();
}

class _BookingConfirmationScreenState extends State<BookingConfirmationScreen> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  bool _loading = true;
  Map<String, dynamic>? _slotData;

  @override
  void initState() {
    super.initState();
    _fetchSlot();
  }

  Future<void> _fetchSlot() async {
    final doc = await _firestore
        .collection('salons')
        .doc(widget.salonId)
        .collection('slots')
        .doc(widget.slotId)
        .get();

    if (doc.exists) {
      setState(() {
        _slotData = doc.data();
        _loading = false;
      });
    }
  }

  Future<void> _confirmBooking() async {
    if (_slotData == null) return;

    final user = _auth.currentUser!;
    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    final customerName = userDoc.data()?['name'] ?? "Customer";

    final batch = _firestore.batch();

    // 1. Mark the slot as booked
    final slotRef = _firestore
        .collection('salons')
        .doc(widget.salonId)
        .collection('slots')
        .doc(widget.slotId);

    batch.update(slotRef, {'isBooked': true});

    // 2. Add to global bookings collection
    final bookingRef = _firestore.collection('bookings').doc();

    batch.set(bookingRef, {
      'salonId': widget.salonId,
      'slotId': widget.slotId,
      'customerId': user.uid,
      'customerName': customerName,
      'date': _slotData!['date'],
      'startTime': _slotData!['startTime'],
      'endTime': _slotData!['endTime'],
      'bookedAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking confirmed!')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Confirm Booking')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Date: ${_slotData!['date']}"),
            Text("Time: ${_slotData!['startTime']} - ${_slotData!['endTime']}"),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _confirmBooking,
              icon: const Icon(Icons.check),
              label: const Text("Confirm Booking"),
            ),
          ],
        ),
      ),
    );
  }
}
