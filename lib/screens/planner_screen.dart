import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';

class PlannerScreen extends StatefulWidget {
  const PlannerScreen({super.key});

  @override
  State<PlannerScreen> createState() => _PlannerScreenState();
}

class _PlannerScreenState extends State<PlannerScreen> {
  final service = FirestoreService();

  void openAddTaskDialog() {
    final titleController = TextEditingController();
    final courseController = TextEditingController();
    final effortController = TextEditingController();
    final weightController = TextEditingController();

    DateTime selectedDeadline = DateTime.now().add(const Duration(days: 1));

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Study Task'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Task Title'),
                ),
                TextField(
                  controller: courseController,
                  decoration: const InputDecoration(labelText: 'Course'),
                ),
                TextField(
                  controller: effortController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Effort Hours'),
                ),
                TextField(
                  controller: weightController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Course Weight / Priority',
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2030),
                      initialDate: selectedDeadline,
                    );

                    if (picked != null) {
                      selectedDeadline = picked;
                    }
                  },
                  child: const Text('Select Deadline'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                await service.addTask(
                  title: titleController.text,
                  course: courseController.text,
                  deadline: selectedDeadline,
                  effortHours: int.tryParse(effortController.text) ?? 1,
                  courseWeight: int.tryParse(weightController.text) ?? 1,
                );

                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  int calculatePriority(Map<String, dynamic> task) {
    final deadline = (task['deadline'] as Timestamp).toDate();
    final daysLeft = deadline.difference(DateTime.now()).inDays + 1;
    final effort = task['effortHours'] ?? 1;
    final weight = task['courseWeight'] ?? 1;

    return (weight * 10) + effort + (10 ~/ daysLeft.clamp(1, 100));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: service.taskStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          docs.sort((a, b) {
            final aData = a.data() as Map<String, dynamic>;
            final bData = b.data() as Map<String, dynamic>;
            return calculatePriority(bData).compareTo(calculatePriority(aData));
          });

          if (docs.isEmpty) {
            return const Center(
              child: Text('No tasks yet. Add your first study task.'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;
              final deadline = (data['deadline'] as Timestamp).toDate();
              final priority = calculatePriority(data);

              return Card(
                child: ListTile(
                  leading: Checkbox(
                    value: data['completed'] ?? false,
                    onChanged: (value) {
                      service.toggleTask(doc.id, value ?? false);
                    },
                  ),
                  title: Text(data['title']),
                  subtitle: Text(
                    '${data['course']} | Due: ${deadline.month}/${deadline.day}/${deadline.year}\n'
                    'Effort: ${data['effortHours']} hrs | Weight: ${data['courseWeight']} | Priority Score: $priority',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => service.deleteTask(doc.id),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: openAddTaskDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}