enum ProjectStatus { not_started, ongoing, completed, archived }

class ProjectResponseModel {
  final String id;
  String title;
  String description;
  ProjectStatus status;

  ProjectResponseModel({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
  });

  factory ProjectResponseModel.fromFirestore(String id, Map<String, dynamic> json) {
    return ProjectResponseModel(
      id: id,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      status: ProjectStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
        orElse: () => ProjectStatus.not_started,
      ),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'status': status.toString(),
    };
  }
}
