import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/firestore_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = FirestoreService();

    return FutureBuilder<DocumentSnapshot>(
      future: service.db.collection('users').doc(service.uid).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.data!.exists) {
          return const Center(child: Text('Profile not found.'));
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 20),

              CircleAvatar(
                radius: 58,
                backgroundColor: const Color(0xFFE0F2F1),
                backgroundImage: const AssetImage(
                  'assets/images/profile_avatar.png',
                ),
              ),

              const SizedBox(height: 18),

              Text(
                data['name'] ?? 'Student',
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                data['email'] ?? '',
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: 24),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    children: [
                      _profileTile(
                        icon: Icons.person,
                        title: 'Name',
                        value: data['name'] ?? '',
                      ),
                      const Divider(),
                      _profileTile(
                        icon: Icons.email,
                        title: 'Email',
                        value: data['email'] ?? '',
                      ),
                      const Divider(),
                      _profileTile(
                        icon: Icons.school,
                        title: 'Major',
                        value: data['major'] ?? '',
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Card(
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFE0F2F1),
                    child: Icon(
                      Icons.info,
                      color: Color(0xFF00796B),
                    ),
                  ),
                  title: const Text('About FocusNFlow'),
                  subtitle: const Text(
                    'A campus study organizer for planning tasks, finding study rooms, and collaborating with study groups.',
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _profileTile({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: const Color(0xFFE0F2F1),
        child: Icon(
          icon,
          color: const Color(0xFF00796B),
        ),
      ),
      title: Text(title),
      subtitle: Text(value.isEmpty ? 'Not provided' : value),
    );
  }
}