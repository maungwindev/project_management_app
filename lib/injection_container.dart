// import 'package:dio/dio.dart';
// import 'package:flutter/foundation.dart';
// import 'package:project_frame/controller/category_cubit/category_cubit.dart';
// import 'package:project_frame/controller/products_cubit/products_cubit.dart';
// import 'package:project_frame/core/const/api_const.dart';
// import 'package:project_frame/core/network/dio_client.dart';
// import 'package:get_it/get_it.dart';
// import 'package:logger/logger.dart';
// import 'package:project_frame/controller/auth_cubit/auth_cubit.dart';
// import 'package:project_frame/controller/internet_cubit/internet_connection_cubit.dart';
// import 'package:project_frame/controller/theme_cubit/theme_cubit.dart';
// import 'package:project_frame/core/local_data/shared_prefs.dart';
// import 'package:project_frame/repository/auth_repo.dart';
// import 'package:project_frame/core/utils/custom_logger.dart';
// import 'package:pretty_dio_logger/pretty_dio_logger.dart';
// import 'package:project_frame/repository/categories_repo.dart';
// import 'package:project_frame/repository/products_repo.dart';

// final getIt = GetIt.instance;

// Future<void> initGetIt() async {
//   /// Blocs/Cubits
//   getIt.registerFactory(() => InternetConnectionCubit());
//   getIt.registerFactory(() => ThemeCubit(sharedPref: getIt.call()));
//   getIt.registerFactory(() => ProductsCubit(productRepo: getIt.call()));
//   getIt.registerFactory(() => CategoryCubit(categoryRepo: getIt.call()));
//   getIt.registerFactory(
//       () => AuthCubit(authRepository: getIt.call(), sharedPref: getIt.call()));

//   /// Repositories
//   getIt.registerLazySingleton(
//       () => AuthRepository(dio: getIt.call(), logService: getIt.call()));
//   getIt.registerLazySingleton(
//       () => ProductsRepo(dioClient: getIt.call(), logger: getIt.call()));
//   getIt.registerLazySingleton(
//       () => CategoryRepository(dioClient: getIt.call(), logger: getIt.call()));

//   /// Network client
//   getIt.registerLazySingleton(
//       () => DioClient(sharedPref: getIt.call(), dio: getIt.call()));

//   /// Custom Logger
//   getIt.registerLazySingleton(() => CustomLogger(logger: getIt.call()));

//   /// Logger Package
//   getIt.registerLazySingleton(() => Logger());

//   /// shared prefs
//   getIt.registerLazySingleton(() => SharedPref());

//   /// Dio
//   getIt.registerLazySingleton(() {
//     final Dio dio = Dio(
//       BaseOptions(
//         baseUrl: ApiConst.BASE_URL_DEV,
//         headers: {
//           'Content-Type': 'application/json',
//         },
//         // connectTimeout: const Duration(seconds: ApiConst.TIMEOUT_DURATION_IN_SECONDS),
//         // receiveTimeout: const Duration(seconds: ApiConst.TIMEOUT_DURATION_IN_SECONDS),
//         // sendTimeout: const Duration(seconds: ApiConst.TIMEOUT_DURATION_IN_SECONDS),
//       ),
//     );
//     if (kDebugMode) {
//       dio.interceptors.add(
//         PrettyDioLogger(
//           requestHeader: true,
//           requestBody: true,
//           responseBody: true,
//           responseHeader: true,
//           error: true,
//           compact: true,
//           maxWidth: 90,
//         ),
//       );
//     }
//     return dio;
//   });
// }
