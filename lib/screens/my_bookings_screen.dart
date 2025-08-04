import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';
import '../widgets/app_widgets.dart';
import '../utils/app_colors.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  final _auth = FirebaseAuth.instance;
  final firestoreService = FirestoreService();
  String userId = "";

  @override
  void initState() {
    super.initState();
    userId = _auth.currentUser?.uid ?? "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text("My Bookings"),
        backgroundColor: AppColors.primaryColor,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: firestoreService.getUserBookings(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final bookings = snapshot.data ?? [];

          if (bookings.isEmpty) {
            return emptyMessage("No bookings yet.");
          }

          return ListView.builder(
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final booking = bookings[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(booking['salonName'] ?? 'No Name'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Time: ${booking['time']}"),
                      Text("Date: ${booking['date']}"),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.cancel, color: Colors.red),
                        onPressed: () async {
                          await firestoreService
                              .cancelBooking(booking['bookingId']);
                          setState(() {});
                        },
                      ),
                      IconButton(
                        icon:
                            const Icon(Icons.rate_review, color: Colors.orange),
                        onPressed: () async {
                          await firestoreService.submitReview(
                            rating: 4.5,
                            comment: "Nice experience",
                            userId: userId,
                            salonId: booking['salonId'],
                            salonName: booking['salonName'],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
