import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pm_app/core/const/global_const.dart';
import 'package:pm_app/core/local_data/shared_prefs.dart';
import 'package:pm_app/core/router/app_router.dart';
import 'package:pm_app/controller/theme_controller.dart';
import 'package:pm_app/core/service/firebase_background.dart';
import 'package:pm_app/firebase_options.dart';
import 'package:pm_app/injection.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  /// ✅ Only enable Crashlytics for mobile (not Web)
  if (!kIsWeb) {
    await FirebaseCrashlytics.instance
        .setCrashlyticsCollectionEnabled(!kDebugMode);

    // Catch Flutter framework errors
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

    // Catch platform errors
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  }

  /// 🔥 Register Firebase Messaging background handler (only for mobile)
  if (!kIsWeb) {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  }

  /// Firestore offline persistence
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  /// Ensure EasyLocalization is initialized
  await EasyLocalization.ensureInitialized();

  /// Dependency Injection (your get_it / injectable setup)
  // await configureDependencies();

  /// Run the app
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

    final sharedPref = SharedPref(); // sync or await if needed

    final ThemeController themeController =
        Get.put(ThemeController(sharedPref: sharedPref));

    return Obx(() {
      return GetMaterialApp(
        navigatorKey: Get.key,
        debugShowCheckedModeBanner: false,
        title: GlobalConst.appName,
        theme: themeController.theme.value,
        themeMode: themeController.themeMode.value,
        locale: context.locale,
        supportedLocales: context.supportedLocales,
        localizationsDelegates: context.localizationDelegates,
        getPages: appRoutes,
        initialRoute: '/',
        initialBinding: AppBindings(),
      );
    });
  }
}
