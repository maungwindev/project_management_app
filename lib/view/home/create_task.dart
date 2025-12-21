import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pm_app/controller/task_controller.dart';
import 'package:pm_app/core/component/custom_Inputdecoration.dart';
import 'package:pm_app/models/response_models/response_model.dart';

class NewTaskScreen extends StatefulWidget {
  const NewTaskScreen({super.key});

  @override
  State<NewTaskScreen> createState() => _NewTaskScreenState();
}

class _NewTaskScreenState extends State<NewTaskScreen> {
  // Define colors based on the image
  final Color _backgroundColor = const Color(0xFF121212); // Dark background
  final Color _cardColor = const Color(0xFF1E2731); // Slightly lighter for cards
  final Color _textColor = Colors.black;
  final Color _subTextColor = Colors.grey;
  final Color _accentColor = const Color(0xFF2F80ED); // Blue
  final Color _lowPriorityColor = const Color(0xFF27AE60); // Green
  final Color _mediumPriorityColor = const Color(0xFFF2994A); // Orange
  final Color _highPriorityColor = const Color(0xFFEB5757); // Red
  final selectedDueDate = Rx<DateTime>(DateTime.now());
   final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();


  String _selectedPriority = 'Medium';
    final TaskController controller = Get.find<TaskController>();
    late final String projectId;

  @override
  void initState() {
    super.initState();
    controller.selectedAssignees.clear();
    controller.subscribeUsers();
    projectId = Get.arguments['projectId'];
  }


 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: _backgroundColor,
      appBar: AppBar(
        // backgroundColor: _backgroundColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'New Task',
          style: TextStyle( fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                     buildLabel('Title'),
                     SizedBox(height: 8,),
                    // Task Title Input
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
                    ),
                    const SizedBox(height: 30),

                    // Description Section
                    buildLabel('Description'),
                    const SizedBox(height: 10),
                    Container(
                      height: 150,
                      decoration: BoxDecoration(
                        color: _cardColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Stack(
                        children: [
                          TextField(
                            controller: descCtrl,
                            maxLines: null,
                            expands: true,
                            textAlignVertical: TextAlignVertical.top,
                            style: TextStyle(color: _textColor),
                            decoration: buildInputDecoration(hintText:'Add details, links, or context...',isPrefix: false)),
                          Positioned(
                            bottom: 12,
                            right: 12,
                            child: Transform.rotate(
                                angle: -3.14 / 4,
                                child:
                                Icon(Icons.attach_file, color: _subTextColor)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Priority Section
                    _buildSectionLabel('PRIORITY'),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _buildPriorityButton('Low', _lowPriorityColor),
                        const SizedBox(width: 12),
                        _buildPriorityButton('Medium', _mediumPriorityColor),
                        const SizedBox(width: 12),
                        _buildPriorityButton('High', _highPriorityColor),
                      ],
                    ),
                    const SizedBox(height: 30),

                    // Assignees Section
                    _buildListItem(
                      icon: Icons.people_alt_outlined,
                      title: 'Assignees',
                      subtitle: 'Who is working on this?',
                      trailing: _buildAssigneesTrailing(),
                    ),
                    const SizedBox(height: 16),

                    // Due Date Section
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
            // Create Task Button
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0, top: 10),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: 
                    // Handle create task action
                    controller.isCreating.value
                    ? null
                    : () async {
                      print("is checking");
                        await controller.createTask(
                             projectId: projectId,
                            title: titleCtrl.text,
                            description: descCtrl.text,
                            status: 'todo',
                            priority: _selectedPriority,
                            assignees: controller.selectedAssignees.toList(), // ✅ IMPORTANT
                            dueDate: selectedDueDate.value,
                      );

                        controller.selectedAssignees.clear();
                        Get.back();
                      },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _accentColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Create Task',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      // const SizedBox(width: 8),
                      // const Icon(Icons.arrow_forward, color: Colors.white),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget for section labels
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

  // Helper widget for priority buttons
  Widget _buildPriorityButton(String label, Color color) {
    final isSelected = _selectedPriority == label;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedPriority = label;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: isSelected
                ? Border.all(color: _accentColor, width: 2)
                : Border.all(color: Colors.grey,width: 1),
          ),
          child: Column(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  // color: _textColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget for list items (Assignees, Due Date)
  Widget _buildListItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        // color: _cardColor,
        border: Border.all(color: Colors.grey,width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              // color: _accentColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: _accentColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(color: _subTextColor, fontSize: 14),
                ),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }

  // Trailing widget for Assignees
 Widget _buildAssigneesTrailing() {
  return Obx(() {
    return Row(
      children: [
        // Selected assignees
        ...controller.selectedAssignees.map((userId) {
          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: Stack(
              alignment: Alignment.topRight,
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.blueGrey,
                  child: const Icon(Icons.person,
                      size: 18, color: Colors.white),
                ),
                GestureDetector(
                  onTap: () {
                    controller.selectedAssignees.remove(userId); // ❌ remove
                  },
                  child: const CircleAvatar(
                    radius: 8,
                    backgroundColor: Colors.red,
                    child: Icon(Icons.close,
                        size: 10, color: Colors.white),
                  ),
                ),
              ],
            ),
          );
        }),

        // Add button
        GestureDetector(
          onTap: _showAddAssigneeDialog,
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey),
            ),
            child: const Icon(Icons.add, size: 20),
          ),
        ),
      ],
    );
  });
}


  

  // Trailing widget for Due Date
  Widget _buildDueDateTrailing() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: _backgroundColor, // Darker background for the chip
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Obx((){
            return Text(
            '${selectedDueDate.value.day}/${selectedDueDate.value.month}/${selectedDueDate.value.year}',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
          );
          }),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () async{
              final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDueDate.value,
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) selectedDueDate.value = picked;
            },
            child: Icon(Icons.edit_calendar_outlined, color: _subTextColor, size: 16),
            ),
        ],
      ),
    );
  }

// calling for assignee user
  void _showAddAssigneeDialog() {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Select Assignees'),
      content: Obx(() {
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
          child: const Text('Done'),
        ),
      ],
    ),
  );
}

void _showEditAssigneeDialog(TaskResponseModel task) {
  controller.selectedAssignees.assignAll(task.assignees); // ✅ preload

  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Edit Assignees'),
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
        TextButton(
          onPressed: () => Get.back(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            await controller.updateTask(
              projectId: projectId,
              taskId: task.id,
              data: {
                'assignees': controller.selectedAssignees.toList(),
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