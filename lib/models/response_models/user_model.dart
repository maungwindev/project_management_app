class UserResponseModel {
  final String id;
  final String name;
  final String email;
  final String fcmToken;
  final List<String>? teamMembers;

  UserResponseModel({
    required this.id,
    required this.name,
    required this.email,
    required this.fcmToken,
    this.teamMembers
  });

  factory UserResponseModel.fromFirestore(Map<String, dynamic> data, String id) {
    return UserResponseModel(
      id: id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      fcmToken: data['fcmToken'] ?? '',
      teamMembers: data['team_members'].isNotEmpty ? data['team_members']:[]
    );
  }
}
