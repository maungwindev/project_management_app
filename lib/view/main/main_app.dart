// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:pm_app/controller/auth_cubit/auth_cubit.dart';
// import 'package:pm_app/controller/category_cubit/category_cubit.dart';
// import 'package:pm_app/controller/internet_cubit/internet_connection_cubit.dart';
// import 'package:pm_app/controller/products_cubit/products_cubit.dart';
// import 'package:pm_app/controller/theme_cubit/theme_cubit.dart';
// import 'package:pm_app/core/const/global_const.dart';
// import 'package:pm_app/core/router/app_router.dart';
// import 'package:pm_app/injection_container.dart' as ic;

// /// main app
// class MyApp extends StatefulWidget {
//   const MyApp({super.key});

//   @override
//   State<MyApp> createState() => _MyAppState();
// }

// class _MyAppState extends State<MyApp> {
//   @override
//   void initState() {
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
    
//     SystemChrome.setPreferredOrientations([
//       DeviceOrientation.portraitDown,
//       DeviceOrientation.portraitUp,
//     ]);

//     return MultiBlocProvider(
//       providers: [
//         /// initialize all the providers
//         BlocProvider(create: (context) => ic.getIt<AuthCubit>()..checkLoginStatus()),
//         BlocProvider(create: (context) => ic.getIt<ThemeCubit>()),
//         BlocProvider(create: (context) => ic.getIt<InternetConnectionCubit>()),
//         BlocProvider(create: (context) => ic.getIt<ProductsCubit>()),
//         BlocProvider(create: (context) => ic.getIt<CategoryCubit>()),
//       ],
//       child: BlocBuilder<ThemeCubit, ThemeState>(
//         builder: (context, themeState) {
//           return MaterialApp.router(
//             title: GlobalConst.appName,
//             theme: themeState.theme,
//             themeMode: themeState.themeMode,
//             debugShowCheckedModeBanner: false,
//             locale: context.locale,
//             supportedLocales: context.supportedLocales,
//             localizationsDelegates: context.localizationDelegates,
//             routerConfig: appRouter,
//           );
//         },
//       ),
//     );
//   }
// }
