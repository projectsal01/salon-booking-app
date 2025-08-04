import 'package:flutter/material.dart';

class BookingDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> bookingData;

  const BookingDetailsScreen({super.key, required this.bookingData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Booking Details"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 3,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _detailRow("Date", bookingData['date']),
                const SizedBox(height: 12),
                _detailRow("Time",
                    "${bookingData['startTime']} - ${bookingData['endTime']}"),
                const SizedBox(height: 12),
                _detailRow("Salon ID", bookingData['salonId']),
                const SizedBox(height: 12),
                _detailRow("Slot ID", bookingData['slotId']),
                const SizedBox(height: 12),
                _detailRow("Customer Name", bookingData['customerName']),
                const SizedBox(height: 12),
                _detailRow("Booked At", bookingData['bookedAt']),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _detailRow(String title, dynamic value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "$title: ",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        Expanded(
          child: Text(
            value != null ? value.toString() : 'N/A',
            style: const TextStyle(color: Colors.black87),
          ),
        ),
      ],
    );
  }
}
