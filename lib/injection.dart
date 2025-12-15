import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:pm_app/service/auth_service.dart';
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

    // Controllers / Cubits (can migrate them to GetX Controllers later)
    Get.lazyPut(() => InternetConnectionController());
    Get.lazyPut(() => ThemeController(sharedPref: Get.find()));
    Get.lazyPut(() => ProductsController(productRepo: Get.find()));
    Get.lazyPut(() => CategoryController(categoryRepo: Get.find()));
    Get.lazyPut(() => AuthController(
          authRepository: Get.find(),
          sharedPref: Get.find(),
        ));
    Get.lazyPut(()=>AuthService());
  }
}
