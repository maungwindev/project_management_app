import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fpdart/fpdart.dart';
import 'package:pm_app/core/utils/custom_logger.dart';
import 'package:pm_app/models/response_models/project_model.dart';
import 'package:pm_app/models/response_models/user_model.dart';
import 'package:rxdart/rxdart.dart';

class ProjectService {
  final FirebaseAuth auth;
  final CustomLogger logService;

  ProjectService({required this.auth, required this.logService});

  Future<Either<String, String>> createProject({
    required String title,
    required String description,
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      return const Left('User not logged in');
    }

    try {
      // ✅ Fetch user ONCE
      final userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      final username = userDoc.exists
          ? UserResponseModel.fromFirestore(
              userDoc.data()!,
              userDoc.id,
            ).name
          : 'Unknown';

      // ✅ Save NORMAL String value
      await FirebaseFirestore.instance.collection('projects').add({
        'ownerId': uid,
        'ownerName': username, // ✅ String
        'title': title,
        'description': description,
        'status': 'not_started',
        'members': [uid],
        'createdAt': FieldValue.serverTimestamp(),
      });

      logService.logInfo("Success");
      return const Right('Project Created Successfully!');
    } on FirebaseException catch (e) {
      return Left('Failed to create project: ${e.message}');
    } catch (e) {
      return Left('Unexpected error: $e');
    }
  }

  Stream<Either<String, List<ProjectResponseModel>>> getProjects() {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return FirebaseFirestore.instance
        .collection('projects')
        .where('members', arrayContains: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map<Either<String, List<ProjectResponseModel>>>((snapshot) {
      try {
        final projects = snapshot.docs.map((doc) {
          return ProjectResponseModel.fromFirestore(doc.id, doc.data());
        }).toList();

        logService.logInfo(projects.toString());
        return Right(projects);
      } catch (e) {
        logService.logError(e.toString());
        return Left('Failed to parse project data: $e');
      }
    }).onErrorReturnWith((error, stackTrace) {
      // ✅ Use onErrorReturnWith to emit a value instead of changing the stream type
      logService.logError(error.toString());
      return Left('Firestore error: $error');
    });
  }

  Future<Either<String, String>> updateProjectStatus({
    required String projectId,
    required String status,
  }) async {
    try {
      await FirebaseFirestore.instance
          .collection('projects')
          .doc(projectId)
          .update({'status': status});

      logService.logInfo("Project $projectId status updated to $status");
      return const Right('Project status updated successfully!');
    } on FirebaseException catch (e) {
      logService.logError('Failed to update status: ${e.message}');
      return Left('Failed to update project status: ${e.message}');
    } catch (e) {
      logService.logError('Unexpected error: $e');
      return Left('Unexpected error: $e');
    }
  }
}
