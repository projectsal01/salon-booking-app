import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ManageSlotsScreen extends StatefulWidget {
  final String salonId;

  const ManageSlotsScreen({super.key, required this.salonId});

  @override
  State<ManageSlotsScreen> createState() => _ManageSlotsScreenState();
}

class _ManageSlotsScreenState extends State<ManageSlotsScreen> {
  TimeOfDay? openingTime;
  TimeOfDay? closingTime;
  int slotDuration = 30;
  int numBarbers = 1;
  bool isLoading = false;

  Future<void> pickTime(bool isOpening) async {
    final time = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 10, minute: 0),
    );
    if (time != null) {
      setState(() {
        if (isOpening) {
          openingTime = time;
        } else {
          closingTime = time;
        }
      });
    }
  }

  Future<void> generateSlots() async {
    if (openingTime == null || closingTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please select opening and closing times')),
      );
      return;
    }

    setState(() => isLoading = true);

    final now = DateTime.now();
    final open = DateTime(
        now.year, now.month, now.day, openingTime!.hour, openingTime!.minute);
    final close = DateTime(
        now.year, now.month, now.day, closingTime!.hour, closingTime!.minute);

    final slotsRef = FirebaseFirestore.instance
        .collection('salons')
        .doc(widget.salonId)
        .collection('slots');

    await slotsRef.get().then((snap) async {
      for (var doc in snap.docs) {
        await doc.reference.delete(); // Clear previous slots
      }
    });

    WriteBatch batch = FirebaseFirestore.instance.batch();

    DateTime slotStart = open;
    while (slotStart.isBefore(close)) {
      DateTime slotEnd = slotStart.add(Duration(minutes: slotDuration));
      for (int i = 0; i < numBarbers; i++) {
        final slotId = "${DateFormat.Hm().format(slotStart)}_b$i";
        final slotDoc = slotsRef.doc(slotId);
        batch.set(slotDoc, {
          'startTime': slotStart.toIso8601String(),
          'endTime': slotEnd.toIso8601String(),
          'barberIndex': i,
          'isBooked': false,
        });
      }
      slotStart = slotStart.add(Duration(minutes: slotDuration));
    }

    await batch.commit();

    // Save config to salon doc
    await FirebaseFirestore.instance
        .collection('salons')
        .doc(widget.salonId)
        .update({
      'openingTime':
          "${openingTime!.hour}:${openingTime!.minute.toString().padLeft(2, '0')}",
      'closingTime':
          "${closingTime!.hour}:${closingTime!.minute.toString().padLeft(2, '0')}",
      'slotDuration': slotDuration,
      'barberCount': numBarbers,
    });

    setState(() => isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Slots generated successfully')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Manage Slots")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => pickTime(true),
                    child: Text(openingTime == null
                        ? "Select Opening Time"
                        : "Open: ${openingTime!.format(context)}"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => pickTime(false),
                    child: Text(closingTime == null
                        ? "Select Closing Time"
                        : "Close: ${closingTime!.format(context)}"),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<int>(
              value: slotDuration,
              decoration:
                  const InputDecoration(labelText: "Slot Duration (minutes)"),
              items: const [15, 30, 45, 60].map((value) {
                return DropdownMenuItem<int>(
                  value: value,
                  child: Text("$value minutes"),
                );
              }).toList(),
              onChanged: (value) => setState(() => slotDuration = value!),
            ),
            const SizedBox(height: 20),
            TextFormField(
              keyboardType: TextInputType.number,
              decoration:
                  const InputDecoration(labelText: "Number of Barbers/Chairs"),
              initialValue: numBarbers.toString(),
              onChanged: (val) => numBarbers = int.tryParse(val) ?? 1,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: isLoading ? null : generateSlots,
              child: isLoading
                  ? const CircularProgressIndicator()
                  : const Text("Generate Slots"),
            ),
          ],
        ),
      ),
    );
  }
}
