import 'package:fpdart/fpdart.dart';
import 'package:pm_app/core/utils/custom_logger.dart';
import 'package:pm_app/models/response_models/response_model.dart';
import 'package:pm_app/service/task_service.dart';

class TaskRepository {
  final TaskService taskService;
  final CustomLogger logger;

  TaskRepository({
    required this.taskService,
    required this.logger,
  });

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
    final result = await taskService.createTask(
      projectId: projectId,
      title: title,
      description: description,
      status: status,
      priority: priority,
      assignees: assignees,
      dueDate: dueDate,
    );

    return result.fold(
      (error) => Left(error),
      (success) => Right(success),
    );
  }

  // ---------------- READ TASKS (STREAM) ----------------
  Stream<Either<String, List<TaskResponseModel>>> getTasks({
    required String projectId,
  }) {
    return taskService.getTasks(projectId: projectId);
  }

  // ---------------- UPDATE TASK ----------------
  Future<Either<String, String>> updateTask({
    required String projectId,
    required String taskId,
    required Map<String, dynamic> data,
  }) async {
    final result = await taskService.updateTask(
      projectId: projectId,
      taskId: taskId,
      data: data,
    );

    return result.fold(
      (error) => Left(error),
      (success) => Right(success),
    );
  }

  // ---------------- UPDATE TASK STATUS ----------------
  Future<Either<String, String>> updateTaskStatus({
    required String projectId,
    required String taskId,
    required String status,
  }) async {
    final result = await taskService.updateTaskStatus(
      projectId: projectId,
      taskId: taskId,
      status: status,
    );

    return result.fold(
      (error) => Left(error),
      (success) => Right(success),
    );
  }

  // ---------------- ADD ASSIGNEE ----------------
  Future<Either<String, String>> addAssignee({
    required String projectId,
    required String taskId,
    required String userId,
  }) async {
    final result = await taskService.addAssignee(
      projectId: projectId,
      taskId: taskId,
      userId: userId,
    );

    return result.fold(
      (error) => Left(error),
      (success) => Right(success),
    );
  }

  // ---------------- REMOVE ASSIGNEE ----------------
  Future<Either<String, String>> removeAssignee({
    required String projectId,
    required String taskId,
    required String userId,
  }) async {
    final result = await taskService.removeAssignee(
      projectId: projectId,
      taskId: taskId,
      userId: userId,
    );

    return result.fold(
      (error) => Left(error),
      (success) => Right(success),
    );
  }

  // ---------------- DELETE TASK ----------------
  Future<Either<String, String>> deleteTask({
    required String projectId,
    required String taskId,
  }) async {
    final result = await taskService.deleteTask(
      projectId: projectId,
      taskId: taskId,
    );

    return result.fold(
      (error) => Left(error),
      (success) => Right(success),
    );
  }
}
