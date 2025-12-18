import 'dart:async';

import 'package:get/get.dart';
import 'package:fpdart/fpdart.dart';
import 'package:pm_app/models/response_models/response_model.dart';
import 'package:pm_app/models/response_models/user_model.dart';
import 'package:pm_app/repository/task_repo.dart';
import 'package:pm_app/repository/user_repo.dart';

class TaskController extends GetxController {
  final TaskRepository taskRepository;
  final UserRepository userRepository; // ✅ add user repository

  TaskController({
    required this.taskRepository,
    required this.userRepository,
  });

  // ---------------- STATE ----------------
  var isLoading = false.obs;
  var isCreating = false.obs;

  var taskList = <TaskResponseModel>[].obs;
  var errorMessage = ''.obs;
  var successMessage = ''.obs;

  var allUsers = <UserResponseModel>[].obs;
  var selectedAssignees = <String>[].obs;

  StreamSubscription<Either<String, List<TaskResponseModel>>>? _taskSub;
  StreamSubscription<Either<String, List<UserResponseModel>>>? _userSub;

  // ---------------- INIT ----------------
  @override
  void onInit() {
    super.onInit();
    subscribeUsers(); // ✅ subscribe users on init
  }

  @override
  void onClose() {
    _taskSub?.cancel();
    _userSub?.cancel();
    super.onClose();
  }

  void subscribeUsers() {
    _userSub?.cancel();
    _userSub = userRepository.getUsers().listen(
      (either) {
        either.fold(
          (error) {
            allUsers.clear();
            errorMessage.value = error;
          },
          (users) {
            // List<UserResponseModel> unselectedUser = selectedAssignees.contains(element)
            allUsers.assignAll(users);
          },
        );
      },
      onError: (e) {
        allUsers.clear();
        errorMessage.value = e.toString();
      },
    );
  }

  // ---------------- SUBSCRIBE TASKS ----------------
  void subscribeTasks({required String projectId,required String ownerId}) {
    isLoading.value = true;
    _taskSub?.cancel();

    _taskSub = taskRepository.getTasks(projectId: projectId,ownerId: ownerId).listen(
      (either) {
        either.fold(
          (error) {
            errorMessage.value = error;
            isLoading.value = false;
          },
          (tasks) {
            taskList.assignAll(tasks);
            errorMessage.value = '';
            isLoading.value = false;
          },
        );
      },
      onError: (e) {
        errorMessage.value = e.toString();
        isLoading.value = false;
      },
    );
  }

  // ---------------- CREATE TASK ----------------
  Future<void> createTask({
    required String projectId,
    required String title,
    required String description,
    required String status,
    required String priority,
    required List<String> assignees,
    required DateTime dueDate,
  }) async {
    isCreating.value = true;
    errorMessage.value = '';
    successMessage.value = '';

    final result = await taskRepository.createTask(
      projectId: projectId,
      title: title,
      description: description,
      status: status,
      priority: priority,
      assignees: assignees,
      dueDate: dueDate,
    );

    result.fold(
      (error) => errorMessage.value = error,
      (success) => successMessage.value = success,
    );

    isCreating.value = false;
  }

  // ---------------- UPDATE TASK ----------------
  Future<void> updateTask({
    required String projectId,
    required String taskId,
    required Map<String, dynamic> data,
  }) async {
    final result = await taskRepository.updateTask(
      projectId: projectId,
      taskId: taskId,
      data: data,
    );

    result.fold(
      (error) => errorMessage.value = error,
      (_) => successMessage.value = 'Task updated',
    );
  }

  // ---------------- UPDATE STATUS ----------------
  Future<void> updateTaskStatus({
    required String projectId,
    required String taskId,
    required String status,
  }) async {
    final result = await taskRepository.updateTaskStatus(
      projectId: projectId,
      taskId: taskId,
      status: status,
    );

    result.fold(
      (error) => errorMessage.value = error,
      (_) => successMessage.value = 'Status updated',
    );
  }

  // ---------------- ADD ASSIGNEE ----------------
  Future<void> addAssignee({
    required String projectId,
    required String taskId,
    required String userId,
  }) async {
    final result = await taskRepository.addAssignee(
      projectId: projectId,
      taskId: taskId,
      userId: userId,
    );

    result.fold(
      (error) => errorMessage.value = error,
      (_) => successMessage.value = 'Assignee added',
    );
  }

  // ---------------- REMOVE ASSIGNEE ----------------
  Future<void> removeAssignee({
    required String projectId,
    required String taskId,
    required String userId,
  }) async {
    final result = await taskRepository.removeAssignee(
      projectId: projectId,
      taskId: taskId,
      userId: userId,
    );

    result.fold(
      (error) => errorMessage.value = error,
      (_) => successMessage.value = 'Assignee removed',
    );
  }

  // ---------------- DELETE TASK ----------------
  Future<void> deleteTask({
    required String projectId,
    required String taskId,
  }) async {
    final result = await taskRepository.deleteTask(
      projectId: projectId,
      taskId: taskId,
    );

    result.fold(
      (error) => errorMessage.value = error,
      (_) => successMessage.value = 'Task deleted',
    );
  }
}
