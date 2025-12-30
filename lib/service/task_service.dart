import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:pm_app/core/service/firebase_noiti_service.dart';
import 'package:pm_app/core/utils/custom_logger.dart';
import 'package:pm_app/models/response_models/response_model.dart';

class TaskService {
  final FirebaseFirestore firestore;
  final CustomLogger logger;
  final FirebaseNotificationService notificationService;
  TaskService({
    required this.firestore,
    required this.logger,
    required this.notificationService
  });

  CollectionReference<Map<String, dynamic>> _taskRef(String projectId) {
    return firestore
        .collection('projects')
        .doc(projectId)
        .collection('tasks');
  }

 
  
  
    

  // ---------------- CREATE TASK ----------------
  Future<Either<String, String>> createTask({
  required String projectId,
  required String title,
  required String description,
  required String status,
  required String priority,
  required List<String> assignees,
  required DateTime dueDate,
}) async {
  try {
    final currentUid = FirebaseAuth.instance.currentUser!.uid;
    final taskRef = _taskRef(projectId).doc();

    // 1️⃣ Create task
    await taskRef.set({
      'projectId': projectId,
      'title': title,
      'description': description,
      'status': status,
      'priority': priority,
      'assignees': assignees,
      'dueDate': Timestamp.fromDate(dueDate),
      'createdAt': Timestamp.now(),
      'updatedAt': Timestamp.now(),
      'createdBy': currentUid,
    });

    // 2️⃣ Sync project members
    if (assignees.isNotEmpty) {
      await firestore.collection('projects').doc(projectId).update({
        'members': FieldValue.arrayUnion(assignees),
      });
    }

    // 3️⃣ 🔔 Send notifications (Firestore-triggered)
    if (assignees.isNotEmpty) {
      for (final uid in assignees) {
        if (uid == currentUid) continue; // ❌ skip self

        await notificationService.sendNotification(
          fromUid: currentUid,
          toUid: uid,
          title: 'New Task Assigned',
          body: 'You have been assigned a task: $title',
          data: {
            'type': 'task',
            'projectId': projectId,
            'taskId': taskRef.id,
          },
        );
      }
    }

    return const Right('Task created successfully');
  } catch (e) {
    debugPrint('Create task error: $e');
    return Left('Failed to create task');
  }
}




  // ---------------- READ TASKS (STREAM) ----------------
  Stream<Either<String, List<TaskResponseModel>>> getTasks({
  required String projectId,
  required String ownerId, // pass project ownerId
}) {
  final uid = FirebaseAuth.instance.currentUser!.uid;

  return firestore
      .collection('projects')
      .doc(projectId)
      .collection('tasks')
      .orderBy('createdAt', descending: true)
      .snapshots(includeMetadataChanges: true)
      .map<Either<String, List<TaskResponseModel>>>((snapshot) {
        try {
          final tasks = snapshot.docs.map((doc) {
            return TaskResponseModel.fromFirestore(doc.id, doc.data());
          }).where((task) {
            // User can see task if they are owner OR assigned
            return uid == ownerId || task.assignees.contains(uid);
          }).toList();

          return Right(tasks);
        } catch (e) {
          return Left('Failed to parse task data: $e');
        }
      }).handleError((e) => Left('Firestore error: $e'));
}



  // ---------------- UPDATE TASK ----------------
  Future<Either<String, String>> updateTask({
    required String projectId,
    required String taskId,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _taskRef(projectId).doc(taskId).update({
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return const Right('Task updated successfully');
    } catch (e) {
      logger.logError('Update Task Error: $e');
      return Left('Failed to update task');
    }
  }

  // ---------------- UPDATE TASK STATUS ONLY ----------------
  Future<Either<String, String>> updateTaskStatus({
  required String projectId,
  required String taskId,
  required String status,
}) async {
  try {
    final currentUid = FirebaseAuth.instance.currentUser!.uid;
    final taskDocRef = _taskRef(projectId).doc(taskId);

    // 1️⃣ Read task
    final taskSnap = await taskDocRef.get();
    if (!taskSnap.exists) {
      return Left('Task not found');
    }

    final taskData = taskSnap.data()!;
    final oldStatus = taskData['status'] as String;
    final taskTitle = taskData['title'] as String;
    final List<String> assignees =
        List<String>.from(taskData['assignees'] ?? []);

    // 2️⃣ Status unchanged → skip
    if (oldStatus == status) {
      return const Right('Status unchanged');
    }

    // 3️⃣ Update status
    await taskDocRef.update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // 4️⃣ 🔔 Notify assignees
    for (final uid in assignees) {
      print('final uid::${uid}');
      //if (uid == currentUid) continue; // ❌ skip self

      await notificationService.sendNotification(
        fromUid: currentUid,
        toUid: uid,
        title: 'Task Status Updated',
        body: 'Task "$taskTitle" is now $status',
        data: {
          'type': 'task_status',
          'projectId': projectId,
          'taskId': taskId,
          'status': status,
        },
      );
    }

    return const Right('Task status updated');
  } catch (e) {
    logger.logError('Update Status Error: $e');
    return Left('Failed to update status');
  }
}


  // ---------------- DELETE TASK ----------------
  Future<Either<String, String>> deleteTask({
    required String projectId,
    required String taskId,
  }) async {
    try {
      await _taskRef(projectId).doc(taskId).delete();
      return const Right('Task deleted successfully');
    } catch (e) {
      logger.logError('Delete Task Error: $e');
      return Left('Failed to delete task');
    }
  }

  Future<Either<String, String>> addAssignee({
  required String projectId,
  required String taskId,
  required String userId,
}) async {
  try {
    // 1️⃣ Update task locally (offline-safe)
    await _taskRef(projectId).doc(taskId).update({
      'assignees': FieldValue.arrayUnion([userId]),
      'updatedAt': Timestamp.now(),
    });

    // 2️⃣ Update project members (best-effort)
    firestore.collection('projects').doc(projectId).update({
      'members': FieldValue.arrayUnion([userId]),
    });

    return const Right('Assignee added');
  } catch (e) {
    return Left('Failed to add assignee');
  }
}



Future<Either<String, String>> removeAssignee({
  required String projectId,
  required String taskId,
  required String userId,
}) async {
  try {
    await _taskRef(projectId).doc(taskId).update({
      'assignees': FieldValue.arrayRemove([userId]),
      'updatedAt': Timestamp.now(),
    });

    firestore.collection('projects').doc(projectId).update({
      'members': FieldValue.arrayRemove([userId]),
    });

    return const Right('Assignee removed');
  } catch (e) {
    return Left('Failed to remove assignee');
  }
}


Stream<Either<String, List<TaskResponseModel>>> getTodayTasksForDashboard() {
  final uid = FirebaseAuth.instance.currentUser!.uid;
  final now = DateTime.now();
  final startOfDay = DateTime(now.year, now.month, now.day);
  final endOfDay = startOfDay.add(const Duration(days: 1));

  return firestore
      .collectionGroup('tasks') // 🔥 IMPORTANT
      .where('dueDate', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
      .where('dueDate', isLessThan: Timestamp.fromDate(endOfDay))
      .orderBy('dueDate')
      .snapshots()
      .map<Either<String, List<TaskResponseModel>>>((snapshot) {
        try {
          final tasks = snapshot.docs
              .map((doc) => TaskResponseModel.fromFirestore(doc.id, doc.data()))
              .where((task) {
                // user must be owner or assignee
                return task.assignees.contains(uid);
              })
              .toList();

          return Right(tasks);
        } catch (e) {
          return Left('Failed to parse dashboard tasks: $e');
        }
      });
}


}
