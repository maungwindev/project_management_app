import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:pm_app/models/response_models/user_model.dart';
import 'package:pm_app/service/auth_service.dart';

class UserService {
  final FirebaseFirestore firestore;
  final AuthService authService;
  // final CustomLogger logger;

  UserService(
      {required this.firestore,
      // required this.logger,
      required this.authService});

  CollectionReference<Map<String, dynamic>> get _userRef =>
      firestore.collection('users');

  // ---------------- CREATE USER ----------------
  Future<Either<String, String>> createUser({
    required Map<String, dynamic> requestBody,
  }) async {
    try {
      final userInfo = await authService.register(requestBody: requestBody);
      String? token = await FirebaseMessaging.instance.getToken();
      return await userInfo.fold(
        (error) async => Left(error), // Return Left immediately on error
        (success) async {
          // Use Firebase UID as the Firestore document ID
          final docRef = _userRef.doc(success.uid);
          await docRef.set({
            'name': requestBody['name'],
            'email': success.email,
            'fcm_token': token,
            'team_members': []
          });
          return Right('User created successfully'); // ✅ Return Right properly
        },
      );
    } catch (e,s) {
       FirebaseCrashlytics.instance.recordError(e, s);
      return Left('Failed to create user');
    }
  }

  // ---------------- READ USERS ----------------
  Stream<Either<String, List<UserResponseModel>>> getUsers() {
 final user = FirebaseAuth.instance.currentUser;

  if (user == null) {
    debugPrint('User not logged in, skipping getUsers');
    return const Stream.empty();
  }

  final currentUid = user.uid;
    final currentUserRef = _userRef.doc(currentUid);
    return currentUserRef.snapshots().asyncMap((currentUserSnap) async {
      if (!currentUserSnap.exists) {
        return Left<String, List<UserResponseModel>>("Current user not found");
      }

      print("he he he eheeehre:${currentUserSnap.data()}");

      final teamMembers =
          List<String>.from(currentUserSnap.data()?['team_members'] ?? []);

      if (teamMembers.isEmpty) {
        // No team members
        return Right<String, List<UserResponseModel>>([]);
      }

      print("checking team members:${teamMembers.toString()}");
      // Fetch users whose IDs are in team_members
      final querySnapshot = await _userRef
          .where(FieldPath.documentId, whereIn: teamMembers)
          .get();

      print("querySnapshot :${querySnapshot.docs.length.toString()}");

      final users = querySnapshot.docs
          .map((doc) {
            print("doc.id: ${doc.id}");
            print("doc.data(): ${doc.data()}");
            try {
              return UserResponseModel.fromFirestore(doc.data(), doc.id);
            } catch (e) {
              print("Error converting user: $e");
              return null;
            }
          })
          .whereType<UserResponseModel>()
          .toList();

      print("users final list: $users");
      return Right<String, List<UserResponseModel>>(users);
    }).handleError((e) {
      
      return Left<String, List<UserResponseModel>>("Failed to fetch users");
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
        final user =
            UserResponseModel.fromFirestore(snapshot.data()!, snapshot.id);
        return Right(user);
      },
    ).handleError((e) {
      // logger.logError('Get Current User Error: $e');
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
    } catch (e,s) {
       FirebaseCrashlytics.instance.recordError(e, s);
      // logger.logError('Update User Error: $e');
      return Left('Failed to update user');
    }
  }

  // ---------------- DELETE USER ----------------
  Future<Either<String, String>> deleteUser({required String userId}) async {
    try {
      await _userRef.doc(userId).delete();
      return const Right('User deleted successfully');
    } catch (e,s) {
       FirebaseCrashlytics.instance.recordError(e, s);
      // logger.logError('Delete User Error: $e');
      return Left('Failed to delete user');
    }
  }

  // ---------- Check User to choose as a member

  Future<Either<bool, UserResponseModel>> checkUser(
      {required String email}) async {
    try {
      final query =
          await _userRef.where('email', isEqualTo: email).limit(1).get();

      if (query.docs.isEmpty) {
        return const Left(false);
      }

      final user = UserResponseModel.fromFirestore(
          query.docs.first.data(), query.docs.first.id);
      print("what is first:${query.docs.first.data()}");
      return Right(user); // UID
    } catch (e,s) {
       FirebaseCrashlytics.instance.recordError(e, s);
      return const Left(false);
    }
  }
}
