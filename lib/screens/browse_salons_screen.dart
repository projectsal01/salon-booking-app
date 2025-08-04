import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BrowseSalonsScreen extends StatefulWidget {
  const BrowseSalonsScreen({super.key});

  @override
  State<BrowseSalonsScreen> createState() => _BrowseSalonsScreenState();
}

class _BrowseSalonsScreenState extends State<BrowseSalonsScreen> {
  final _firestore = FirebaseFirestore.instance;
  String? selectedLocation;
  String? selectedService;

  List<String> locations = [];
  List<String> services = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadFilters();
  }

  Future<void> loadFilters() async {
    final salonsSnapshot = await _firestore.collection('salons').get();
    final servicesSnapshot = await _firestore.collectionGroup('services').get();

    final Set<String> locationSet = {};
    final Set<String> serviceSet = {};

    for (var doc in salonsSnapshot.docs) {
      final data = doc.data();
      if (data.containsKey('location')) {
        locationSet.add(data['location']);
      }
    }

    for (var doc in servicesSnapshot.docs) {
      final data = doc.data();
      if (data.containsKey('name')) {
        serviceSet.add(data['name']);
      }
    }

    setState(() {
      locations = locationSet.toList();
      services = serviceSet.toList();
      isLoading = false;
    });
  }

  Future<List<DocumentSnapshot>> getFilteredSalons() async {
    if (selectedLocation == null || selectedService == null) return [];

    final salonsSnapshot = await _firestore
        .collection('salons')
        .where('location', isEqualTo: selectedLocation)
        .get();

    final List<DocumentSnapshot> matchedSalons = [];

    for (var salon in salonsSnapshot.docs) {
      final servicesSnapshot =
          await salon.reference.collection('services').get();
      for (var service in servicesSnapshot.docs) {
        final data = service.data();
        if (data['name'] == selectedService) {
          matchedSalons.add(salon);
          break;
        }
      }
    }

    return matchedSalons;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Browse Salons")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                const SizedBox(height: 16),
                DropdownButton<String>(
                  hint: const Text("Select Location"),
                  value: selectedLocation,
                  onChanged: (value) =>
                      setState(() => selectedLocation = value),
                  items: locations
                      .map((loc) => DropdownMenuItem(
                            value: loc,
                            child: Text(loc),
                          ))
                      .toList(),
                ),
                DropdownButton<String>(
                  hint: const Text("Select Service"),
                  value: selectedService,
                  onChanged: (value) => setState(() => selectedService = value),
                  items: services
                      .map((srv) => DropdownMenuItem(
                            value: srv,
                            child: Text(srv),
                          ))
                      .toList(),
                ),
                ElevatedButton(
                  onPressed: () => setState(() {}),
                  child: const Text("Search"),
                ),
                const Divider(),
                Expanded(
                  child: FutureBuilder<List<DocumentSnapshot>>(
                    future: getFilteredSalons(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final salons = snapshot.data ?? [];

                      if (salons.isEmpty) {
                        return const Center(
                            child: Text("No matching salons found"));
                      }

                      return ListView.builder(
                        itemCount: salons.length,
                        itemBuilder: (context, index) {
                          final salon =
                              salons[index].data() as Map<String, dynamic>;

                          return ListTile(
                            title: Text(salon['name'] ?? 'Unnamed'),
                            subtitle: Text(salon['location'] ?? ''),
                            trailing: ElevatedButton(
                              onPressed: () {
                                // TODO: Navigate to booking slot screen
                                Navigator.pushNamed(
                                  context,
                                  '/viewSlots',
                                  arguments: salons[index].id,
                                );
                              },
                              child: const Text("View Slots"),
                            ),
                          );
                        },
                      );
                    },
                  ),
                )
              ],
            ),
    );
  }
}
