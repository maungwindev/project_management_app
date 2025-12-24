import 'dart:async';
import 'package:get/get.dart';
import 'package:fpdart/fpdart.dart';
import 'package:pm_app/models/response_models/project_model.dart';
import 'package:pm_app/repository/project_repo.dart';

class ProjectController extends GetxController {
  final ProjectRepository projectRepository;

  ProjectController({required this.projectRepository});

  // Table state
  var isLoading = false.obs;
  var projectList = <ProjectResponseModel>[].obs;
  var errorMessage = ''.obs;

  // Create dialog state
  var isCreating = false.obs;
  var successMessage = ''.obs;

  StreamSubscription<Either<String, List<ProjectResponseModel>>>? _projectSub;

  @override
  void onInit() {
    super.onInit();
    _subscribeProjects();
  }

  void _subscribeProjects() {
    isLoading.value = true;
    _projectSub?.cancel();

    _projectSub = projectRepository.getAllProjects().listen(
      (either) {
        either.fold(
          (error) {
            errorMessage.value = error;
            isLoading.value = false;
          },
          (data) {
            projectList.assignAll(data);
            errorMessage.value = '';
            isLoading.value = false;
          },
        );
      },
      onError: (e) {
        errorMessage.value = e.toString();
        isLoading.value = false;
      },
    );
  }

  Future<void> createProject({
    required String title,
    required String description,
  }) async {
    // isCreating.value = true;
    successMessage.value = '';
    errorMessage.value = '';

    final result = await projectRepository.createProject(
      title: title,
      description: description,
    );

    // isCreating.value = false;

    result.fold(
      (error) => errorMessage.value = error,
      (success) => successMessage.value = success,
    );

    
  }

   Future<void> updateProject({
    required String title,
    required String description,
    required String projectId
  }) async {
    // isCreating.value = true;
    successMessage.value = '';
    errorMessage.value = '';

    final result = await projectRepository.updateProject(
      projectId: projectId,
      title: title,
      description: description,
    );

    // isCreating.value = false;

    result.fold(
      (error) => errorMessage.value = error,
      (success) => successMessage.value = success,
    );

    
  }

  Future<void> updatedProjectStatus(
      {required String status, required String projectId}) async {
    final result = await projectRepository.updatedProjectStatus(
        status: status, projectId: projectId);
    result.fold((error) => errorMessage.value = error,
        (success) {
          projectList.refresh();
          successMessage.value = '';

          });
  }

  Future<void> deleteProject({
    required String projectId
  }) async {
    final result = await projectRepository.deleteTask(
      projectId: projectId
    );

    result.fold(
      (error) => errorMessage.value = error,
      (_) {
        projectList.refresh();
        successMessage.value = 'Project deleted';
      },
    );
  }

  @override
  void onClose() {
    _projectSub?.cancel();
    super.onClose();
  }
}
