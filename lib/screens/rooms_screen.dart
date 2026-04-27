import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';

class RoomsScreen extends StatelessWidget {
  const RoomsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = FirestoreService();

    return StreamBuilder<QuerySnapshot>(
      stream: service.roomStream(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final rooms = snapshot.data!.docs;

        if (rooms.isEmpty) {
          return const Center(
            child: Text(
              'No study rooms found.\nAdd sample rooms in Firestore collection: studyRooms',
              textAlign: TextAlign.center,
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: rooms.length,
          itemBuilder: (context, index) {
            final doc = rooms[index];
            final data = doc.data() as Map<String, dynamic>;

            final occupancy = data['occupancy'] ?? 0;
            final capacity = data['capacity'] ?? 1;
            final available = capacity - occupancy;

            return Card(
              child: ListTile(
                title: Text(data['name'] ?? 'Study Room'),
                subtitle: Text(
                  'Location: ${data['location'] ?? 'Campus'}\n'
                  'Occupancy: $occupancy / $capacity\n'
                  'Available Seats: $available',
                ),
                trailing: Wrap(
                  spacing: 4,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: () {
                        service.updateRoomOccupancy(doc.id, -1);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        service.updateRoomOccupancy(doc.id, 1);
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}