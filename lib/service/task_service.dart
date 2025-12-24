import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fpdart/fpdart.dart';
import 'package:pm_app/core/utils/custom_logger.dart';
import 'package:pm_app/models/response_models/response_model.dart';

class TaskService {
  final FirebaseFirestore firestore;
  final CustomLogger logger;

  TaskService({
    required this.firestore,
    required this.logger,
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
    final taskRef = _taskRef(projectId).doc();

    await taskRef.set({
      'projectId': projectId,
      'title': title,
      'description': description,
      'status': status,
      'priority': priority,
      'assignees': assignees,
      'dueDate': Timestamp.fromDate(dueDate),

      // 🔥 MUST be client timestamps
      'createdAt': Timestamp.now(),
      'updatedAt': Timestamp.now(),
    });

    // OPTIONAL — sync project members later
    firestore.collection('projects').doc(projectId).update({
      'members': FieldValue.arrayUnion(assignees),
    });

    return const Right('Task created successfully');
  } catch (e) {
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
      await _taskRef(projectId).doc(taskId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });

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
