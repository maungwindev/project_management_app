import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pm_app/controller/task_controller.dart';
import 'package:pm_app/models/response_models/response_model.dart';
import 'package:pm_app/view/home/project_card.dart';
import 'package:pm_app/view/home/task_card.dart';

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

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: AppBar(title: const Text('Tasks')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.toNamed('/create-task', arguments: {
            'projectId': projectId,
          });
        },
        child: const Icon(Icons.add),
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

        return isMobile
            ? ListView.builder(
                padding: const EdgeInsets.all(10),
                itemCount: controller.taskList.length,
                itemBuilder: (_, index) {
                  final task = controller.taskList[index];
                  return TaskCard(
                        priority: "HIGH PRIORITY",
                        priorityBg: Color(0xFF451A1A),
                        priorityText: Color(0xFFF87171),
                        title: task.title,
                        description: task.description,
                        status: task.status.value.toUpperCase(),
                        statusColor: Colors.blue,
                        avatarCount: task.assignees.length,
                        taskModel: task,
                  );
                },
              )
            : _desktopTable();
      }),
    );
  }

  // ================= MOBILE CARD =================

  Widget _taskCard(TaskResponseModel task) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20,vertical: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white, // Card color
         borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TITLE + STATUS
            Row(
              children: [
                Expanded(
                  child: Text(
                    task.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                _statusBadge(task),
              ],
            ),

            const SizedBox(height: 6),

            // DESCRIPTION
            Text(
              task.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
              ),
            ),

            const SizedBox(height: 12),

            // META
            Row(
              children: [
                _infoChip(
                  label: task.priority.name.toUpperCase(),
                  bg: Colors.red.shade50,
                  textColor: Colors.red,
                ),
                const SizedBox(width: 8),
                _infoChip(
                  label: 'Due ${task.dueDate}',
                  bg: Colors.blue.shade50,
                  textColor: Colors.blue,
                ),
              ],
            ),

            const SizedBox(height: 12),

            // ASSIGNEES
            assigneeRow(task),

            const SizedBox(height: 8),

            // ACTIONS
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, size: 20),
                  onPressed: () => _showEditTaskDialog(context, task),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, size: 20, color: Colors.red),
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

  // ================= INFO CHIP =================

  Widget _infoChip({
    required String label,
    required Color bg,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  // ================= ASSIGNEES =================

  Widget assigneeRow(TaskResponseModel task) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          ...task.assignees.map((userId) => Padding(
                padding: const EdgeInsets.only(right: 6),
                child: Stack(
                  alignment: Alignment.topRight,
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.blueGrey,
                      child: const Icon(Icons.person,
                          size: 16, color: Colors.white),
                    ),
                    GestureDetector(
                      onTap: () {
                        controller.removeAssignee(
                          projectId: projectId,
                          taskId: task.id,
                          userId: userId,
                        );
                      },
                      child: const CircleAvatar(
                        radius: 7,
                        backgroundColor: Colors.red,
                        child: Icon(Icons.close,
                            size: 9, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              )),
          GestureDetector(
            onTap: () => _showAddAssigneeDialog(context, task.id),
            child: const CircleAvatar(
              radius: 16,
              backgroundColor: Colors.blue,
              child: Icon(Icons.add, color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  // ================= DESKTOP TABLE (UNCHANGED) =================

  Widget _desktopTable() {
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
        rows: controller.taskList.map((task) {
          return DataRow(cells: [
            DataCell(Text(task.title)),
            DataCell(Text(task.description)),
            DataCell(Text(task.priority.name)),
            DataCell(assigneeRow(task)),
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

  // ================= ADD ASSIGNEE =================

  void _showAddAssigneeDialog(BuildContext context, String taskId) {
    controller.selectedAssignees.clear();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Select Assignees'),
        content: Obx(() {
          return ListView(
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
          );
        }),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
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
