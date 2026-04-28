import 'package:flutter/material.dart';
import '../services/firestore_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final service = FirestoreService();

  final nameController = TextEditingController();
  final majorController = TextEditingController();

  bool loading = false;

  Future<void> saveProfile() async {
    setState(() => loading = true);

    await service.db.collection('users').doc(service.uid).update({
      'name': nameController.text.trim(),
      'major': majorController.text.trim(),
    });

    setState(() => loading = false);

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: majorController,
              decoration: const InputDecoration(
                labelText: 'Major',
              ),
            ),
            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: loading ? null : saveProfile,
              child: loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}