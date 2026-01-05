import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:fpdart/fpdart.dart';
import 'package:pm_app/models/response_models/project_model.dart';
import 'package:pm_app/models/response_models/response_model.dart';
import 'package:pm_app/models/response_models/user_model.dart';
import 'package:pm_app/repository/task_repo.dart';
import 'package:pm_app/repository/user_repo.dart';

class TaskController extends GetxController {
  final TaskRepository taskRepository;
  final UserRepository userRepository;

  TaskController({
    required this.taskRepository,
    required this.userRepository,
  });

  // ---------------- STATE ----------------
  var isLoading = false.obs;
  var isCreating = false.obs;
  var isDashboardLoading = false.obs;

  var taskList = <TaskResponseModel>[].obs;
  var todayTasks = <TaskResponseModel>[].obs;

  var errorMessage = ''.obs;
  var successMessage = ''.obs;

  var allUsers = <UserResponseModel>[].obs;
  var selectedAssignees = <String>[].obs;

  StreamSubscription<Either<String, List<TaskResponseModel>>>? _taskSub;
  StreamSubscription<Either<String, List<UserResponseModel>>>? _userSub;

  final Map<String, StreamSubscription> _todayTaskSubs = {};

  final Map<String, Rx<SyncState>> taskSyncStates = {};

  // ---------------- INIT ----------------
  @override
  void onInit() {
    super.onInit();
    subscribeUsers();
  }

  @override
  void onClose() {
    _taskSub?.cancel();
    _userSub?.cancel();
    _cancelTodayTaskSubs();
    super.onClose();
  }

  @override
  void dispose() {
    _cancelTodayTaskSubs();
    super.dispose();
  }

  void _cancelTodayTaskSubs() {
    _todayTaskSubs.forEach((_, sub) => sub.cancel());
    _todayTaskSubs.clear();
  }

  // ---------------- USERS ----------------
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

  // ---------------- TASKS ----------------
  void subscribeTasks({required String projectId, required String ownerId}) {
    isLoading.value = true;
    _taskSub?.cancel();

    _taskSub =
        taskRepository.getTasks(projectId: projectId, ownerId: ownerId).listen(
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

  // ---------------- CREATE / UPDATE / DELETE TASK ----------------
  Future<void> createTask({
    required String projectId,
    required String title,
    required String description,
    required String status,
    required String priority,
    required List<String> assignees,
    required DateTime dueDate,
  }) async {
    // isCreating.value = true;
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

    // isCreating.value = false;
    result.fold(
      (error) => errorMessage.value = error,
      (success) {
        successMessage.value = success;
      },
    );
  }

  Future<void> updateTask({
    required String projectId,
    required String taskId,
    required Map<String, dynamic> data,
  }) async {
    isCreating.value = true;
    errorMessage.value = '';
    successMessage.value = '';

    final result = await taskRepository.updateTask(
      projectId: projectId,
      taskId: taskId,
      data: data,
    );

    isCreating.value = false;

    result.fold(
      (error) {
        errorMessage.value = error;
      },
      (_) {
        // ✅ DO NOTHING to taskList
        // Firestore snapshots will update it automatically
        successMessage.value = 'Task updated';
      },
    );
  }

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
      (_) {
        successMessage.value = 'Status updated';
      },
    );
  }

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
      (_) {
        taskList.refresh();
        successMessage.value = 'Assignee added';
      },
    );
  }

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
      (_) {
        taskList.refresh();
        successMessage.value = 'Assignee removed';
      },
    );
  }

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
      (_) {
        taskList.refresh();
        successMessage.value = 'Task deleted';
      },
    );
  }

  // ---------------- TODAY TASKS ----------------
  void loadTodayTasksFromProjects(List<ProjectResponseModel> projects) {
    isDashboardLoading.value = true;

    // Cancel old listeners first
    _cancelTodayTaskSubs();

    todayTasks.clear();

    for (final project in projects) {
      final sub = FirebaseFirestore.instance
          .collection('projects')
          .doc(project.id)
          .collection('tasks')
          .snapshots()
          .listen((snapshot) {
        // Remove old tasks of this project
        todayTasks.removeWhere((t) => t.projectId == project.id);

        for (final doc in snapshot.docs) {
          final task = TaskResponseModel.fromFirestore(
            doc.id,
            doc.data(),
            metadata: doc.metadata,
          );
          if (_isToday(task.dueDate)) {
            todayTasks.add(task);
          }
        }

        // Trigger UI update
        todayTasks.refresh();
      });

      _todayTaskSubs[project.id] = sub;
    }

    isDashboardLoading.value = false;
  }

  // ---------------- DATE HELPER ----------------
  bool _isToday(DateTime? date) {
    if (date == null) return false;
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  Rx<SyncState> getSyncState(String taskId) {
    taskSyncStates.putIfAbsent(taskId, () => SyncState.pending.obs);
    return taskSyncStates[taskId]!;
  }

  void markSynced(String taskId) {
    final state = getSyncState(taskId);
    state.value = SyncState.synced;

    // Hide after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (state.value == SyncState.synced) {
        state.value = SyncState.offline;
      }
    });
  }
}
