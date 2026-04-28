import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/firestore_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final service = FirestoreService();

  Future<DocumentSnapshot> getOrCreateProfile() async {
    final user = service.auth.currentUser!;
    final ref = service.db.collection('users').doc(service.uid);

    final doc = await ref.get();

    if (!doc.exists) {
      await ref.set({
        'uid': service.uid,
        'name': 'Not provided',
        'email': user.email ?? '',
        'major': 'Not provided',
        'createdAt': FieldValue.serverTimestamp(),
      });

      return await ref.get();
    }

    return doc;
  }

  void openEditProfileDialog(Map<String, dynamic> data) {
    final nameController = TextEditingController(
      text: data['name'] == 'Not provided' ? '' : data['name'],
    );

    final majorController = TextEditingController(
      text: data['major'] == 'Not provided' ? '' : data['major'],
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Profile'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: majorController,
                decoration: const InputDecoration(
                  labelText: 'Major',
                  prefixIcon: Icon(Icons.school),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                await service.db.collection('users').doc(service.uid).update({
                  'name': nameController.text.trim().isEmpty
                      ? 'Not provided'
                      : nameController.text.trim(),
                  'major': majorController.text.trim().isEmpty
                      ? 'Not provided'
                      : majorController.text.trim(),
                });

                if (!mounted) return;

                Navigator.pop(context);

                setState(() {});
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: getOrCreateProfile(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error loading profile:\n${snapshot.error}',
              textAlign: TextAlign.center,
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Center(
            child: Text('Profile not found.'),
          );
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: () => openEditProfileDialog(data),
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit'),
                ),
              ),

              const SizedBox(height: 12),

              const CircleAvatar(
                radius: 60,
                backgroundColor: Color(0xFFE0F2F1),
                backgroundImage: AssetImage(
                  'assets/images/profile_avatar.png',
                ),
              ),

              const SizedBox(height: 16),

              Text(
                data['name'] ?? 'Not provided',
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
                        value: data['name'] ?? 'Not provided',
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
                        value: data['major'] ?? 'Not provided',
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              const Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Color(0xFFE0F2F1),
                    child: Icon(
                      Icons.info,
                      color: Color(0xFF00796B),
                    ),
                  ),
                  title: Text('About FocusNFlow'),
                  subtitle: Text(
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