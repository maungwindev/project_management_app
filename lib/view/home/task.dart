import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pm_app/controller/connection_controller.dart';
import 'package:pm_app/controller/task_controller.dart';
import 'package:pm_app/controller/task_ui_controller.dart';
import 'package:pm_app/controller/user_controller.dart';
import 'package:pm_app/models/response_models/response_model.dart';
import 'package:pm_app/view/home/task_card.dart';
import 'package:responsive_builder/responsive_builder.dart';

class TaskScreen extends StatefulWidget {
  const TaskScreen({super.key});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  final TaskController controller = Get.find<TaskController>();
  final UserController userController = Get.find<UserController>();
  final InternetConnectionController internetController = Get.find();
  late final String projectId;
  late final String ownerId;

  final RxString selectedFilter = 'All'.obs; // <-- Filter state

  Map<TaskPriority, Color> priorityBgColors = {
    TaskPriority.low: const Color(0xFFDFF7DF),
    TaskPriority.medium: const Color(0xFFFFF4E5),
    TaskPriority.high: const Color(0xFFFDE2E2),
  };

  Map<TaskPriority, Color> priorityTextColors = {
    TaskPriority.low: const Color(0xFF27AE60),
    TaskPriority.medium: const Color(0xFFF2994A),
    TaskPriority.high: const Color(0xFFEB5757),
  };

  

  @override
  void initState() {
    super.initState();
    projectId = Get.arguments['projectId'];
    ownerId = Get.arguments['ownerId'];
    controller.subscribeTasks(projectId: projectId, ownerId: ownerId);
    controller.subscribeUsers();
  }

  Color _statusColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.todo:
        return const Color(0xFF3B82F6);
      case TaskStatus.inProgress:
        return const Color(0xFFFACC15);
      case TaskStatus.done:
        return const Color(0xFF10B981);
      default:
        return Colors.grey;
    }
  }

  Color getPriorityBg(TaskPriority priority) {
    return priorityBgColors[priority] ?? Colors.grey.shade200;
  }

  Color getPriorityTextColor(TaskPriority priority) {
    return priorityTextColors[priority] ?? Colors.black;
  }

  @override
  Widget build(BuildContext context) {
    return ScreenTypeLayout.builder(
      mobile: (context) => _mobileView(),
      desktop: (context) => _desktopView(),
    );
  }

  // ================= MOBILE VIEW =================
  Widget _mobileView() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        actions: [
          Obx(() {
            switch (internetController.status.value) {
              case InternetStatus.disconnected:
                return Padding(
                  padding: const EdgeInsets.only(right: 30),
                  child: Icon(Icons.wifi_off_outlined),
                );
              case InternetStatus.connected:
                return SizedBox.shrink();

              case InternetStatus.initial:
                // TODO: Handle this case.
                return SizedBox.shrink();
              case InternetStatus.loading:
                // TODO: Handle this case.
                return SizedBox.shrink();
            }
          }),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.toNamed('/create-task', arguments: {
            'projectId': projectId,
            'task': null,
          });
        },
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // ---------------- FILTER TABS ----------------
              Obx(() {
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children:
                        ['All', 'To Do', 'In Progress', 'Done'].map((label) {
                      final isActive = selectedFilter.value == label;
                      return GestureDetector(
                        onTap: () => selectedFilter.value = label,
                        child: Container(
                          margin: const EdgeInsets.only(right: 12),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            color: isActive ? Colors.blue : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: isActive
                                ? Border.all(color: Colors.transparent)
                                : Border.all(color: Colors.blue.shade200),
                          ),
                          child: Text(
                            label,
                            style: TextStyle(
                              color: isActive ? Colors.white : Colors.black,
                              fontWeight: isActive
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                );
              }),
              const SizedBox(height: 15),

              // ---------------- TASK LIST ----------------
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (controller.errorMessage.isNotEmpty) {
                    return Center(child: Text(controller.errorMessage.value));
                  }

                  final filteredTasks = controller.taskList.where((task) {
                    switch (selectedFilter.value) {
                      case 'All':
                        return true;
                      case 'To Do':
                        return task.status == TaskStatus.todo;
                      case 'In Progress':
                        return task.status == TaskStatus.inProgress;
                      case 'Done':
                        return task.status == TaskStatus.done;
                      default:
                        return true;
                    }
                  }).toList();

                  if (filteredTasks.isEmpty) {
                    return const Center(child: Text('No tasks found'));
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(10),
                    itemCount: filteredTasks.length,
                    itemBuilder: (_, index) {
                      final task = filteredTasks[index];
                      return TaskCard(
                        currentUserId: userController.currentUserInfo.value!.id,
                        ownerId: ownerId,
                        projectId: projectId,
                        priority: task.priority.displayName,
                        priorityBg: getPriorityBg(task.priority),
                        priorityText: getPriorityTextColor(task.priority),
                        title: task.title,
                        description: task.description,
                        status: task.status.name.toUpperCase(),
                        statusColor: Colors.blue,
                        avatarCount: task.assignees.length,
                        taskModel: task,
                        // syncData: task.syncState,
                        onEdit: () {
                          Get.toNamed('/create-task', arguments: {
                            'projectId': projectId,
                            'task': task
                          });
                        },
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= DESKTOP VIEW =================
  Widget _desktopView() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // ---------------- FILTER TABS ----------------
          Obx(() {
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['All', 'To Do', 'In Progress', 'Done'].map((label) {
                  final isActive = selectedFilter.value == label;
                  return GestureDetector(
                    onTap: () => selectedFilter.value = label,
                    child: Container(
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: isActive ? Colors.blue : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: isActive
                            ? Border.all(color: Colors.transparent)
                            : Border.all(color: Colors.blue.shade200),
                      ),
                      child: Text(
                        label,
                        style: TextStyle(
                          color: isActive ? Colors.white : Colors.black,
                          fontWeight:
                              isActive ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            );
          }),
          const SizedBox(height: 20),

          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.errorMessage.isNotEmpty) {
                return Center(child: Text(controller.errorMessage.value));
              }

              final filteredTasks = controller.taskList.where((task) {
                switch (selectedFilter.value) {
                  case 'All':
                    return true;
                  case 'To Do':
                    return task.status == TaskStatus.todo;
                  case 'In Progress':
                    return task.status == TaskStatus.inProgress;
                  case 'Done':
                    return task.status == TaskStatus.done;
                  default:
                    return true;
                }
              }).toList();

              if (filteredTasks.isEmpty) {
                return const Center(child: Text('No tasks found'));
              }

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Task Name')),
                    DataColumn(label: Text('Description')),
                    DataColumn(label: Text('Priority')),
                    DataColumn(label: Text('Assignees')),
                    DataColumn(label: Text('Due Date')),
                    DataColumn(label: Text('Status')),
                    DataColumn(label: Text('Actions')),
                  ],
                  rows: filteredTasks.map((task) {
                    return DataRow(cells: [
                      DataCell(Text(task.title)),
                      DataCell(Text(task.description)),
                      DataCell(Text(task.priority.name)),
                      DataCell(_assigneeRow(task)),
                      DataCell(Text('${task.dueDate}')),
                      DataCell(_statusBadge(task)),
                      DataCell(Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _showEditTaskDialog(context, task),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              controller.deleteTask(
                                projectId: projectId,
                                taskId: task.id,
                              );
                            },
                          ),
                        ],
                      )),
                    ]);
                  }).toList(),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // ================= STATUS BADGE =================
  Widget _statusBadge(TaskResponseModel task) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _statusColor(task.status).withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        task.status.name.toUpperCase(),
        style: TextStyle(
          color: _statusColor(task.status),
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // ================= ASSIGNEES =================
  Widget _assigneeRow(TaskResponseModel task) {
    return Row(
      children: task.assignees
          .map((e) => Padding(
                padding: const EdgeInsets.only(right: 6),
                child: CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.blueGrey,
                  child:
                      const Icon(Icons.person, size: 16, color: Colors.white),
                ),
              ))
          .toList(),
    );
  }

  // ================= EDIT TASK =================
  void _showEditTaskDialog(BuildContext context, TaskResponseModel task) {
    final titleCtrl = TextEditingController(text: task.title);
    final descCtrl = TextEditingController(text: task.description);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit Task'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleCtrl),
            TextField(controller: descCtrl),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              await controller.updateTask(
                projectId: projectId,
                taskId: task.id,
                data: {
                  'title': titleCtrl.text,
                  'description': descCtrl.text,
                },
              );
              Get.back();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
