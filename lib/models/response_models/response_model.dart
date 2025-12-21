import 'package:cloud_firestore/cloud_firestore.dart';

enum TaskStatus { todo, inProgress, done }
enum TaskPriority { low, medium, high }

extension TaskStatusX on TaskStatus {
  /// save to Firestore
  String get value => name;

  /// read from Firestore
  static TaskStatus fromValue(String? value) {
    return TaskStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => TaskStatus.todo,
    );
  }
}

class TaskResponseModel {
  final String id;
  final String title;
  final String description;
   TaskStatus status;
  final TaskPriority priority;
  final List<String> assignees;
  final DateTime? dueDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  TaskResponseModel({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
    required this.assignees,
    this.dueDate,
    this.createdAt,
    this.updatedAt,
  });

  factory TaskResponseModel.fromFirestore(
    String id,
    Map<String, dynamic> data,
  ) {
    return TaskResponseModel(
      id: id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      status: TaskStatusX.fromValue(data['status']),
      priority: _parsePriority(data['priority']),
      assignees: List<String>.from(data['assignees'] ?? []),
      dueDate: (data['dueDate'] as Timestamp?)?.toDate(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  static TaskStatus _parseStatus(String? value) {
    switch (value) {
      case 'in_progress':
        return TaskStatus.inProgress;
      case 'done':
        return TaskStatus.done;
      default:
        return TaskStatus.todo;
    }
  }

  static TaskPriority _parsePriority(String? value) {
    switch (value) {
      case 'medium':
        return TaskPriority.medium;
      case 'high':
        return TaskPriority.high;
      default:
        return TaskPriority.low;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'status': status.value,
      'priority': priority.name,
      'assignee': assignees,
      'dueDate': dueDate,
    };
  }
}
