import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pm_app/controller/task_controller.dart';
import 'package:pm_app/models/response_models/response_model.dart';

class TaskScreen extends StatefulWidget {
  const TaskScreen({super.key});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  final TaskController controller = Get.find<TaskController>();
  late final String projectId;
  late final String ownerId;

  @override
  void initState() {
    super.initState();
    projectId = Get.arguments['projectId'];
    ownerId = Get.arguments['ownerId'];
    controller.subscribeTasks(projectId: projectId,ownerId: ownerId);
    controller.subscribeUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showCreateTaskDialog(context),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage.isNotEmpty) {
          return Center(child: Text(controller.errorMessage.value));
        }

        if (controller.taskList.isEmpty) {
          return const Center(child: Text('No tasks found'));
        }

        return ListView.builder(
          itemCount: controller.taskList.length,
          itemBuilder: (_, index) {
            final task = controller.taskList[index];
            return _taskCard(task);
          },
        );
      }),
    );
  }

  Widget _taskCard(TaskResponseModel task) {
    return Card(
      margin: const EdgeInsets.all(10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(task.title,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(task.description),
            const SizedBox(height: 10),

            // -------- STATUS DROPDOWN --------
            DropdownButton<TaskStatus>(
              value: task.status,
              items: const [
                DropdownMenuItem(
                  value: TaskStatus.todo,
                  child: Text('Todo'),
                ),
                DropdownMenuItem(
                  value: TaskStatus.inProgress,
                  child: Text('In Progress'),
                ),
                DropdownMenuItem(
                  value: TaskStatus.done,
                  child: Text('Done'),
                ),
              ],
              onChanged: (value) {
                if (value == null) return;
                controller.updateTaskStatus(
                  projectId: projectId,
                  taskId: task.id,
                  status: _statusToFirestore(value),
                );
              },
            ),

            const SizedBox(height: 6),

            // -------- ASSIGNEES (No Obx here) --------
            Wrap(
              spacing: 6,
              children: task.assignees.map((userId) {
                return Chip(
                  label: Text(userId),
                  deleteIcon: const Icon(Icons.close),
                  onDeleted: () {
                    controller.removeAssignee(
                      projectId: projectId,
                      taskId: task.id,
                      userId: userId,
                    );
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 10),

            // -------- ACTIONS --------
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.person_add),
                  onPressed: () => _showAddAssigneeDialog(context, task.id,initialAssignees: task.assignees,),
                ),
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
            ),
          ],
        ),
      ),
    );
  }

  String _statusToFirestore(TaskStatus status) {
    switch (status) {
      case TaskStatus.inProgress:
        return 'in_progress';
      case TaskStatus.done:
        return 'done';
      case TaskStatus.todo:
      default:
        return 'todo';
    }
  }

  void _showCreateTaskDialog(BuildContext context) {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Create Task'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(labelText: 'Title')),
            TextField(
                controller: descCtrl,
                decoration: const InputDecoration(labelText: 'Description')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          Obx(() => ElevatedButton(
                onPressed: controller.isCreating.value
                    ? null
                    : () async {
                        await controller.createTask(
                          projectId: projectId,
                          title: titleCtrl.text,
                          description: descCtrl.text,
                          status: 'Todo',
                          priority: 'Medium',
                          assignees: [],
                          dueDate: DateTime.now().add(const Duration(days: 7)),
                        );
                        Get.back();
                      },
                child: controller.isCreating.value
                    ? const CircularProgressIndicator()
                    : const Text('Create'),
              )),
        ],
      ),
    );
  }

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

  void _showAddAssigneeDialog(
    BuildContext context,
    String taskId, {
    List<String> initialAssignees = const [],
  }) {
    // ✅ reset and initialize properly
    controller.selectedAssignees
      ..clear()
      ..addAll(initialAssignees);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Select Assignees'),
        content: Obx(() {
          if (controller.allUsers.isEmpty) {
            return const Center(child: Text('No users found'));
          }

          return SizedBox(
            width: double.maxFinite,
            child: ListView(
              shrinkWrap: true,
              children: controller.allUsers.map((user) {
                final isSelected =
                    controller.selectedAssignees.contains(user.id);

                return CheckboxListTile(
                  value: isSelected,
                  title: Text(user.name),
                  onChanged: (val) {
                    if (val == true) {
                      controller.selectedAssignees.add(user.id);
                    } else {
                      controller.selectedAssignees.remove(user.id);
                    }
                  },
                );
              }).toList(),
            ),
          );
        }),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              for (final userId in controller.selectedAssignees) {
                await controller.addAssignee(
                  projectId: projectId,
                  taskId: taskId,
                  userId: userId,
                );
              }
              Get.back();
            },
            child: const Text('Assign'),
          ),
        ],
      ),
    );
  }
}
