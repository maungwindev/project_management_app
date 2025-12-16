class UserResponseModel {
  final String id;
  final String name;
  final String email;

  UserResponseModel({
    required this.id,
    required this.name,
    required this.email,
  });

  factory UserResponseModel.fromFirestore(Map<String, dynamic> data, String id) {
    return UserResponseModel(
      id: id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
    );
  }
}
