import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fpdart/fpdart.dart';
import 'package:pm_app/core/utils/custom_logger.dart';
import 'package:pm_app/models/response_models/user_model.dart';

class UserService {
  final FirebaseFirestore firestore;
  final CustomLogger logger;

  UserService({required this.firestore, required this.logger});

  CollectionReference<Map<String, dynamic>> get _userRef =>
      firestore.collection('users');

  // ---------------- CREATE USER ----------------
  Future<Either<String, String>> createUser({
    required String name,
    required String email,
  }) async {
    try {
      await _userRef.add({
        'name': name,
        'email': email,
      });
      return const Right('User created successfully');
    } catch (e) {
      logger.logError('Create User Error: $e');
      return Left('Failed to create user');
    }
  }

  // ---------------- READ USERS ----------------
  Stream<Either<String, List<UserResponseModel>>> getUsers() {
    return _userRef
        .snapshots()
        .map<Either<String, List<UserResponseModel>>>((snapshot) {
      final users = snapshot.docs.map((doc) {
        return UserResponseModel.fromFirestore(doc.data(), doc.id);
      }).toList();

      return Right<String, List<UserResponseModel>>(
          users); // ✅ specify type explicitly
    }).handleError((e) {
      logger.logError('Get Users Error: $e');
      return Left<String, List<UserResponseModel>>(
          'Failed to fetch users'); // ✅ specify type explicitly
    });
  }

   /// Stream current logged-in user's info
  Stream<Either<String, UserResponseModel>> getCurrentUser() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    return _userRef.doc(uid).snapshots().map<Either<String, UserResponseModel>>(
      (snapshot) {
        if (!snapshot.exists) {
          return Left('User not found');
        }
        final user = UserResponseModel.fromFirestore(snapshot.data()!, snapshot.id);
        return Right(user);
      },
    ).handleError((e) {
      logger.logError('Get Current User Error: $e');
      return Left('Failed to fetch user info');
    });
  }

  // ---------------- UPDATE USER ----------------
  Future<Either<String, String>> updateUser({
    required String userId,
    required String name,
    required String email,
  }) async {
    try {
      await _userRef.doc(userId).update({
        'name': name,
        'email': email,
      });
      return const Right('User updated successfully');
    } catch (e) {
      logger.logError('Update User Error: $e');
      return Left('Failed to update user');
    }
  }

  // ---------------- DELETE USER ----------------
  Future<Either<String, String>> deleteUser({required String userId}) async {
    try {
      await _userRef.doc(userId).delete();
      return const Right('User deleted successfully');
    } catch (e) {
      logger.logError('Delete User Error: $e');
      return Left('Failed to delete user');
    }
  }
}
