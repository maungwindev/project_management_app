class CategoryModel {
  int? id;
  String? name;
  String? description;
  String? status;

  CategoryModel({
    this.id,
    this.name,
    this.description,
    this.status,
  });

  factory CategoryModel.fromMap(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'status': status,
    };
  }

  CategoryModel copyWith({
    int? id,
    String? name,
    String? description,
    String? phone,
    String? password,
    bool? isChanged,
    String? changedDate,
    String? dob,
    String? status,
    String? profilePhoto,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      status: status ?? this.status,
    );
  }
}
