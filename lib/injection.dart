import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:pm_app/controller/project_controller.dart';
import 'package:pm_app/controller/project_ui_controller.dart';
import 'package:pm_app/controller/task_controller.dart';
import 'package:pm_app/controller/task_ui_controller.dart';
import 'package:pm_app/controller/user_controller.dart';
import 'package:pm_app/core/service/firebase_noiti_service.dart';
import 'package:pm_app/core/service/local_noti_service.dart';
import 'package:pm_app/repository/project_repo.dart';
import 'package:pm_app/repository/task_repo.dart';
import 'package:pm_app/repository/user_repo.dart';
import 'package:pm_app/service/auth_service.dart';
import 'package:pm_app/service/connection_service.dart';
import 'package:pm_app/service/project_service.dart';
import 'package:pm_app/service/task_service.dart';
import 'package:pm_app/service/user_service.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:pm_app/controller/auth_controller.dart';
import 'package:pm_app/controller/connection_controller.dart';
import 'package:pm_app/controller/theme_controller.dart';
import 'package:pm_app/core/const/api_const.dart';
import 'package:pm_app/core/local_data/shared_prefs.dart';
import 'package:pm_app/core/network/dio_client.dart';
import 'package:pm_app/core/utils/custom_logger.dart';
import 'package:pm_app/repository/auth_repo.dart';
class AppBindings extends Bindings {
  @override
  void dependencies() {

    // 🔐 Firebase (GLOBAL)
    Get.put<FirebaseAuth>(FirebaseAuth.instance, permanent: true);
    Get.put<FirebaseFirestore>(FirebaseFirestore.instance, permanent: true);
    Get.lazyPut(
      () => LocalNotificationService(),
      fenix: true,
    );
     Get.lazyPut(
      () => FirebaseNotificationService(localNotificationService: Get.find()),
      fenix: true,
    );

    // 🔐 Core Utils
    Get.put<Logger>(Logger(), permanent: true);
    Get.put<CustomLogger>(
      CustomLogger(logger: Get.find()),
      permanent: true,
    );
    Get.put<SharedPref>(SharedPref(), permanent: true);

    // 🔐 Auth Core
    Get.put<AuthService>(
      AuthService(auth: Get.find(),firestore: Get.find()),
      permanent: true,
    );

    // 🌐 Dio
    Get.put<Dio>(
      Dio(
        BaseOptions(
          baseUrl: ApiConst.BASE_URL_DEV,
          headers: {'Content-Type': 'application/json'},
        ),
      ),
      permanent: true,
    );

    if (kDebugMode) {
      Get.find<Dio>().interceptors.add(
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseBody: true,
          responseHeader: true,
          error: true,
          compact: true,
          maxWidth: 90,
        ),
      );
    }

    // 🌐 Dio Client
    Get.put(
      DioClient(sharedPref: Get.find(), dio: Get.find()),
      permanent: true,
    );

    // 📦 Services
    Get.lazyPut(
      () => UserService(
        firestore: Get.find(),
        authService: Get.find(),
      ),
      fenix: true,
    );
    Get.lazyPut(
      () => ProjectService(
        auth: Get.find(),
        logService: Get.find(),
      ),
      fenix: true,
    );
    Get.lazyPut(
      () => TaskService(
        firestore: Get.find(),
        logger: Get.find(),
      ),
      fenix: true,
    );

    Get.lazyPut(
      () => ConnectionService(
        firestore: Get.find(),
      ),
      fenix: true,
    );

    // 📦 Repositories
    Get.lazyPut(
      () => AuthRepository(
        authService: Get.find(),
        logService: Get.find(),
      ),
      fenix: true,
    );
    Get.lazyPut(() => UserRepository(userService: Get.find(), logger: Get.find()), fenix: true);
    Get.lazyPut(() => ProjectRepository(projectService: Get.find(), logger: Get.find()), fenix: true);
    Get.lazyPut(() => TaskRepository(taskService: Get.find(), logger: Get.find()), fenix: true);

    // 🎮 Controllers
    Get.lazyPut(() => AuthController(
      authRepository: Get.find(),
      sharedPref: Get.find(),
    ), fenix: true);

    Get.lazyPut(() => UserController(userRepository: Get.find(),sharedPref: Get.find(),connectionService: Get.find(),notificationService: Get.find()), fenix: true);
    Get.lazyPut(() => ProjectController(projectRepository: Get.find()), fenix: true);
    Get.lazyPut(() => TaskController(
      taskRepository: Get.find(),
      userRepository: Get.find(),
    ), fenix: true);

    Get.lazyPut(() => ThemeController(sharedPref: Get.find()), fenix: true);
    Get.lazyPut(() => InternetConnectionController(), fenix: true);
    Get.put(ProjectUIController());
    // Get.put(TaskUIController());
  }
}
