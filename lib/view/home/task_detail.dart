import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pm_app/controller/task_controller.dart';
import 'package:pm_app/core/component/custom_Inputdecoration.dart';
import 'package:pm_app/core/component/loading_widget.dart';
import 'package:pm_app/core/utils/snackbar.dart';
import 'package:pm_app/models/response_models/response_model.dart';

class TaskDetailScreen extends StatefulWidget {
  const TaskDetailScreen({super.key});

  @override
  State<TaskDetailScreen> createState() => _NewTaskScreenState();
}

class _NewTaskScreenState extends State<TaskDetailScreen> {
  // ---------------- COLORS ----------------
  final Color _backgroundColor = const Color(0xFF121212);
  final Color _textColor = Colors.black;
  final Color _subTextColor = Colors.grey;
  final Color _accentColor = const Color(0xFF2F80ED);
  final Color _lowPriorityColor = const Color(0xFF27AE60);
  final Color _mediumPriorityColor = const Color(0xFFF2994A);
  final Color _highPriorityColor = const Color(0xFFEB5757);

  // ---------------- CONTROLLERS ----------------
  final TaskController controller = Get.find<TaskController>();
  final titleCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  final selectedDueDate = Rx<DateTime>(DateTime.now());

  // ---------------- STATE ----------------
  String _selectedPriority = 'Medium';
  late final String projectId;
  late final String taskId;
  late final String ownerId;
  TaskResponseModel? editingTask;

  bool get isEdit => editingTask != null;

  final FocusNode titleFocus = FocusNode();
  final FocusNode descFocus = FocusNode();

  // ---------------- INIT ----------------
  @override
  void initState() {
    super.initState();

    projectId = Get.arguments['projectId'];
    ownerId = Get.arguments['ownerId'];
    taskId = Get.arguments['taskId'];
    // editingTask = Get.arguments['task'];

    controller.getTaskById(
        projectId: projectId, ownerId: ownerId, taskId: taskId);
  }

  @override
  void dispose() {
    titleCtrl.dispose();
    descCtrl.dispose();
    titleFocus.dispose();
    descFocus.dispose();
    super.dispose();
  }

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: _closeKeyboard,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            'Task Detail',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: Obx(() {
           final data = controller.getTaskInformation.value;
          titleCtrl.text = data!.title;
          descCtrl.text = data.description;
          _selectedPriority = data.priority.displayName;
          selectedDueDate.value = data.dueDate!;
          controller.selectedAssignees.assignAll(data.assignees);
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),

                        // -------- TITLE --------
                        buildLabel('Title'),
                        const SizedBox(height: 8),
                        TextField(
                          controller: titleCtrl,
                          style: TextStyle(
                            color: _textColor,
                            fontSize: 24,
                            fontWeight: FontWeight.w500,
                          ),
                          decoration: buildInputDecoration(
                            hintText: 'Enter Task Title',
                            isPrefix: false,
                          ),
                          focusNode: titleFocus,
                          autofocus: false,
                          readOnly: true,
                        ),

                        const SizedBox(height: 30),

                        // -------- DESCRIPTION --------
                        buildLabel('Description'),
                        const SizedBox(height: 10),
                        Container(
                          height: 150,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: TextField(
                            controller: descCtrl,
                            maxLines: null,
                            expands: true,
                            textAlignVertical: TextAlignVertical.top,
                            decoration: buildInputDecoration(
                              hintText: 'Add details...',
                              isPrefix: false,
                            ),
                            focusNode: descFocus,
                            autofocus: false,
                            readOnly: true,
                          ),
                        ),

                        const SizedBox(height: 30),

                        // -------- PRIORITY --------
                        _buildSectionLabel('PRIORITY'),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            _buildPriorityButton('Low', _lowPriorityColor),
                            const SizedBox(width: 12),
                            _buildPriorityButton(
                                'Medium', _mediumPriorityColor),
                            const SizedBox(width: 12),
                            _buildPriorityButton('High', _highPriorityColor),
                          ],
                        ),

                        const SizedBox(height: 30),

                        // -------- ASSIGNEES --------
                        _buildListItem(
                          icon: Icons.people_outline,
                          title: 'Assignees',
                          subtitle: 'Who is working on this?',
                          trailing: _buildAssigneesTrailing(),
                        ),

                        const SizedBox(height: 16),

                        // -------- DUE DATE --------
                        _buildListItem(
                          icon: Icons.calendar_today_outlined,
                          title: 'Due Date',
                          subtitle: 'Set a deadline',
                          trailing: _buildDueDateTrailing(),
                        ),

                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),

                // -------- ACTION BUTTON --------
                // SizedBox(
                //   width: double.infinity,
                //   height: 56,
                //   child: ElevatedButton(
                //     style: ElevatedButton.styleFrom(
                //       backgroundColor: _accentColor,
                //       shape: RoundedRectangleBorder(
                //         borderRadius: BorderRadius.circular(12),
                //       ),
                //     ),
                //     onPressed: controller.isCreating.value
                //         ? null
                //         : () async {
                //             Get.back();
                //             if (isEdit) {
                //               _closeKeyboard();
                //               // 🔁 UPDATE
                //               await controller.updateTask(
                //                 projectId: projectId,
                //                 taskId: editingTask!.id,
                //                 data: {
                //                   'title': titleCtrl.text,
                //                   'description': descCtrl.text,
                //                   'priority': _selectedPriority,
                //                   'assignees':
                //                       controller.selectedAssignees.toList(),
                //                   'dueDate': selectedDueDate.value,
                //                 },
                //               );

                //               if (controller.successMessage.isNotEmpty) {
                //                 showMaterialSnackBar(
                //                     context, controller.successMessage.value);
                //               } else if (controller.errorMessage.isNotEmpty) {
                //                 showMaterialSnackBar(
                //                     context, controller.errorMessage.value);
                //               }

                //               //  controller.selectedAssignees.clear();
                //               //  Get.back();
                //             } else {
                //               _closeKeyboard();
                //               // ➕ CREATE
                //               await controller.createTask(
                //                 projectId: projectId,
                //                 title: titleCtrl.text,
                //                 description: descCtrl.text,
                //                 status: 'todo',
                //                 priority: _selectedPriority,
                //                 assignees: controller.selectedAssignees.toList(),
                //                 dueDate: selectedDueDate.value,
                //               );

                //               if (controller.successMessage.isNotEmpty) {
                //                 showMaterialSnackBar(
                //                     context, controller.successMessage.value);
                //               } else if (controller.errorMessage.isNotEmpty) {
                //                 showMaterialSnackBar(
                //                     context, controller.errorMessage.value);
                //               }
                //             }

                //             controller.selectedAssignees.clear();
                //           },
                //     child: controller.isCreating.value
                //         ? LoadingWidget()
                //         : Text(
                //             isEdit ? 'Update Task' : 'Create Task',
                //             style: const TextStyle(
                //               fontSize: 18,
                //               fontWeight: FontWeight.bold,
                //               color: Colors.white,
                //             ),
                //           ),
                //   ),
                // ),

                const SizedBox(height: 20),
              ],
            ),
          );
        }),
      ),
    );
  }

  // ---------------- HELPERS ----------------

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: TextStyle(
        color: _subTextColor,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildPriorityButton(String label, Color color) {
    final isSelected = _selectedPriority == label;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          // _closeKeyboard();
          // setState(() => _selectedPriority = label);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? _accentColor : Colors.grey,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              CircleAvatar(radius: 5, backgroundColor: color),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(subtitle,
                    style: TextStyle(color: _subTextColor, fontSize: 13)),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }

  Widget _buildAssigneesTrailing() {
    return Obx(() {
      return Row(
        children: [
          ...controller.selectedAssignees.map((id) {
            return Padding(
              padding: const EdgeInsets.only(right: 6),
              child: Stack(
                alignment: Alignment.topRight,
                children: [
                  const CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.blueGrey,
                    child: Icon(Icons.person, size: 18, color: Colors.white),
                  ),
                  GestureDetector(
                    onTap: () => controller.selectedAssignees.remove(id),
                    child: const CircleAvatar(
                      radius: 8,
                      backgroundColor: Colors.red,
                      child: Icon(Icons.close, size: 10, color: Colors.white),
                    ),
                  ),
                ],
              ),
            );
          }),
          // GestureDetector(
          //   onTap: _showAddAssigneeDialog,
          //   child: const CircleAvatar(
          //     radius: 16,
          //     backgroundColor: Colors.blue,
          //     child: Icon(Icons.add),
          //   ),
          // ),
        ],
      );
    });
  }

  Widget _buildDueDateTrailing() {
    return GestureDetector(
      onTap: () async {
        // _closeKeyboard();

        // final picked = await showDatePicker(
        //   context: context,
        //   initialDate: selectedDueDate.value,
        //   firstDate: DateTime.now(),
        //   lastDate: DateTime(2100),
        // );
        // if (picked != null) selectedDueDate.value = picked;
      },
      child: Obx(() => Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.all(Radius.circular(10))),
            child: Text(
              '${selectedDueDate.value.day}/${selectedDueDate.value.month}/${selectedDueDate.value.year}',
              style: const TextStyle(
                  fontWeight: FontWeight.w500, color: Colors.white),
            ),
          )),
    );
  }

  void _showAddAssigneeDialog() {
    _closeKeyboard();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Select Assignees'),
        content: Obx(() {
          return SizedBox(
            width: double.maxFinite,
            height: 500,
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
              onPressed: () {
                FocusScope.of(context).unfocus(); // 🔥 CLOSE KEYBOARD
                Navigator.of(context).pop();
              },
              child: const Text('Done')),
        ],
      ),
    );
  }

  void _closeKeyboard() {
    titleFocus.unfocus();
    descFocus.unfocus();
    FocusManager.instance.primaryFocus?.unfocus();
  }
}
