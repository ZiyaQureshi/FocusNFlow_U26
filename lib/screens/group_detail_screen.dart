import 'package:flutter/material.dart';

import 'chat_screen.dart';
import 'session_screen.dart';
import 'shared_timer_screen.dart';

class GroupDetailScreen extends StatelessWidget {
  final String groupId;
  final String groupName;

  const GroupDetailScreen({
    super.key,
    required this.groupId,
    required this.groupName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(groupName),
      ),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              groupName,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Manage group chat, study sessions, and shared timer.',
            ),
            const SizedBox(height: 24),

            _featureCard(
              context: context,
              icon: Icons.chat,
              title: 'Group Chat',
              subtitle: 'Send real-time messages with group members.',
              screen: ChatScreen(
                groupId: groupId,
                groupName: groupName,
              ),
            ),

            _featureCard(
              context: context,
              icon: Icons.event,
              title: 'Study Sessions',
              subtitle: 'Schedule upcoming group study sessions.',
              screen: SessionScreen(
                groupId: groupId,
                groupName: groupName,
              ),
            ),

            _featureCard(
              context: context,
              icon: Icons.timer,
              title: 'Shared Study Timer',
              subtitle: 'Use a shared Pomodoro timer and group goals.',
              screen: SharedTimerScreen(
                groupId: groupId,
                groupName: groupName,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _featureCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget screen,
  }) {
    return Card(
      child: ListTile(
        leading: Icon(icon, size: 34),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => screen),
          );
        },
      ),
    );
  }
}