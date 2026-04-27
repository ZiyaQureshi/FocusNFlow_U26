import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/firestore_service.dart';

class SessionScreen extends StatefulWidget {
  final String groupId;
  final String groupName;

  const SessionScreen({
    super.key,
    required this.groupId,
    required this.groupName,
  });

  @override
  State<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends State<SessionScreen> {
  final service = FirestoreService();

  void openCreateSessionDialog() {
    final titleController = TextEditingController();

    DateTime startTime = DateTime.now().add(const Duration(hours: 1));
    DateTime endTime = DateTime.now().add(const Duration(hours: 2));

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Schedule Study Session'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Session Title',
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2030),
                    initialDate: startTime,
                  );

                  if (pickedDate == null) return;

                  final pickedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.fromDateTime(startTime),
                  );

                  if (pickedTime == null) return;

                  startTime = DateTime(
                    pickedDate.year,
                    pickedDate.month,
                    pickedDate.day,
                    pickedTime.hour,
                    pickedTime.minute,
                  );

                  endTime = startTime.add(const Duration(hours: 1));
                },
                child: const Text('Pick Start Time'),
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
                await service.createStudySession(
                  groupId: widget.groupId,
                  title: titleController.text.trim(),
                  startTime: startTime,
                  endTime: endTime,
                );

                Navigator.pop(context);
              },
              child: const Text('Schedule'),
            ),
          ],
        );
      },
    );
  }

  String formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.groupName} Sessions'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: service.sessionStream(widget.groupId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final sessions = snapshot.data!.docs;

          if (sessions.isEmpty) {
            return const Center(
              child: Text('No sessions scheduled yet.'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: sessions.length,
            itemBuilder: (context, index) {
              final data = sessions[index].data() as Map<String, dynamic>;

              final startTime = (data['startTime'] as Timestamp).toDate();
              final endTime = (data['endTime'] as Timestamp).toDate();

              return Card(
                child: ListTile(
                  leading: const Icon(Icons.event_available),
                  title: Text(data['title'] ?? 'Study Session'),
                  subtitle: Text(
                    'Starts: ${formatDate(startTime)}\n'
                    'Ends: ${formatDate(endTime)}',
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: openCreateSessionDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}