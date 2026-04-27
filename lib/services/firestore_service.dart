import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore db = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  String get uid => auth.currentUser!.uid;

  CollectionReference get tasks =>
      db.collection('users').doc(uid).collection('tasks');

  CollectionReference get rooms => db.collection('studyRooms');

  CollectionReference get groups => db.collection('studyGroups');

  Future<void> addTask({
    required String title,
    required String course,
    required DateTime deadline,
    required int effortHours,
    required int courseWeight,
  }) async {
    await tasks.add({
      'title': title,
      'course': course,
      'deadline': Timestamp.fromDate(deadline),
      'effortHours': effortHours,
      'courseWeight': courseWeight,
      'completed': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> toggleTask(String taskId, bool completed) async {
    await tasks.doc(taskId).update({'completed': completed});
  }

  Future<void> deleteTask(String taskId) async {
    await tasks.doc(taskId).delete();
  }

  Stream<QuerySnapshot> taskStream() {
    return tasks.orderBy('deadline').snapshots();
  }

  Stream<QuerySnapshot> roomStream() {
    return rooms.orderBy('name').snapshots();
  }

  Future<void> updateRoomOccupancy(String roomId, int change) async {
    final roomRef = rooms.doc(roomId);

    await db.runTransaction((transaction) async {
      final snapshot = await transaction.get(roomRef);

      final current = snapshot['occupancy'] ?? 0;
      final capacity = snapshot['capacity'] ?? 1;
      int updated = current + change;

      if (updated < 0) updated = 0;
      if (updated > capacity) updated = capacity;

      transaction.update(roomRef, {'occupancy': updated});
    });
  }

  Future<void> createGroup({
    required String name,
    required String course,
    required String description,
  }) async {
    final groupRef = await groups.add({
      'name': name,
      'course': course,
      'description': description,
      'createdBy': uid,
      'createdAt': FieldValue.serverTimestamp(),
    });

    await groupRef.collection('members').doc(uid).set({
      'uid': uid,
      'role': 'owner',
      'joinedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> joinGroup(String groupId) async {
    await groups.doc(groupId).collection('members').doc(uid).set({
      'uid': uid,
      'role': 'member',
      'joinedAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot> groupStream() {
    return groups.orderBy('createdAt', descending: true).snapshots();
  }

  Future<void> sendMessage({
    required String groupId,
    required String text,
  }) async {
    await groups.doc(groupId).collection('messages').add({
      'senderId': uid,
      'senderEmail': auth.currentUser?.email ?? '',
      'text': text,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot> messageStream(String groupId) {
    return groups
        .doc(groupId)
        .collection('messages')
        .orderBy('createdAt')
        .snapshots();
  }

  Future<void> createStudySession({
    required String groupId,
    required String title,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    await groups.doc(groupId).collection('sessions').add({
      'title': title,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
      'createdBy': uid,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot> sessionStream(String groupId) {
    return groups
        .doc(groupId)
        .collection('sessions')
        .orderBy('startTime')
        .snapshots();
  }

  Future<void> updateSharedTimer({
    required String groupId,
    required int minutes,
    required bool running,
    required String goal,
  }) async {
    await groups.doc(groupId).collection('shared').doc('timer').set({
      'minutes': minutes,
      'running': running,
      'goal': goal,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<DocumentSnapshot> timerStream(String groupId) {
    return groups.doc(groupId).collection('shared').doc('timer').snapshots();
  }
}