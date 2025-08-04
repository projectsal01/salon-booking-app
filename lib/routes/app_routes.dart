import 'package:flutter/material.dart';

import 'package:salon_booking_app/screens/login_screen.dart';
import 'package:salon_booking_app/screens/signup_screen.dart';
import 'package:salon_booking_app/screens/role_check_screen.dart';
import 'package:salon_booking_app/screens/customer_home.dart';
import 'package:salon_booking_app/screens/salon_owner_home.dart';
import 'package:salon_booking_app/screens/customer_profile_screen.dart';
import 'package:salon_booking_app/screens/salon_owner_profile_screen.dart';
import 'package:salon_booking_app/screens/splash_screen.dart';
import 'package:salon_booking_app/screens/add_slots_screen.dart';
import 'package:salon_booking_app/screens/browse_salons_screen.dart';
import 'package:salon_booking_app/screens/view_salons_screen.dart';
import 'package:salon_booking_app/screens/salon_view_bookings_screen.dart';
import '../screens/my_bookings_screen.dart';

final Map<String, WidgetBuilder> appRoutes = {
  '/': (context) => const SplashScreen(),
  '/login': (context) => LoginScreen(),
  '/signup': (context) => SignupScreen(),
  '/roleCheck': (context) => RoleCheckScreen(),
  '/customerHome': (context) => CustomerHomeScreen(),
  '/salonOwnerHome': (context) => SalonOwnerHomeScreen(),
  '/customerProfile': (context) => CustomerProfileScreen(),
  '/salonOwnerProfile': (context) => SalonOwnerProfileScreen(),
  '/browseSalons': (context) => BrowseSalonsScreen(),
  '/addSlots': (context) => AddSlotsScreen(),
  '/viewSalons': (context) => ViewSalonsScreen(),
  '/myBookings': (context) => const MyBookingsScreen(),
  '/salonViewBookings': (context) => const SalonViewBookingsScreen(),
};
