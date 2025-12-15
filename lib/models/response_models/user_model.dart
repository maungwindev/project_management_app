import 'package:equatable/equatable.dart';

class UserResponseModel extends Equatable {
  final String msg;
  final bool status;
  final UserModel user;

  const UserResponseModel({
    required this.status,
    required this.msg,
    required this.user,
  });

  factory UserResponseModel.fromMap(Map<String, dynamic> map) {
    return UserResponseModel(
      status: map["status"],
      msg: map["msg"],
      user: map["data"],
    );
  }

  @override
  List<Object?> get props => [status, msg, user];
}

class UserModel extends Equatable {
  final int? id;
  final String? name;
  final String? email;
  final String? phone;
  final String? gender;
  final String? dob;
  final String? address;
  final String? token;
  final String? image;

  const UserModel({
    this.id,
    this.name,
    this.email,
    this.phone,
    this.gender,
    this.dob,
    this.address,
    this.token,
    this.image,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      name: map['name'] ?? "",
      email: map['email'] ?? "",
      phone: map['phone'] ?? "",
      gender: map['gender'] ?? "",
      dob: map['dob'] ?? "",
      address: map['address'] ?? "",
      token: map["token"] ?? "",
      image: map["image"] ?? "",
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'gender': gender,
      'dob': dob,
      'address': address,
      'image': image,
    };
  }

  UserModel copyWith({
    int? id,
    String? name,
    String? email,
    String? phone,
    String? gender,
    String? dob,
    String? address,
    String? token,
    String? image,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      gender: gender ?? this.gender,
      dob: dob ?? this.dob,
      address: address ?? this.address,
      token: token ?? this.token,
      image: image ?? this.image,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        phone,
        gender,
        dob,
        address,
        token,
        image,
      ];
}
