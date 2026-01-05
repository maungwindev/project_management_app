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
    required this.ownerId,
  });

  final TaskController controller = Get.find<TaskController>();
  static final Set<String> _shownSyncedOnce = {};

  Color _statusColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.todo:
        return const Color(0xFF64748B);
      case TaskStatus.inProgress:
        return const Color(0xFF3B82F6);
      case TaskStatus.done:
        return const Color(0xFF10B981);
      default:
        return Colors.black;
    }
  }

  Widget buildSyncIndicator() {
    switch (taskModel.syncState) {
      case SyncState.offline:
        return const Icon(Icons.cloud_off, color: Colors.orange, size: 16);

      case SyncState.pending:
        // Reset so synced can show once later
        _shownSyncedOnce.remove(taskModel.id);
        return const SizedBox(
          width: 14,
          height: 14,
          child: CircularProgressIndicator(strokeWidth: 2),
        );

      case SyncState.synced:
        // 👇 show only ONCE after pending
        if (_shownSyncedOnce.contains(taskModel.id)) {
          return const SizedBox.shrink();
        }

        _shownSyncedOnce.add(taskModel.id);

        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 1, end: 0),
          duration: const Duration(seconds: 2),
          builder: (_, value, child) => Opacity(opacity: value, child: child),
          child: const Icon(Icons.cloud_done, color: Colors.green, size: 16),
        );
    }
  }

  Widget _buildAvatarStack() {
    return SizedBox(
      width: 100,
      height: 32,
      child: Stack(
        children: List.generate(avatarCount + (extraAvatars != null ? 1 : 0),
            (index) {
          if (index == avatarCount && extraAvatars != null) {
            return Positioned(
              left: index * 22.0,
              child: CircleAvatar(
                radius: 16,
                backgroundColor: const Color(0xFF334155),
                child: Text(
                  extraAvatars!,
                  style:
                      const TextStyle(fontSize: 12, color: Colors.blueAccent),
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
                backgroundColor:
                    useInitials ? const Color(0xFF334155) : Colors.grey,
                child: useInitials
                    ? const Text("JD",
                        style: TextStyle(fontSize: 10, color: Colors.grey))
                    : const Icon(Icons.person, size: 18, color: Colors.white),
              ),
            ),
          );
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
              if (currentUserId == ownerId)
                PopupMenuButton<int>(
                  offset: const Offset(0, 50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      onTap: () => onEdit(),
                      child: Row(
                        children: const [
                          Icon(Icons.edit, size: 18, color: Colors.black),
                          SizedBox(width: 8),
                          Text("Edit"),
                        ],
                      ),
                    ),
                    const PopupMenuDivider(),
                    PopupMenuItem(
                      onTap: () {
                        controller.deleteTask(
                          projectId: projectId,
                          taskId: taskModel.id,
                        );
                      },
                      child: Row(
                        children: const [
                          Icon(Icons.delete_forever,
                              size: 18, color: Colors.black),
                          SizedBox(width: 8),
                          Text("Delete"),
                        ],
                      ),
                    ),
                  ],
                  child: const Icon(Icons.more_horiz, color: Colors.grey),
                ),
            ],
          ),
          const SizedBox(height: 12),
          // Title
          Row(
            children: [
              Text(
                title,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 6),
              buildSyncIndicator(),
            ],
          ),
          const SizedBox(height: 12),
          // Description
          Text(
            description,
            style: const TextStyle(fontSize: 14, height: 1.5),
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
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusColor(taskModel.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<TaskStatus>(
                    focusColor: Colors.transparent,
                    value: taskModel.status,
                    icon: Icon(Icons.keyboard_arrow_down,
                        color: _statusColor(taskModel.status), size: 18),
                    isDense: true,
                    dropdownColor: Colors.white,
                    items: TaskStatus.values.map((status) {
                      return DropdownMenuItem<TaskStatus>(
                        value: status,
                        child: Text(status.displayName,
                            style: TextStyle(
                                color: _statusColor(status),
                                fontWeight: FontWeight.w500,
                                fontSize: 13)),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      taskModel.status = value;
                      controller.updateTaskStatus(
                        status: taskModel.status.value,
                        projectId: projectId,
                        taskId: taskModel.id,
                      );
                      // Mark task as synced
                      // controller.markSynced(taskModel.id);
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
