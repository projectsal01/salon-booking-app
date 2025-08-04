import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreInitializer {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> initializeDummyData() async {
    WriteBatch batch = _firestore.batch();

    // 1. Add a dummy customer user
    final userRef = _firestore.collection('users').doc('user123');
    batch.set(userRef, {
      'name': 'John Doe',
      'email': 'john@example.com',
      'userType': 'customer',
      'gender': 'male',
      'dob': '1990-01-01',
      'createdAt': Timestamp.now(),
    });

    // 2. Add a dummy salon owner user
    final ownerRef = _firestore.collection('users').doc('owner123');
    batch.set(ownerRef, {
      'name': 'Jane Salon',
      'email': 'jane@salon.com',
      'userType': 'salon_owner',
      'createdAt': Timestamp.now(),
    });

    // 3. Add a salon for this owner
    final salonRef = _firestore.collection('salons').doc('salonId123');
    batch.set(salonRef, {
      'name': 'Glamour Cuts',
      'location': 'Downtown Street',
      'ownerId': 'owner123',
      'openingTime': '09:00',
      'closingTime': '18:00',
      'images': [], // Add salon images later
      'createdAt': Timestamp.now(),
    });

    // 4. Add some sample slots
    final slotCollection = salonRef.collection('slots');
    for (int i = 0; i < 5; i++) {
      final slotTime = DateTime.now().add(Duration(hours: 9 + i));
      final slotRef = slotCollection.doc();
      batch.set(slotRef, {
        'time': '${slotTime.hour.toString().padLeft(2, '0')}:00',
        'date': '${slotTime.year}-${slotTime.month}-${slotTime.day}',
        'isBooked': false,
        'createdAt': Timestamp.now(),
      });
    }

    // 5. Add a booking
    final bookingRef = _firestore.collection('bookings').doc();
    batch.set(bookingRef, {
      'customerId': 'user123',
      'salonId': 'salonId123',
      'serviceName': 'Haircut',
      'price': 200,
      'slotTime': DateTime.now().add(Duration(days: 1)).toIso8601String(),
      'status': 'pending',
      'createdAt': Timestamp.now(),
    });

    // 6. Add a review
    final reviewRef = _firestore.collection('reviews').doc();
    batch.set(reviewRef, {
      'salonId': 'salonId123',
      'customerId': 'user123',
      'rating': 4.5,
      'comment': 'Great experience!',
      'createdAt': Timestamp.now(),
    });

    // 7. Add a notification
    final notificationRef = _firestore.collection('notifications').doc();
    batch.set(notificationRef, {
      'userId': 'user123',
      'title': 'Booking Confirmed',
      'body': 'Your haircut at Glamour Cuts is confirmed.',
      'isRead': false,
      'createdAt': Timestamp.now(),
    });

    try {
      await batch.commit();
      print('✅ Dummy Firestore data initialized.');
    } catch (e) {
      print('❌ Error initializing Firestore: $e');
    }
  }
}
