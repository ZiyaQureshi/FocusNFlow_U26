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

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.bold,
          color: Color(0xFF374057),
        ),
      ),
    );
  }
  Widget _listCard({
    required IconData icon,
    required String title,
    required String subtitle,
    Color iconBg = const Color(0xFFE6F1FB),
    Color iconColor = const Color(0xFF0039A6),
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374057),
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 12, color: Color(0xFF888888)),
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: Color(0xFFCCCCCC),
          size: 20,
        ),
      ),
    );
  }

  Widget _quickCard({
    required String title,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final service = FirestoreService();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF0039A6),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.school_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'FocusNFlow',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.3,
                          ),
                        ),
                        Text(
                          'Georgia State University',
                          style: TextStyle(color: Colors.white70, fontSize: 11),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Welcome back 👋',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Plan smarter, find study spaces,\nand stay focused.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(
                        Icons.calendar_today_rounded,
                        color: Colors.white,
                        size: 14,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'View today\'s schedule',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          _sectionTitle('Quick actions'),
          Row(
            children: [
              _quickCard(
                title: 'Planner',
                icon: Icons.edit_calendar_rounded,
                color: const Color(0xFF0039A6),
              ),
              const SizedBox(width: 10),
              _quickCard(
                title: 'Rooms',
                icon: Icons.meeting_room_rounded,
                color: const Color(0xFF0071CE),
              ),
              const SizedBox(width: 10),
              _quickCard(
                title: 'Groups',
                icon: Icons.groups_rounded,
                color: const Color(0xFF374057),
              ),
              const SizedBox(width: 10),
              _quickCard(
                title: 'Timer',
                icon: Icons.timer_rounded,
                color: const Color(0xFFCC0000),
              ),
            ],
          ),

          const SizedBox(height: 24),

          _sectionTitle('High priority tasks'),
          StreamBuilder<QuerySnapshot>(
            stream: service.taskStream(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(color: Color(0xFF0039A6)),
                  ),
                );
              }

              final tasks = snapshot.data!.docs;

              tasks.sort((a, b) {
                final aData = a.data() as Map<String, dynamic>;
                final bData = b.data() as Map<String, dynamic>;
                return calculatePriority(
                  bData,
                ).compareTo(calculatePriority(aData));
              });

              final topTasks = tasks.take(3).toList();

              if (topTasks.isEmpty) {
                return _listCard(
                  icon: Icons.task_alt,
                  title: 'No tasks yet',
                  subtitle: 'Add tasks in the Study Planner',
                );
              }

              return Column(
                children: topTasks.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final deadline = (data['deadline'] as Timestamp).toDate();
                  final daysLeft = deadline.difference(DateTime.now()).inDays;
                  final isUrgent = daysLeft <= 2;

                  return _listCard(
                    icon: Icons.task_alt_rounded,
                    title: data['title'] ?? 'Task',
                    subtitle:
                        '${data['course'] ?? 'Course'} · Due ${formatDate(deadline)} · Score: ${calculatePriority(data)}',
                    iconBg: isUrgent
                        ? const Color(0xFFFCEBEB)
                        : const Color(0xFFE6F1FB),
                    iconColor: isUrgent
                        ? const Color(0xFFCC0000)
                        : const Color(0xFF0039A6),
                  );
                }).toList(),
              );
            },
          ),

          const SizedBox(height: 24),

          _sectionTitle('Available study rooms'),
          StreamBuilder<QuerySnapshot>(
            stream: service.roomStream(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(color: Color(0xFF0039A6)),
                  ),
                );
              }

              final rooms = snapshot.data!.docs.take(3).toList();

              if (rooms.isEmpty) {
                return _listCard(
                  icon: Icons.meeting_room_rounded,
                  title: 'No rooms found',
                  subtitle: 'Add studyRooms documents in Firestore',
                );
              }

              return Column(
                children: rooms.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final capacity = data['capacity'] ?? 0;
                  final occupancy = data['occupancy'] ?? 0;
                  final available = capacity - occupancy;
                  final isFull = available == 0;

                  return _listCard(
                    icon: Icons.meeting_room_rounded,
                    title: data['name'] ?? 'Study Room',
                    subtitle:
                        '${data['location'] ?? 'Campus'} · $available seats available',
                    iconBg: isFull
                        ? const Color(0xFFFCEBEB)
                        : const Color(0xFFE3F7F0),
                    iconColor: isFull
                        ? const Color(0xFFCC0000)
                        : const Color(0xFF1D9E75),
                  );
                }).toList(),
              );
            },
          ),

          const SizedBox(height: 24),

          _sectionTitle('Recent study groups'),
          StreamBuilder<QuerySnapshot>(
            stream: service.groupStream(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(color: Color(0xFF0039A6)),
                  ),
                );
              }

              final groups = snapshot.data!.docs.take(3).toList();

              if (groups.isEmpty) {
                return _listCard(
                  icon: Icons.groups_rounded,
                  title: 'No groups yet',
                  subtitle: 'Create or join a group from the Groups tab',
                );
              }

              return Column(
                children: groups.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return _listCard(
                    icon: Icons.groups_rounded,
                    title: data['name'] ?? 'Study Group',
                    subtitle: data['course'] ?? 'Course',
                    iconBg: const Color(0xFFEEEDFE),
                    iconColor: const Color(0xFF374057),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
