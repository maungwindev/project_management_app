import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pm_app/controller/task_controller.dart';
import 'package:pm_app/models/response_models/response_model.dart';

class TaskCard extends StatelessWidget {
  final String priority;
  final Color priorityBg;
  final Color priorityText;
  final String title;
  final String description;
  final String status;
  final Color statusColor;
  final int avatarCount;
  final String? extraAvatars;
  final bool isDone;
  final bool useInitials;
  final TaskResponseModel taskModel;
  final String projectId;
  final Function onEdit;
  final String currentUserId;
  final String ownerId;

   TaskCard({
    super.key,
    required this.projectId,
    required this.taskModel,
    required this.priority,
    required this.priorityBg,
    required this.priorityText,
    required this.title,
    required this.description,
    required this.status,
    required this.statusColor,
    required this.avatarCount,
    this.extraAvatars,
    this.isDone = false,
    this.useInitials = false,
    required this.onEdit,
    required this.currentUserId,
    required this.ownerId
  });

  final controller = Get.find<TaskController>();

  Color _statusColor(TaskStatus status) {
  switch (status) {
    case TaskStatus.todo: // "To Do"
      return const Color(0xFF64748B); // Slate Grey
    case TaskStatus.inProgress:    // "In Progress"
      return const Color(0xFF3B82F6); // Bright Blue
    case TaskStatus.done:
      return const Color(0xFF10B981); // Emerald Green
    default:
      return Colors.black;
  }
}


  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white, // Card color
         borderRadius: BorderRadius.circular(16),
        border: Border.all(color: priorityText),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Priority and Options
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: priorityBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  priority,
                  style: TextStyle(
                    color: priorityText,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // const Icon(Icons.more_horiz, color: Colors.grey),
              if(currentUserId == ownerId)
                PopupMenuButton<int>(
                offset: const Offset(0, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                itemBuilder: (context) => [
                  // const PopupMenuDivider(),
                  PopupMenuItem(
                    onTap: () {
                      onEdit();
                      // Handle logout
                      //authController.clearUser();
                    //  Get.offAllNamed('/login');
                    },
                    child: Row(
                      children: const [
                        Icon(Icons.edit, size: 18, color: Colors.black),
                        SizedBox(width: 8),
                        Text("Edit"),
                      ],
                    ),
                  ),
                  PopupMenuDivider(),
                  PopupMenuItem(
                    onTap: () {
                      controller.deleteTask(
                        projectId: projectId,
                        taskId: taskModel.id,
                      );
                      // Handle logout
                      //authController.clearUser();
                    //  Get.offAllNamed('/login');
                    },
                    child: Row(
                      children: const [
                        Icon(Icons.delete_forever, size: 18, color: Colors.black),
                        SizedBox(width: 8),
                        Text("Delete"),
                      ],
                    ),
                  ),
                ],
                child:Icon(Icons.more_horiz, color: Colors.grey) ,
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Title
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              // color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          // Description
          Text(
            description,
            style: TextStyle(
              fontSize: 14,
              // color: Colors.white.withOpacity(0.6),
              height: 1.5,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 20),
          const Divider(color: Colors.white10),
          const SizedBox(height: 15),
          // Bottom Row: Avatars and Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildAvatarStack(),
              Row(
                children: [
                  // isDone
                  //     ? Icon(Icons.check_circle, color: statusColor, size: 16)
                  //     : Container(
                  //         width: 8,
                  //         height: 8,
                  //         decoration: BoxDecoration(
                  //           color: statusColor,
                  //           shape: BoxShape.circle,
                  //         ),
                  //       ),
                  // const SizedBox(width: 8),
                  // Text(
                  //   status,
                  //   style: const TextStyle(color: Colors.white, fontSize: 13),
                  // ),

                  Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  // Using .withOpacity() to get that soft pastel look from the image
                                  color: _statusColor(taskModel.status)
                                      .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(
                                      8), // More rectangular like the image
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<TaskStatus>(
                                    focusColor: Colors.transparent,
                                    value: taskModel.status,
                                    // Re-enable and style the icon
                                    icon: Icon(
                                      Icons.keyboard_arrow_down,
                                      color: _statusColor(taskModel.status),
                                      size: 18,
                                    ),
                                    isDense: true, // Makes the button compact
                                    dropdownColor: Colors.white,
                                    items: TaskStatus.values.map((status) {
                                      return DropdownMenuItem<TaskStatus>(
                                        value: status,
                                        child: Text(
                                          status.displayName,
                                          style: TextStyle(
                                            // Text color matches the primary status color
                                            color: _statusColor(status),
                                            fontWeight: FontWeight.w500,
                                            fontSize: 13,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      // print("value:${value}");
                                      if (value == null) return;
                                      // Logic remains the same
                                      taskModel.status = value;
                                      controller.updateTaskStatus(
                                        status: taskModel.status.value,
                                        projectId:projectId ,
                                        taskId: taskModel.id
                                      );
                                    },
                                  ),
                                ),
                              )
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarStack() {
    return SizedBox(
      width: 100,
      height: 32,
      child: Stack(
        children: List.generate(avatarCount + (extraAvatars != null ? 1 : 0), (index) {
          if (index == avatarCount && extraAvatars != null) {
            return Positioned(
              left: index * 22.0,
              child: CircleAvatar(
                radius: 16,
                backgroundColor: const Color(0xFF334155),
                child: Text(
                  extraAvatars!,
                  style: const TextStyle(fontSize: 12, color: Colors.blueAccent),
                ),
              ),
            );
          }
          return Positioned(
            left: index * 22.0,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF1E293B), width: 2),
              ),
              child: CircleAvatar(
                radius: 14,
                backgroundColor: useInitials ? const Color(0xFF334155) : Colors.grey,
                child: useInitials 
                  ? const Text("JD", style: TextStyle(fontSize: 10, color: Colors.grey))
                  : const Icon(Icons.person, size: 18, color: Colors.white), 
                  // Replace Icon with NetworkImage in a real app
              ),
            ),
          );
        }),
      ),
    );
  }
}