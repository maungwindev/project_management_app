import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:project_frame/core/const/global_const.dart';
import 'package:project_frame/core/local_data/shared_prefs.dart';
import 'package:project_frame/core/router/app_router.dart';
import 'package:project_frame/controller/theme_controller.dart';
import 'package:project_frame/injection.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  runApp(
    EasyLocalization(
      path: 'assets/translations',
      fallbackLocale: const Locale('en', 'US'),
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('my', 'MM'),
      ],
      child: const MyApp(),
    ),
  );
}

/// Main App widget
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Lock portrait orientations
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
    ]);
    
    final sharedPref = SharedPref(); // Or await initialization if async

    final ThemeController themeController =
        Get.put(ThemeController(sharedPref: sharedPref));

    return Obx(() {
      return GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: GlobalConst.appName,
        theme: themeController.theme.value,
        themeMode: themeController.themeMode.value,
        locale: context.locale,
        supportedLocales: context.supportedLocales,
        localizationsDelegates: context.localizationDelegates,
        getPages: appRoutes, // your GetX route list
        initialRoute: '/',
        initialBinding: AppBindings(),
        // Optionally: translations, fallbackLocale, etc for EasyLocalization + GetX integration
      );
    });
  }
}
