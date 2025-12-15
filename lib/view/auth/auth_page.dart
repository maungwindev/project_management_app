import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pm_app/controller/auth_controller.dart';

class AuthGate extends StatelessWidget {
  AuthGate({super.key});

  final AuthController authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    // Call once
    authController.checkLoginStatus();

    return Obx(() {
      if (authController.isLoading.value) {
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      }

      if (authController.isLoggedIn.value) {
        // Logged in → Home
        Future.microtask(() => Get.offAllNamed('/home'));
      } else {
        // Not logged in → Login
        Future.microtask(() => Get.offAllNamed('/login'));
      }

      return const SizedBox(); // empty while routing
    });
  }
}
