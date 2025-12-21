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
   await firestore.runTransaction((tx) async {
  final taskRef = _taskRef(projectId).doc();

  tx.set(taskRef, {
    'title': title,
    'description': description,
    'status': status,
    'priority': priority,
    'assignees': assignees,
    'dueDate': Timestamp.fromDate(dueDate),
    'createdAt': FieldValue.serverTimestamp(),
    'updatedAt': FieldValue.serverTimestamp(),
  });

  tx.update(
    firestore.collection('projects').doc(projectId),
    {
      'members': FieldValue.arrayUnion(assignees),
    },
  );
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
  required String ownerId, // pass project ownerId
}) {
  final uid = FirebaseAuth.instance.currentUser!.uid;

  return firestore
      .collection('projects')
      .doc(projectId)
      .collection('tasks')
      .orderBy('createdAt', descending: true)
      .snapshots()
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
    
    final _projectRef = firestore.collection('projects').doc(projectId);

    await firestore.runTransaction((transaction) async {
      // add assignee to task
      transaction.update(_taskRef(projectId).doc(taskId), {
        'assignees': FieldValue.arrayUnion([userId]),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // ensure user is project member
      transaction.update(_projectRef, {
        'members': FieldValue.arrayUnion([userId]),
      });
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

    final _projectRef = firestore.collection('projects').doc(projectId);

    await firestore.runTransaction((transaction) async {
      // add assignee to task
      transaction.update(_taskRef(projectId).doc(taskId), {
        'assignees': FieldValue.arrayRemove([userId]),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // ensure user is project member
      transaction.update(_projectRef, {
        'members': FieldValue.arrayRemove([userId]),
      });
    });

    return const Right('Assignee removed');
  } catch (e) {
    logger.logError('Remove Assignee Error: $e');
    return Left('Failed to remove assignee');
  }
}

}
