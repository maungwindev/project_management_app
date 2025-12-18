import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart';

class AuthService {
  final FirebaseAuth auth;

  AuthService({required this.auth});

  /// Firebase login replacing API call
  Future<Either<String, User>> login({
    required Map<String, dynamic> requestBody,
  }) async {
    try {
      final email = requestBody['email'] as String?;
      final password = requestBody['password'] as String?;

      if (email == null || password == null) {
        return const Left('Email and password are required');
      }

      final userCredential = await auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      if (userCredential.user != null) {
        return Right(userCredential.user!);
      } else {
        return const Left('Login failed');
      }
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print('FirebaseAuthException code: ${e.code}');
        print('Message: ${e.message}');
      }
      return Left(e.message ?? 'Firebase login failed');
    } catch (e) {
      if (kDebugMode) {
        print('Unexpected error: $e');
      }
      return const Left('Unexpected error occurred');
    }
  }

// For Register
  Future<Either<String, User>> register({
    required Map<String, dynamic> requestBody,
  }) async {
    try {
      final email = requestBody['email'] as String?;
      final password = requestBody['password'] as String?;

      if (email == null || password == null) {
        return const Left('Email and password are required');
      }

      final userCredential = await auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      if (userCredential.user != null) {
        return Right(userCredential.user!);
      } else {
        return const Left('Register failed');
      }
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print('FirebaseAuthException code: ${e.code}');
        print('Message: ${e.message}');
      }
      return Left(e.message ?? 'Firebase register failed');
    } catch (e) {
      if (kDebugMode) {
        print('Unexpected error: $e');
      }
      return const Left('Unexpected error occurred');
    }
  }
}
