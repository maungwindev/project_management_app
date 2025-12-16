import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pm_app/controller/product_controller.dart';
import 'package:pm_app/core/component/custom_error_widget.dart';
import 'package:pm_app/core/utils/context_extension.dart';
import 'package:pm_app/models/response_models/product_model.dart';
import 'package:pm_app/view/home/project_page.dart';
import 'package:pm_app/view/theme/swith_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ProductsController productsController = Get.find();

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
    // Load products on first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      productsController.getAllProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "PM APP",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: PopupMenuButton<String>(
              offset: const Offset(0, 45),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              onSelected: (value) {
                switch (value) {
                  case 'profile':
                    // Navigate to profile
                    break;
                  case 'theme':
                    // Toggle theme
                    break;
                  case 'logout':
                    // Logout logic
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'profile',
                  child: Row(
                    children: [
                      Icon(Icons.person_outline, size: 18),
                      SizedBox(width: 10),
                      Text('Profile'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'theme',
                  child: ThemeSwitch(),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout, size: 18),
                      SizedBox(width: 10),
                      Text('Logout'),
                    ],
                  ),
                ),
              ],
              child: Row(
                children: const [
                  CircleAvatar(
                    radius: 16,
                    child: Icon(Icons.person, size: 18),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'John Doe',
                    style: TextStyle(fontSize: 14),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.keyboard_arrow_down),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Row(
        children: [
          // Left Side UI

          Container(
            width: 220,
            color: Colors.grey.shade900,
            child: Column(
              children: [
                const SizedBox(height: 40),
                ...List.generate(menuItems.length, (index) {
                  final isSelected = selectedIndex == index;
                  return InkWell(
                    onTap: () {
                      setState(() {
                        selectedIndex = index;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      color: isSelected
                          ? Colors.blue.withOpacity(0.2)
                          : Colors.transparent,
                      child: Row(
                        children: [
                          Icon(
                            Icons.circle,
                            size: 10,
                            color: isSelected ? Colors.blue : Colors.grey,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            menuItems[index],
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.grey,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),

          // Right Side UI
          Expanded(
            child: Container(
              color: Colors.grey.shade100,
              child: _buildRightContent(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRightContent() {
    switch (selectedIndex) {
      case 0:
        return const DashboardScreen();
      case 1:
        return const ProjectScreen();
      case 2:
        return const ReportsScreen();
      case 3:
        return const SettingsScreen();
      default:
        return const SizedBox();
    }
  }

  int _getCrossAxisCount(double screenWidth) {
    if (screenWidth > 1600) return 6;
    if (screenWidth > 1200) return 5;
    if (screenWidth > 900) return 4;
    if (screenWidth > 600) return 3;
    return 2;
  }

  double _getHorizontalPadding(double screenWidth) {
    if (screenWidth > 1600) return 200;
    if (screenWidth > 1200) return 100;
    if (screenWidth > 900) return 60;
    if (screenWidth > 600) return 30;
    return 16;
  }

  double _getAspectRatio(double screenWidth) {
    if (screenWidth > 1600) return 0.85;
    if (screenWidth > 1200) return 0.8;
    if (screenWidth > 900) return 0.75;
    if (screenWidth > 600) return 0.7;
    return 0.65;
  }

  EdgeInsets _getCardPadding(double screenWidth) {
    if (screenWidth > 1600) return const EdgeInsets.all(20);
    if (screenWidth > 1200) return const EdgeInsets.all(16);
    if (screenWidth > 900) return const EdgeInsets.all(14);
    if (screenWidth > 600) return const EdgeInsets.all(12);
    return const EdgeInsets.all(10);
  }
}

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: GridView.count(
        crossAxisCount: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        children: List.generate(6, (index) {
          return Card(
            elevation: 2,
            child: Center(
              child: Text(
                'Card ${index + 1}',
                style: const TextStyle(fontSize: 18),
              ),
            ),
          );
        }),
      ),
    );
  }
}



class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Reports Screen', style: TextStyle(fontSize: 24)),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Settings Screen', style: TextStyle(fontSize: 24)),
    );
  }
}
