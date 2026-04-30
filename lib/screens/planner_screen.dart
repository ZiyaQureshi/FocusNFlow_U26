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

  Widget _fieldLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, top: 4),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Color(0xFF374057),
        ),
      ),
    );
  }

  Widget _styledField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboard = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboard,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFFAAAAAA), fontSize: 13),
        prefixIcon: Icon(icon, color: const Color(0xFF0039A6), size: 18),
        filled: true,
        fillColor: const Color(0xFFF5F5F7),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE2E2E6)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF0039A6), width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      ),
    );
  }

  void openAddTaskDialog() {
    final titleController    = TextEditingController();
    final courseController   = TextEditingController();
    final effortController   = TextEditingController();
    final weightController   = TextEditingController();
    DateTime selectedDeadline = DateTime.now().add(const Duration(days: 1));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE6F1FB),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.edit_calendar_rounded,
                            color: Color(0xFF0039A6),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Add study task',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF374057),
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close, color: Color(0xFF888888)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _fieldLabel('Task title'),
                    _styledField(
                      controller: titleController,
                      hint: 'e.g. CS401 Final Project',
                      icon: Icons.task_alt_rounded,
                    ),
                    _fieldLabel('Course'),
                    _styledField(
                      controller: courseController,
                      hint: 'e.g. CS401',
                      icon: Icons.school_outlined,
                    ),
                    _fieldLabel('Effort hours'),
                    _styledField(
                      controller: effortController,
                      hint: 'e.g. 8',
                      icon: Icons.timer_outlined,
                      keyboard: TextInputType.number,
                    ),
                    _fieldLabel('Course weight / priority'),
                    _styledField(
                      controller: weightController,
                      hint: 'e.g. 40 (for 40% of grade)',
                      icon: Icons.bar_chart_rounded,
                      keyboard: TextInputType.number,
                    ),
                    _fieldLabel('Deadline'),
                    GestureDetector(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2030),
                          initialDate: selectedDeadline,
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: const ColorScheme.light(
                                  primary: Color(0xFF0039A6),
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (picked != null) {
                          setModalState(() => selectedDeadline = picked);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F7),
                          border: Border.all(color: const Color(0xFFE2E2E6)),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.calendar_today_rounded,
                              color: Color(0xFF0039A6),
                              size: 18,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              '${selectedDeadline.month}/${selectedDeadline.day}/${selectedDeadline.year}',
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF374057),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () async {
                        await service.addTask(
                          title: titleController.text,
                          course: courseController.text,
                          deadline: selectedDeadline,
                          effortHours: int.tryParse(effortController.text) ?? 1,
                          courseWeight: int.tryParse(weightController.text) ?? 1,
                        );
                        if (!mounted) return;
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0039A6),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Save task',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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

  int calculatePriority(Map<String, dynamic> task) {
    final deadline = (task['deadline'] as Timestamp).toDate();
    final daysLeft = deadline.difference(DateTime.now()).inDays + 1;
    final effort   = task['effortHours'] ?? 1;
    final weight   = task['courseWeight'] ?? 1;
    return (weight * 10) + effort + (10 ~/ daysLeft.clamp(1, 100));
  }
  Widget _priorityBadge(int score) {
    Color color;
    String label;
    if (score >= 50) {
      color = const Color(0xFFCC0000);
      label = 'High';
    } else if (score >= 25) {
      color = const Color(0xFFEF9F27);
      label = 'Medium';
    } else {
      color = const Color(0xFF1D9E75);
      label = 'Low';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      body: StreamBuilder<QuerySnapshot>(
        stream: service.taskStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF0039A6)),
            );
          }

          final docs = snapshot.data!.docs;

          docs.sort((a, b) {
            final aData = a.data() as Map<String, dynamic>;
            final bData = b.data() as Map<String, dynamic>;
            return calculatePriority(bData).compareTo(calculatePriority(aData));
          });

          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE6F1FB),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.edit_calendar_rounded,
                      color: Color(0xFF0039A6),
                      size: 36,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No tasks yet',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF374057),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Tap + to add your first study task',
                    style: TextStyle(fontSize: 13, color: Color(0xFF888888)),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc      = docs[index];
              final data     = doc.data() as Map<String, dynamic>;
              final deadline = (data['deadline'] as Timestamp).toDate();
              final priority = calculatePriority(data);
              final daysLeft = deadline.difference(DateTime.now()).inDays;
              final completed = data['completed'] ?? false;

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFEEEEEE)),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: Checkbox(
                          value: completed,
                          activeColor: const Color(0xFF0039A6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          onChanged: (value) =>
                              service.toggleTask(doc.id, value ?? false),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    data['title'] ?? 'Task',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: completed
                                          ? const Color(0xFFAAAAAA)
                                          : const Color(0xFF374057),
                                      decoration: completed
                                          ? TextDecoration.lineThrough
                                          : null,
                                    ),
                                  ),
                                ),
                                _priorityBadge(priority),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${data['course'] ?? 'Course'} · Due ${deadline.month}/${deadline.day}/${deadline.year}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF888888),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(
                                  Icons.timer_outlined,
                                  size: 12,
                                  color: Color(0xFFAAAAAA),
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  '${data['effortHours']} hrs',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFFAAAAAA),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Icon(
                                  Icons.schedule_rounded,
                                  size: 12,
                                  color: daysLeft <= 2
                                      ? const Color(0xFFCC0000)
                                      : const Color(0xFFAAAAAA),
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  daysLeft <= 0
                                      ? 'Due today'
                                      : '$daysLeft days left',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: daysLeft <= 2
                                        ? const Color(0xFFCC0000)
                                        : const Color(0xFFAAAAAA),
                                    fontWeight: daysLeft <= 2
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline_rounded,
                          color: Color(0xFFCCCCCC),
                          size: 20,
                        ),
                        onPressed: () => service.deleteTask(doc.id),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: openAddTaskDialog,
        backgroundColor: const Color(0xFF0039A6),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Add task',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}