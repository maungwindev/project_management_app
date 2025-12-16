import 'package:cloud_firestore/cloud_firestore.dart';
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
    await _taskRef(projectId).add({
      'title': title,
      'description': description,
      'status': status,
      'priority': priority,
      'assignees': assignees, // ✅ array
      'dueDate': Timestamp.fromDate(dueDate),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return const Right('Task created successfully');
  } catch (e) {
    logger.logError('Create Task Error: $e');
    return Left('Failed to create task');
  }
}


  // ---------------- READ TASKS (STREAM) ----------------
  Stream<Either<String, List<TaskResponseModel>>> getTasks({
  required String projectId,
}) {
  return firestore
      .collection('projects')
      .doc(projectId)
      .collection('tasks')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) {
        final tasks = snapshot.docs.map((doc) {
          return TaskResponseModel.fromFirestore(
            doc.id,
            doc.data(),
          );
        }).toList();

        return Right(tasks);
      });
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
    await _taskRef(projectId).doc(taskId).update({
      'assignees': FieldValue.arrayUnion([userId]),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return const Right('Assignee added');
  } catch (e) {
    logger.logError('Add Assignee Error: $e');
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
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return const Right('Assignee removed');
  } catch (e) {
    logger.logError('Remove Assignee Error: $e');
    return Left('Failed to remove assignee');
  }
}

}
