enum ProjectStatus { not_started, ongoing, completed, archived }

extension ProjectStatusX on ProjectStatus {
  /// save to Firestore
  String get value => name;

  /// read from Firestore
  static ProjectStatus fromValue(String? value) {
    return ProjectStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ProjectStatus.not_started,
    );
  }
}

class ProjectResponseModel {
  final String id;
  String title;
  String description;
  ProjectStatus status;
  List<String> members; // 🔥 NEW
  String ownerId;

  ProjectResponseModel({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.members,
    required this.ownerId
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
      'ownerId':ownerId
    };
  }
}
