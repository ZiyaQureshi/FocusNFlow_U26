import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/firestore_service.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  int calculatePriority(Map<String, dynamic> task) {
    final deadline = (task['deadline'] as Timestamp).toDate();
    final daysLeft = deadline.difference(DateTime.now()).inDays + 1;
    final effort = task['effortHours'] ?? 1;
    final weight = task['courseWeight'] ?? 1;

    return (weight * 10) + effort + (10 ~/ daysLeft.clamp(1, 100));
  }

  String formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final service = FirestoreService();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Welcome to FocusNFlow 👋',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Organize tasks, find study rooms, and collaborate with your groups.',
          ),
          const SizedBox(height: 20),

          _sectionTitle('High Priority Tasks'),
          StreamBuilder<QuerySnapshot>(
            stream: service.taskStream(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final tasks = snapshot.data!.docs;

              tasks.sort((a, b) {
                final aData = a.data() as Map<String, dynamic>;
                final bData = b.data() as Map<String, dynamic>;
                return calculatePriority(bData)
                    .compareTo(calculatePriority(aData));
              });

              final topTasks = tasks.take(3).toList();

              if (topTasks.isEmpty) {
                return const Card(
                  child: ListTile(
                    title: Text('No tasks yet'),
                    subtitle: Text('Add tasks in the Study Planner.'),
                  ),
                );
              }

              return Column(
                children: topTasks.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final deadline = (data['deadline'] as Timestamp).toDate();

                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.task_alt),
                      title: Text(data['title'] ?? 'Task'),
                      subtitle: Text(
                        '${data['course'] ?? 'Course'} • Due ${formatDate(deadline)}\n'
                        'Priority Score: ${calculatePriority(data)}',
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),

          const SizedBox(height: 20),

          _sectionTitle('Available Study Rooms'),
          StreamBuilder<QuerySnapshot>(
            stream: service.roomStream(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final rooms = snapshot.data!.docs.take(3).toList();

              if (rooms.isEmpty) {
                return const Card(
                  child: ListTile(
                    title: Text('No rooms found'),
                    subtitle: Text('Add studyRooms documents in Firestore.'),
                  ),
                );
              }

              return Column(
                children: rooms.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final capacity = data['capacity'] ?? 0;
                  final occupancy = data['occupancy'] ?? 0;
                  final available = capacity - occupancy;

                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.meeting_room),
                      title: Text(data['name'] ?? 'Study Room'),
                      subtitle: Text(
                        '${data['location'] ?? 'Campus'} • $available seats available',
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),

          const SizedBox(height: 20),

          _sectionTitle('Recent Study Groups'),
          StreamBuilder<QuerySnapshot>(
            stream: service.groupStream(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final groups = snapshot.data!.docs.take(3).toList();

              if (groups.isEmpty) {
                return const Card(
                  child: ListTile(
                    title: Text('No groups yet'),
                    subtitle: Text('Create or join a group from the Groups tab.'),
                  ),
                );
              }

              return Column(
                children: groups.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;

                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.groups),
                      title: Text(data['name'] ?? 'Study Group'),
                      subtitle: Text(data['course'] ?? 'Course'),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 19,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}