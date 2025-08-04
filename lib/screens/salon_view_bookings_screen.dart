import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../widgets/app_widgets.dart';

class SalonViewBookingsScreen extends StatelessWidget {
  const SalonViewBookingsScreen({super.key});

  Future<List<Map<String, dynamic>>> _fetchSalonBookings() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final query = await FirebaseFirestore.instance
        .collection('bookings')
        .where('salonId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .get();

    return query.docs.map((doc) => doc.data()).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Bookings'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchSalonBookings(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return emptyMessage("No bookings found.");
          }

          final bookings = snapshot.data!;
          return ListView.builder(
            itemCount: bookings.length,
            padding: const EdgeInsets.all(12),
            itemBuilder: (context, index) {
              final booking = bookings[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                color: Colors.white,
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Text(
                    booking['customerName'] ?? 'Customer',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                      fontSize: 18,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Text("Date: ${booking['date']}"),
                      Text("Time: ${booking['time']}"),
                      if (booking['service'] != null)
                        Text("Service: ${booking['service']}"),
                    ],
                  ),
                  leading:
                      const Icon(Icons.calendar_today, color: AppColors.accent),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
