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
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF00796B),
                  Color(0xFF26A69A),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome back 👋',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Plan smarter, find study spaces, and stay focused.',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Image.asset(
                  'assets/images/study_planner.png',
                  height: 95,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          Row(
            children: [
              _quickCard(
                title: 'Planner',
                image: 'assets/images/study_planner.png',
              ),
              const SizedBox(width: 12),
              _quickCard(
                title: 'Rooms',
                image: 'assets/images/study_room.png',
              ),
              const SizedBox(width: 12),
              _quickCard(
                title: 'Groups',
                image: 'assets/images/group_study.png',
              ),
            ],
          ),

          const SizedBox(height: 24),

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
                      leading: const CircleAvatar(
                        backgroundColor: Color(0xFFE0F2F1),
                        child: Icon(
                          Icons.task_alt,
                          color: Color(0xFF00796B),
                        ),
                      ),
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
                      leading: const CircleAvatar(
                        backgroundColor: Color(0xFFE0F2F1),
                        child: Icon(
                          Icons.meeting_room,
                          color: Color(0xFF00796B),
                        ),
                      ),
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
                      leading: const CircleAvatar(
                        backgroundColor: Color(0xFFE0F2F1),
                        child: Icon(
                          Icons.groups,
                          color: Color(0xFF00796B),
                        ),
                      ),
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

  Widget _quickCard({
    required String title,
    required String image,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        height: 120,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              color: Color(0x22000000),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Expanded(
              child: Image.asset(image),
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
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