import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:salon_booking_app/services/firestore_service.dart';
import 'package:salon_booking_app/utils/app_colors.dart';
import 'package:salon_booking_app/widgets/app_widgets.dart';

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  final firestoreService = FirestoreService();
  final currentUser = FirebaseAuth.instance.currentUser;

  Future<void> _cancelBooking(String bookingId) async {
    await firestoreService.cancelBooking(bookingId);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Booking cancelled')),
    );
    setState(() {});
  }

  void _showReviewDialog(String salonId, String salonName, String bookingId) {
    final _reviewController = TextEditingController();
    double _rating = 3;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Leave a Review'),
        content: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _reviewController,
                decoration: const InputDecoration(
                  hintText: 'Enter your review...',
                ),
              ),
              const SizedBox(height: 10),
              Slider(
                value: _rating,
                onChanged: (val) => setState(() => _rating = val),
                min: 1,
                max: 5,
                divisions: 4,
                label: '${_rating.toStringAsFixed(1)} ★',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await firestoreService.submitReview(
                salonId: salonId,
                userId: currentUser!.uid,
                comment: _reviewController.text,
                rating: _rating,
                salonName: salonName,
              );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Review submitted')),
              );
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
        title: const Text('Welcome, Customer'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacementNamed(context, '/login');
            },
          )
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('bookings')
            .where('userId', isEqualTo: currentUser!.uid)
            .orderBy('bookingTime', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return emptyMessage("No bookings found");
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: snapshot.data!.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final bookingTime = (data['bookingTime'] as Timestamp).toDate();
              final salonId = data['salonId'] ?? 'N/A';
              final salonName = data['salonName'] ?? 'Unknown Salon';
              final bookingId = doc.id;

              return Card(
                color: Colors.white,
                margin: const EdgeInsets.symmetric(vertical: 10),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  title: Text(
                    salonName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: AppColors.primaryColor,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 6),
                      Text(
                        DateFormat('EEE, MMM d • h:mm a').format(bookingTime),
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Salon ID: $salonId',
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'cancel') {
                        _cancelBooking(bookingId);
                      } else if (value == 'review') {
                        _showReviewDialog(salonId, salonName, bookingId);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'cancel',
                        child: Text('Cancel Booking'),
                      ),
                      const PopupMenuItem(
                        value: 'review',
                        child: Text('Review Salon'),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
