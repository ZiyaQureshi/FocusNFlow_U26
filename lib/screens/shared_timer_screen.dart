import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/firestore_service.dart';

class SharedTimerScreen extends StatefulWidget {
  final String groupId;
  final String groupName;

  const SharedTimerScreen({
    super.key,
    required this.groupId,
    required this.groupName,
  });

  @override
  State<SharedTimerScreen> createState() => _SharedTimerScreenState();
}

class _SharedTimerScreenState extends State<SharedTimerScreen> {
  final service = FirestoreService();
  final goalController = TextEditingController();

  Timer? localTimer;
  int minutes = 25;
  bool running = false;
  String goal = '';

  @override
  void dispose() {
    localTimer?.cancel();
    goalController.dispose();
    super.dispose();
  }

  Future<void> updateTimer() async {
    await service.updateSharedTimer(
      groupId: widget.groupId,
      minutes: minutes,
      running: running,
      goal: goalController.text.trim(),
    );
  }

  void startLocalTimer() {
    localTimer?.cancel();

    localTimer = Timer.periodic(const Duration(minutes: 1), (timer) async {
      if (!running) {
        timer.cancel();
        return;
      }

      if (minutes <= 0) {
        running = false;
        timer.cancel();
      } else {
        minutes--;
      }

      await updateTimer();
    });
  }

  Future<void> startTimer() async {
    setState(() {
      running = true;
      goal = goalController.text.trim();
    });

    await updateTimer();
    startLocalTimer();
  }

  Future<void> pauseTimer() async {
    setState(() {
      running = false;
    });

    localTimer?.cancel();
    await updateTimer();
  }

  Future<void> resetTimer() async {
    setState(() {
      running = false;
      minutes = 25;
    });

    localTimer?.cancel();
    await updateTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.groupName} Timer'),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: service.timerStream(widget.groupId),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data!.exists) {
            final data = snapshot.data!.data() as Map<String, dynamic>;

            minutes = data['minutes'] ?? 25;
            running = data['running'] ?? false;
            goal = data['goal'] ?? '';

            if (goalController.text.isEmpty && goal.isNotEmpty) {
              goalController.text = goal;
            }
          }

          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 20),
                Text(
                  '$minutes:00',
                  style: const TextStyle(
                    fontSize: 56,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  running ? 'Timer Running' : 'Timer Paused',
                  style: TextStyle(
                    color: running ? Colors.green : Colors.red,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: goalController,
                  decoration: const InputDecoration(
                    labelText: 'Shared Study Goal',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),
                Wrap(
                  spacing: 12,
                  children: [
                    ElevatedButton.icon(
                      onPressed: startTimer,
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Start'),
                    ),
                    ElevatedButton.icon(
                      onPressed: pauseTimer,
                      icon: const Icon(Icons.pause),
                      label: const Text('Pause'),
                    ),
                    ElevatedButton.icon(
                      onPressed: resetTimer,
                      icon: const Icon(Icons.restart_alt),
                      label: const Text('Reset'),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.flag),
                    title: const Text('Current Group Goal'),
                    subtitle: Text(goal.isEmpty ? 'No goal set yet.' : goal),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}