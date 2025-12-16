import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fpdart/fpdart.dart';
import 'package:pm_app/core/utils/custom_logger.dart';
import 'package:pm_app/models/response_models/project_model.dart';

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
      await FirebaseFirestore.instance.collection('projects').add({
        'ownerId': uid,
        'title': title,
        'description': description,
        'status': 'not_started',
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
        .where('ownerId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map<Either<String, List<ProjectResponseModel>>>((snapshot) {
      try {
        final projects = snapshot.docs.map((doc) {
          return ProjectResponseModel.fromFirestore(
            doc.id,
            doc.data(),
          );
        }).toList();

        logService.logInfo(projects.toList().toString());
        return Right(projects);
      } catch (e) {
        logService.logError(e.toString());
        return Left('Failed to parse project data: $e');
      }
    }).handleError((e) {
      logService.logError(e.toString());
      // Handle Firestore stream errors
      return Left('Firestore error: $e');
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
