import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ViewSalonsScreen extends StatefulWidget {
  const ViewSalonsScreen({super.key});

  @override
  State<ViewSalonsScreen> createState() => _ViewSalonsScreenState();
}

class _ViewSalonsScreenState extends State<ViewSalonsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? selectedService;
  String? selectedLocation;

  List<String> services = [];
  List<String> locations = [];

  @override
  void initState() {
    super.initState();
    fetchServicesAndLocations();
  }

  Future<void> fetchServicesAndLocations() async {
    final servicesSnapshot =
        await _firestore.collection('services_master').get();
    final locationsSnapshot =
        await _firestore.collection('locations_master').get();

    setState(() {
      services =
          servicesSnapshot.docs.map((doc) => doc['name'] as String).toList();
      locations =
          locationsSnapshot.docs.map((doc) => doc['name'] as String).toList();
    });
  }

  Stream<QuerySnapshot> getFilteredSalons() {
    if (selectedService == null || selectedLocation == null) {
      return const Stream.empty();
    }

    return _firestore
        .collection('salons')
        .where('services', arrayContains: selectedService)
        .where('location', isEqualTo: selectedLocation)
        .snapshots();
  }

  void navigateToSlotScreen(String salonId, String salonName) {
    Navigator.pushNamed(
      context,
      '/viewSlots',
      arguments: {
        'salonId': salonId,
        'salonName': salonName,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Browse Salons")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Select Service'),
              value: selectedService,
              items: services.map((service) {
                return DropdownMenuItem(
                  value: service,
                  child: Text(service),
                );
              }).toList(),
              onChanged: (value) => setState(() => selectedService = value),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Select Location'),
              value: selectedLocation,
              items: locations.map((location) {
                return DropdownMenuItem(
                  value: location,
                  child: Text(location),
                );
              }).toList(),
              onChanged: (value) => setState(() => selectedLocation = value),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: getFilteredSalons(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('No salons found.'));
                  }

                  final salons = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: salons.length,
                    itemBuilder: (context, index) {
                      final salon = salons[index];
                      final name = salon['name'] ?? 'Unnamed';
                      final address = salon['address'] ?? '';

                      return ListTile(
                        title: Text(name),
                        subtitle: Text(address),
                        trailing: const Icon(Icons.arrow_forward),
                        onTap: () => navigateToSlotScreen(salon.id, name),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
