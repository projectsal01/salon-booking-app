import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 🔸 Get salonId for current owner
  Future<String?> getSalonIdForCurrentOwner() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final snapshot = await _firestore
        .collection('salons')
        .where('ownerId', isEqualTo: user.uid)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      return snapshot.docs.first.id;
    } else {
      print('No salon found for current owner.');
      return null;
    }
  }

  // 🔸 Generate daily slots - placeholder
  Future<void> generateDailySlotsFromSalonSettings(
      String salonId, String date) async {
    print('Generating slots for salon $salonId on $date');
    // Implement logic if needed
  }

  // 🔥 NEW - Cancel Booking
  Future<void> cancelBooking(String bookingId) async {
    try {
      await _firestore.collection('bookings').doc(bookingId).delete();
      print('Booking $bookingId canceled.');
    } catch (e) {
      print('Error canceling booking: $e');
      rethrow;
    }
  }

  // 🔥 NEW - Submit Review
  Future<void> submitReview({
    required String salonId,
    required String userId,
    required double rating,
    required String reviewText,
  }) async {
    try {
      await _firestore.collection('reviews').add({
        'salonId': salonId,
        'userId': userId,
        'rating': rating,
        'reviewText': reviewText,
        'timestamp': FieldValue.serverTimestamp(),
      });
      print('Review submitted.');
    } catch (e) {
      print('Error submitting review: $e');
      rethrow;
    }
  }

  // 🔥 NEW - Get User Bookings
  Future<List<Map<String, dynamic>>> getUserBookings(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('bookings')
          .where('userId', isEqualTo: userId)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['bookingId'] = doc.id; // add bookingId for canceling
        return data;
      }).toList();
    } catch (e) {
      print('Error getting user bookings: $e');
      rethrow;
    }
  }
}
