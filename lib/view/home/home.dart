import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:pm_app/controller/auth_controller.dart';
import 'package:pm_app/controller/connection_controller.dart';
import 'package:pm_app/controller/project_controller.dart';
import 'package:pm_app/controller/project_ui_controller.dart';
import 'package:pm_app/controller/task_controller.dart';
import 'package:pm_app/controller/user_controller.dart';
import 'package:pm_app/core/service/firebase_noiti_service.dart';
import 'package:pm_app/models/response_models/project_model.dart';
import 'package:pm_app/models/response_models/response_model.dart';
import 'package:pm_app/view/home/project_page.dart';
import 'package:pm_app/view/home/setting.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final uiController = Get.find<ProjectUIController>();
  final projectController = Get.find<ProjectController>();
  final taskController = Get.find<TaskController>();
  final FirebaseNotificationService notiService = Get.find();
  int selectedIndex = 0;
  late final DashboardContent dashboardContent;

  final List<String> menuItems = [
    'Dashboard',
    'Projects',
    'Reports',
    'Settings',
  ];

  late final pages;

  void _requestPermission() async {
    await notiService.init(FirebaseAuth.instance.currentUser!.uid);
  }

  @override
  void initState() {
    super.initState();
    _requestPermission();
    dashboardContent = DashboardContent(
      projectController: projectController,
      taskController: taskController,
    );
    pages = [
      dashboardContent,
      const ProjectScreen(),
      const SizedBox(
        child: Center(
          child: Text("Still Developing"),
        ),
      ),
      const SettingScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    return isMobile ? ResponsiveMobile() : ResponsiveWebAndLaptopView();
  }

  Widget ResponsiveWebAndLaptopView() {
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

  Widget ResponsiveMobile() {
    return Scaffold(
      body: pages[selectedIndex],
      floatingActionButton: selectedIndex == 1
          ? FloatingActionButton(
              onPressed: () {
                uiController.openCreate();
              },
              child: const Icon(Icons.add),
            )
          : SizedBox(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (index) {
          setState(() => selectedIndex = index);
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.folder),
            label: 'Projects',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.report),
            label: 'Reports',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_2_outlined),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    switch (selectedIndex) {
      case 0:
        return DashboardContent(
          projectController: projectController,
          taskController: taskController,
        );
      case 1:
        return const ProjectScreen();
      case 2:
        return const SizedBox();
      case 3:
        return const SettingScreen();
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
    final List<IconData> iconData = [
      Icons.dashboard,
      Icons.folder,
      Icons.report,
      Icons.settings
    ];
    return Container(
      width: 200,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("PM APP",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 30),
          ...List.generate(menuItems.length, (index) {
            final isActive = selectedIndex == index;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: InkWell(
                onTap: () => onItemTap(index),
                child: Row(
                  children: [
                    Icon(iconData[index],
                        size: 20, color: isActive ? Colors.blue : Colors.grey),
                    const SizedBox(width: 12),
                    Text(
                      menuItems[index],
                      style: TextStyle(
                        color: isActive ? Colors.black : Colors.grey,
                        fontWeight:
                            isActive ? FontWeight.bold : FontWeight.normal,
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
      final firstLetter =
          displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U';

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
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              itemBuilder: (context) => [
                PopupMenuItem(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(displayName,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(user?.email ?? '',
                          style: const TextStyle(
                              color: Colors.grey, fontSize: 12)),
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
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
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
class DashboardContent extends StatefulWidget {
  final ProjectController projectController;
  final TaskController taskController;

  const DashboardContent({
    super.key,
    required this.projectController,
    required this.taskController,
  });

  @override
  State<DashboardContent> createState() => _DashboardContentState();
}

class _DashboardContentState extends State<DashboardContent> {
  final InternetConnectionController internetController = Get.find();
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Initial load
      _loadTodayTasks();

      // Listen for changes in project list
      widget.projectController.projectList.listen((projects) {
        _loadTodayTasks();
      });
    });
  }

  void _loadTodayTasks() {
    final projects = widget.projectController.projectList;
    if (projects.isNotEmpty) {
      widget.taskController.loadTodayTasksFromProjects(projects);
    }
  }

  String getGreeting() {
    final hour = DateTime.now().hour;

    if (hour < 12) {
      return 'Good Morning ☀️';
    } else if (hour < 17) {
      return 'Good Afternoon 🌤️';
    } else {
      return 'Good Evening 🌙';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return isMobile ? _mobileView() : _webView();
  }

  Widget _mobileView() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 🔒 FIXED HEADER
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${getGreeting()}",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Spacer(),
                Obx(() {
                  switch (internetController.status.value) {
                    case InternetStatus.disconnected:
                      return const Icon(Icons.wifi_off_outlined);
                    case InternetStatus.connected:
                    case InternetStatus.initial:
                    case InternetStatus.loading:
                      return const SizedBox.shrink();
                  }
                }),
                GestureDetector(onTap:()=>throw Exception(),child: Icon(Icons.notifications_outlined)),
              ],
            ),
           
            const SizedBox(height: 16),

            /// 🔽 SCROLLABLE CONTENT
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Project Overview Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Project Overview",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),
                    const Text(
                      "Reconfigure your workflow and handle repetitive tasks with integration.",
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),

                    const SizedBox(height: 24),

                    /// Project Cards
                    Obx(() {
                      final projects = widget.projectController.projectList;

                      if (projects.isEmpty) {
                        return SizedBox(
                          height: 220,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'assets/images/empty_project.png',
                                  width: 100,
                                ),
                                const Text("No projects found"),
                              ],
                            ),
                          ),
                        );
                      }

                      return SizedBox(
                        height: 220,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: projects.length > 4 ? 4 : projects.length,
                          itemBuilder: (_, index) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 16),
                              child: SizedBox(
                                width: 250,
                                child: IntegrationCard(
                                  projectResponseModel: projects[index],
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    }),

                    const SizedBox(height: 24),

                    /// Today Tasks
                    const Text(
                      "Today Tasks",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),
                    const Text(
                      "Check for today tasks which is priority of your task.",
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),

                    const SizedBox(height: 24),

                    Obx(() {
                      if (widget.taskController.isDashboardLoading.value) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      final todayTasks = widget.taskController.todayTasks;

                      if (todayTasks.isEmpty) {
                        return SizedBox(
                          height: 220,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'assets/images/empty_task.png',
                                  width: 100,
                                  height: 80,
                                ),
                                const Text(
                                  "Good News! Today, you haven't tasks",
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: todayTasks.length,
                        itemBuilder: (_, index) {
                          return TaskIntegrationCard(
                            taskResponseModel: todayTasks[index],
                          );
                        },
                      );
                    }),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _webView() {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        const Text(
          "Dashboard - Web View",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),

        // For simplicity, just show project cards
        Obx(() {
          final projects = widget.projectController.projectList;
          if (projects.isEmpty) return const Text("No projects found");

          return Wrap(
            spacing: 16,
            runSpacing: 16,
            children: projects
                .map((project) => SizedBox(
                      width: 250,
                      child: IntegrationCard(projectResponseModel: project),
                    ))
                .toList(),
          );
        }),

        const SizedBox(height: 30),

        const Text(
          "Tasks Today",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        Obx(() {
          if (widget.taskController.isDashboardLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          final todayTasks = widget.taskController.todayTasks;
          if (todayTasks.isEmpty) return const Text("No tasks due today");

          return Column(
            children: todayTasks
                .map((task) => TaskIntegrationCard(taskResponseModel: task))
                .toList(),
          );
        }),
      ],
    );
  }
}

// Card Widget
class IntegrationCard extends StatelessWidget {
  final ProjectResponseModel projectResponseModel;
  const IntegrationCard({super.key, required this.projectResponseModel});

  Color _statusColor(ProjectStatus status) {
    switch (status) {
      case ProjectStatus.onhold: // "To Do"
        return const Color(0xFF64748B); // Slate Grey
      case ProjectStatus.ongoing: // "In Progress"
        return const Color(0xFF3B82F6); // Bright Blue
      case ProjectStatus.completed:
        return const Color(0xFF10B981); // Emerald Green
      default:
        return Colors.black;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Top Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: 100,
                child: Text(
                  projectResponseModel.title,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          /// Icons Row
          Row(
            children: [
              SizedBox(
                  width: 150,
                  child: Text(
                    projectResponseModel.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  )),
            ],
          ),

          const Spacer(),

          /// Bottom Row
          Row(
            children: [
              CircleAvatar(radius: 12, backgroundColor: Colors.blueGrey),
              SizedBox(width: 8),
              Text(
                "by ${projectResponseModel.ownerName}",
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusColor(projectResponseModel.status)
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "${projectResponseModel.status.value.toUpperCase()}",
                  style: TextStyle(
                      color: _statusColor(projectResponseModel.status),
                      fontSize: 10),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class TaskIntegrationCard extends StatelessWidget {
  final TaskResponseModel taskResponseModel;

  TaskIntegrationCard({
    super.key,
    required this.taskResponseModel,
  });

  Color _statusColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.todo: // "To Do"
        return const Color(0xFF64748B); // Slate Grey
      case TaskStatus.inProgress: // "In Progress"
        return const Color(0xFF3B82F6); // Bright Blue
      case TaskStatus.done:
        return const Color(0xFF10B981); // Emerald Green
      default:
        return Colors.black;
    }
  }

  Map<TaskPriority, Color> priorityBgColors = {
    TaskPriority.low: const Color(0xFFDFF7DF),
    TaskPriority.medium: const Color(0xFFFFF4E5),
    TaskPriority.high: const Color(0xFFFDE2E2),
  };

  Map<TaskPriority, Color> priorityTextColors = {
    TaskPriority.low: const Color(0xFF27AE60),
    TaskPriority.medium: const Color(0xFFF2994A),
    TaskPriority.high: const Color(0xFFEB5757),
  };

  Color getPriorityBg(TaskPriority priority) {
    return priorityBgColors[priority] ?? Colors.grey.shade200;
  }

  Color getPriorityTextColor(TaskPriority priority) {
    return priorityTextColors[priority] ?? Colors.black;
  }

  String _formatDate(DateTime date) {
    return "${date.day} / ${date.month} / ${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(taskResponseModel.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 🔹 Top Row (Status Badge)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: getPriorityBg(taskResponseModel.priority),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  taskResponseModel.priority.displayName,
                  style: TextStyle(
                    color: getPriorityTextColor(taskResponseModel.priority),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          /// 🔹 Title
          Text(
            taskResponseModel.title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 12),

          /// 🔹 Description
          Text(
            taskResponseModel.description,
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
              color: Colors.black87,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 20),
          // const Divider(height: 1),
          // const SizedBox(height: 15),

          /// 🔹 Bottom Row (Owner + Status)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              /// Owner
              Row(
                children: [
                  // const CircleAvatar(
                  //   radius: 14,
                  //   backgroundColor: Color(0xFF334155),
                  //   child: Icon(Icons.person, size: 16, color: Colors.white),
                  // ),
                  // const SizedBox(width: 8),
                  SizedBox(
                    // width: 110,
                    child: Text(
                      "Due Date: ${_formatDate(taskResponseModel.dueDate!)}",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),

              /// Status Badge (Right)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  taskResponseModel.status.value.toUpperCase(),
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
