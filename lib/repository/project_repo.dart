
import 'package:fpdart/fpdart.dart';
import 'package:pm_app/core/utils/custom_logger.dart';
import 'package:pm_app/models/response_models/project_model.dart';
import 'package:pm_app/service/project_service.dart';

class ProjectRepository {
  final CustomLogger logger;
  final ProjectService projectService;

  ProjectRepository({required this.logger, required this.projectService});

  Future<Either<String, String>> createProject({
    required String title,
    required String description,
  }) async{

    final responseStatus = await projectService.createProject(title: title, description: description);
    return responseStatus.fold((error)=>Left(error), (success)=>Right(success));
  }

  Future<Either<String, String>> updateProject({
    required String title,
    required String description,
    required String projectId
  }) async{

    final responseStatus = await projectService.updateProject(title: title, description: description,projectId: projectId);
    return responseStatus.fold((error)=>Left(error), (success)=>Right(success));
  }


  Stream<Either<String, List<ProjectResponseModel>>> getAllProjects() {
   final responseStatus =  projectService.getProjects();

   return responseStatus;
  }

  Future<Either<String,void>> updatedProjectStatus({
    required String status,
    required String projectId
  }) async{

    final responseStatus = await projectService.updateProjectStatus(projectId: projectId, status: status);

    return responseStatus.fold((error)=>Left("Error"), (success)=>Right(null));
  }

  // ---------------- DELETE PROJECT ----------------
  Future<Either<String, String>> deleteTask({
    required String projectId,
  }) async {
    final result = await projectService.deleteProject(
      projectId: projectId
    );

    return result.fold(
      (error) => Left(error),
      (success) => Right(success),
    );
  }
}
