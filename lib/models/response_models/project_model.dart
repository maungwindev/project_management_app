enum ProjectStatus { onhold, ongoing, completed }

extension ProjectStatusX on ProjectStatus {
  /// save to Firestore
  String get value => name;

  /// read from Firestore
  static ProjectStatus fromValue(String? value) {
    return ProjectStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ProjectStatus.onhold,
    );
  }
}

extension ProjectStatusExtension on ProjectStatus {
  String get displayName {
    switch (this) {
      case ProjectStatus.onhold:
        return "On Hold";
      case ProjectStatus.ongoing:
        return "Ongoing";
      case ProjectStatus.completed:
        return "Completed";
    }
  }
}

class ProjectResponseModel {
  final String id;
  String title;
  String description;
  ProjectStatus status;
  List<String> members; // 🔥 NEW
  String ownerId;
  String ownerName;

  ProjectResponseModel({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.members,
    required this.ownerId,
    required this.ownerName
  });

  factory ProjectResponseModel.fromFirestore(
    String id,
    Map<String, dynamic> json,
  ) {
    return ProjectResponseModel(
      id: id,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      ownerId: json['ownerId'] ?? '',
      ownerName: json['ownerName'] ?? '',
      status: ProjectStatusX.fromValue(json['status']),
      members: List<String>.from(json['members'] ?? []), // ✅ safe
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'status': status.value,
      'members': members, // 🔥 REQUIRED
      'ownerId':ownerId,
      'ownerName':ownerName
    };
  }
}
