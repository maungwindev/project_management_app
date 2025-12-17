enum ProjectStatus { not_started, ongoing, completed, archived }

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
      status: ProjectStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
        orElse: () => ProjectStatus.not_started,
      ),
      members: List<String>.from(json['members'] ?? []), // ✅ safe
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'status': status.toString(),
      'members': members, // 🔥 REQUIRED
      'ownerId':ownerId
    };
  }
}
