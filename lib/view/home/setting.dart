import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pm_app/controller/auth_controller.dart';
import 'package:pm_app/controller/connection_controller.dart';
import 'package:pm_app/controller/user_controller.dart';
import 'package:pm_app/core/const/size_const.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userController = Get.find<UserController>();
    final authController = Get.find<AuthController>();
    
  final InternetConnectionController internetController = Get.find();

    final isMobile = MediaQuery.of(context).size.width < 600;

    return Obx(() {
      final user = userController.currentUserInfo.value;
      final displayName = user?.name ?? 'User';
      final email = user?.email ?? '';
      final firstLetter =
          displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U';

      return SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: isMobile
              ? _mobileLayout(
                  displayName,
                  email,
                  firstLetter,
                  authController,
                  internetController
                )
              : Center(child: Text("Maintaince"),)
        ),
      );
    });
  }

  // ================= DESKTOP =================

  Widget _desktopLayout(
    String name,
    String email,
    String firstLetter,
    AuthController authController,
  ) {
    return Row(
      children: [
        const Spacer(),
        PopupMenuButton<int>(
          offset: const Offset(0, 50),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          itemBuilder: (context) => [
            PopupMenuItem(
              enabled: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(email,
                      style:
                          const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
            const PopupMenuDivider(),
            PopupMenuItem(
              onTap: () {
                authController.clearUser();
                Get.offAllNamed('/login');
              },
              child: const Row(
                children: [
                  Icon(Icons.logout, size: 18),
                  SizedBox(width: 8),
                  Text("Logout"),
                ],
              ),
            ),
          ],
          child: Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: Colors.blue,
                child: Text(
                  firstLetter,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 8),
              Text(name, style: const TextStyle(fontSize: 14)),
              const Icon(Icons.keyboard_arrow_down),
            ],
          ),
        ),
      ],
    );
  }

  // ================= MOBILE =================

  Widget _mobileLayout(
    String name,
    String email,
    String firstLetter,
    AuthController authController,
    InternetConnectionController internetController
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // const SizedBox(height: 10),
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Setting',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                 Obx((){
                    switch(internetController.status.value){
                      case InternetStatus.disconnected:
                      return Icon(Icons.wifi_off_outlined);
                      case InternetStatus.connected:
                      return SizedBox.shrink();
                      
                      case InternetStatus.initial:
                        // TODO: Handle this case.
                        return SizedBox.shrink();
                      case InternetStatus.loading:
                        // TODO: Handle this case.
                        return SizedBox.shrink();
                    }
                  }),
              ],
            ),
        // Avatar
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: Colors.blue,
                child: Text(
                  firstLetter,
                  style: const TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          
          SizedBox(width: 20,),
               // Name + Email
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                email,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          
            ],
          ),
        ),

        Divider(
          thickness: SizeConst.kDividerThickness,
        ),
        const SizedBox(height: 20),
        Spacer(),
        // Logout Button
        GestureDetector(
          onTap: () {
            authController.clearUser();
            Get.offAllNamed('/login');
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.logout, color: Colors.red),
                SizedBox(width: 8),
                Text(
                  "Logout",
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
