import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/firestore_service.dart';
import '../utils/app_colors.dart';
import 'salon_owner_profile_screen.dart';

class SalonOwnerHomeScreen extends StatefulWidget {
  const SalonOwnerHomeScreen({super.key});

  @override
  State<SalonOwnerHomeScreen> createState() => _SalonOwnerHomeScreenState();
}

class _SalonOwnerHomeScreenState extends State<SalonOwnerHomeScreen> {
  final firestoreService = FirestoreService();
  String? salonId;
  int _currentIndex = 0;
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    loadSalonId();
  }

  Future<void> loadSalonId() async {
    try {
      salonId = await firestoreService.getSalonIdForCurrentOwner();
      if (salonId != null) {
        await firestoreService.generateDailySlotsFromSalonSettings(
          salonId!,
          DateFormat('yyyy-MM-dd').format(selectedDate),
        );
      }
      setState(() {});
    } catch (e) {
      print('Error loading salonId: $e');
      setState(() {
        salonId = null;
      });
    }
  }

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  Widget _buildDashboard() {
    if (salonId == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('bookings')
          .where('salonId', isEqualTo: salonId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final bookings = snapshot.data?.docs ?? [];

        if (bookings.isEmpty) {
          return const Center(child: Text('No bookings yet.'));
        }

        return ListView.builder(
          itemCount: bookings.length,
          itemBuilder: (context, index) {
            final booking =
                bookings[index].data() as Map<String, dynamic>? ?? {};

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: ListTile(
                title: Text(booking['customerName'] ?? 'No Name'),
                subtitle: Text('Time: ${booking['time'] ?? 'Unknown'}'),
                trailing: Text(booking['date'] ?? ''),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildProfile() {
    return const SalonOwnerProfileScreen();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text('Salon Owner Dashboard'),
        backgroundColor: AppColors.primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: _currentIndex == 0 ? _buildDashboard() : _buildProfile(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: AppColors.primaryColor,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
