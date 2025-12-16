import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:pm_app/controller/project_controller.dart';
import 'package:pm_app/controller/task_controller.dart';
import 'package:pm_app/controller/user_controller.dart';
import 'package:pm_app/repository/project_repo.dart';
import 'package:pm_app/repository/task_repo.dart';
import 'package:pm_app/repository/user_repo.dart';
import 'package:pm_app/service/auth_service.dart';
import 'package:pm_app/service/project_service.dart';
import 'package:pm_app/service/task_service.dart';
import 'package:pm_app/service/user_service.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:pm_app/controller/auth_controller.dart';
import 'package:pm_app/controller/category_controller.dart';
import 'package:pm_app/controller/connection_controller.dart';
import 'package:pm_app/controller/product_controller.dart';
import 'package:pm_app/controller/theme_controller.dart';
import 'package:pm_app/core/const/api_const.dart';
import 'package:pm_app/core/local_data/shared_prefs.dart';
import 'package:pm_app/core/network/dio_client.dart';
import 'package:pm_app/core/utils/custom_logger.dart';
import 'package:pm_app/repository/auth_repo.dart';
import 'package:pm_app/repository/categories_repo.dart';
import 'package:pm_app/repository/products_repo.dart';

class AppBindings extends Bindings {
  @override
  void dependencies() {
    // Shared Prefs
    Get.lazyPut(() => SharedPref());

    // Logger
    Get.lazyPut(() => Logger());

    // Custom Logger
    Get.lazyPut(() => CustomLogger(logger: Get.find()));

    // Dio
    Get.lazyPut<Dio>(() {
      final dio = Dio(
        BaseOptions(
          baseUrl: ApiConst.BASE_URL_DEV,
          headers: {'Content-Type': 'application/json'},
        ),
      );

      if (kDebugMode) {
        dio.interceptors.add(
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

      return dio;
    });

    // DioClient
    Get.lazyPut(() => DioClient(sharedPref: Get.find(), dio: Get.find()));

    // Repositories
    Get.lazyPut(() => AuthRepository(authService: Get.find(), logService: Get.find()));
    Get.lazyPut(() => ProductsRepo(dioClient: Get.find(), logger: Get.find()));
    Get.lazyPut(() => CategoryRepository(dioClient: Get.find(), logger: Get.find()));
    Get.lazyPut(() => ProjectRepository(projectService: Get.find(), logger: Get.find()));
    Get.lazyPut(() => TaskRepository(taskService: Get.find(), logger: Get.find()));
    Get.lazyPut(() => UserRepository(userService: Get.find(), logger: Get.find()));

    // Controllers / Cubits (can migrate them to GetX Controllers later)
    Get.lazyPut(() => InternetConnectionController());
    Get.lazyPut(() => ThemeController(sharedPref: Get.find()));
    Get.lazyPut(() => ProductsController(productRepo: Get.find()));
    Get.lazyPut(() => CategoryController(categoryRepo: Get.find()));
    Get.lazyPut(() => ProjectController(projectRepository: Get.find()));
    Get.lazyPut(() => TaskController(taskRepository: Get.find(),userRepository: Get.find()));
    Get.lazyPut(() => UserController(userRepository: Get.find()));
    Get.lazyPut(() => AuthController(
          authRepository: Get.find(),
          sharedPref: Get.find(),
        ));
    Get.lazyPut(()=>AuthService(auth: Get.find()));
    Get.lazyPut(()=>ProjectService(auth: Get.find(),logService: Get.find()));
    Get.lazyPut(()=>TaskService(firestore: Get.find(),logger: Get.find()));
    Get.lazyPut(()=>UserService(firestore: Get.find(),logger: Get.find()));

    // Firebase Instance
    Get.lazyPut<FirebaseAuth>((){
      FirebaseAuth auth  = FirebaseAuth.instance;
      return auth;
    });

    Get.lazyPut(() => FirebaseFirestore.instance);

  }
}
