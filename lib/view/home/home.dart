import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pm_app/controller/auth_controller.dart';
import 'package:pm_app/controller/product_controller.dart';
import 'package:pm_app/controller/user_controller.dart';
import 'package:pm_app/view/home/project_page.dart';
import 'package:pm_app/view/theme/swith_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  
  int selectedIndex = 0;

  final List<String> menuItems = [
    'Dashboard',
    'Projects',
    'Reports',
    'Settings',
  ];

  @override
  void initState() {
    super.initState();
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          SidebarWidget(
            menuItems: menuItems,
            selectedIndex: selectedIndex,
            onItemTap: (index) {
              setState(() {
                selectedIndex = index;
              });
            },
          ),

          // Main content
          Expanded(
            child: Column(
              children: [
                TopNavbar(),
                Expanded(
                  child: _buildMainContent(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    switch (selectedIndex) {
      case 0:
        return DashboardContent();
      case 1:
        return const ProjectScreen();
      case 2:
        return const SizedBox();
      case 3:
        return const SizedBox();
      default:
        return const SizedBox();
    }
  }
}

// Sidebar Widget
class SidebarWidget extends StatelessWidget {
  final List<String> menuItems;
  final int selectedIndex;
  final Function(int) onItemTap;

  const SidebarWidget({
    super.key,
    required this.menuItems,
    required this.selectedIndex,
    required this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    final List<IconData> iconData = [Icons.dashboard,Icons.folder,Icons.report,Icons.settings];
    return Container(
      width: 200,
      decoration: BoxDecoration(
         border: Border.all(color: Colors.grey.shade200),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("PM APP", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 30),
          ...List.generate(menuItems.length, (index) {
            final isActive = selectedIndex == index;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: InkWell(
                onTap: () => onItemTap(index),
                child: Row(
                  children: [
                    Icon(iconData[index], size: 20, color: isActive ? Colors.blue : Colors.grey),
                    const SizedBox(width: 12),
                    Text(
                      menuItems[index],
                      style: TextStyle(
                        color: isActive ? Colors.black : Colors.grey,
                        fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

// Top Navbar
class TopNavbar extends StatelessWidget {
  const TopNavbar({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<UserController>();
    final authController = Get.find<AuthController>();

    return Obx(() {
      final user = controller.currentUserInfo.value;
      final displayName = user?.name ?? 'User';
      final firstLetter = displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U';

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        margin: const EdgeInsets.only(left: 10),
        color: Colors.white,
        child: Row(
          children: [
            const Spacer(),

            // Profile circle with first letter
            PopupMenuButton<int>(
              offset: const Offset(0, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              itemBuilder: (context) => [
                PopupMenuItem(
                
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(displayName, style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(user?.email ?? '', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                PopupMenuItem(
                  onTap: () {
                    // Handle logout
                    authController.clearUser();
                   Get.offAllNamed('/login');
                  },
                  child: Row(
                    children: const [
                      Icon(Icons.logout, size: 18, color: Colors.black),
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
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(displayName, style: const TextStyle(fontSize: 14)),
                  const SizedBox(width: 4),
                  const Icon(Icons.keyboard_arrow_down),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}


// Dashboard Content (Grid Cards)
class DashboardContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Integration", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text(
            "Reconfigure your workflow and handle repetitive tasks with integration.",
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 400,
              mainAxisExtent: 200,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
            ),
            itemCount: 6,
            itemBuilder: (context, index) => const IntegrationCard(),
          ),
        ],
      ),
    );
  }
}

// Card Widget
class IntegrationCard extends StatelessWidget {
  const IntegrationCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Notion + Flows list", style: TextStyle(fontWeight: FontWeight.w600)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(8)),
                child: const Text("Activate", style: TextStyle(color: Colors.green, fontSize: 10)),
              )
            ],
          ),
          const Spacer(),
          const Row(
            children: [
              Icon(Icons.notes, size: 24),
              Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Icon(Icons.swap_horiz, color: Colors.grey)),
              Icon(Icons.grid_view_rounded, size: 24),
            ],
          ),
          const Spacer(),
          const Row(
            children: [
              CircleAvatar(radius: 12, backgroundColor: Colors.blueGrey),
              SizedBox(width: 8),
              Text("by Group", style: TextStyle(fontSize: 12, color: Colors.grey)),
              Spacer(),
              Icon(Icons.more_horiz, color: Colors.grey),
            ],
          )
        ],
      ),
    );
  }
}
