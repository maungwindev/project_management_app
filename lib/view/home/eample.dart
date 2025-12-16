import 'package:flutter/material.dart';

class TwoColumnDashboard extends StatefulWidget {
  const TwoColumnDashboard({super.key});

  @override
  State<TwoColumnDashboard> createState() => _TwoColumnDashboardState();
}

class _TwoColumnDashboardState extends State<TwoColumnDashboard> {
  int selectedIndex = 0;

  final List<String> menuItems = [
    'Dashboard',
    'Users',
    'Reports',
    'Settings',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // LEFT SIDE (TABS / MENU)
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
                            color: isSelected
                                ? Colors.blue
                                : Colors.grey,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            menuItems[index],
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : Colors.grey,
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

          // RIGHT SIDE (CHANGING UI)
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
        return const UsersScreen();
      case 2:
        return const ReportsScreen();
      case 3:
        return const SettingsScreen();
      default:
        return const SizedBox();
    }
  }
}

// ---------------- RIGHT SIDE SCREENS ----------------

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Map<String, String>> projects = [
    {
      'id': '1',
      'title': 'Mobile App',
      'description': 'Flutter dashboard app',
      'status': 'Not started',
    },
    {
      'id': '2',
      'title': 'Backend API',
      'description': 'REST API with auth',
      'status': 'On going',
    },
    {
      'id': '3',
      'title': 'Admin Panel',
      'description': 'Web dashboard UI',
      'status': 'Completed',
    },
  ];

  final List<String> statusList = [
    'Not started',
    'On going',
    'Completed',
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Project List',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Card(
              elevation: 1,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('ID')),
                    DataColumn(label: Text('Title')),
                    DataColumn(label: Text('Description')),
                    DataColumn(label: Text('Status')),
                    DataColumn(label: Text('Actions')),
                  ],
                  rows: projects.map((project) {
                    return DataRow(
                      cells: [
                        DataCell(Text(project['id']!)),
                        DataCell(Text(project['title']!)),
                        DataCell(Text(project['description']!)),
                        DataCell(
                          DropdownButton<String>(
                            value: project['status'],
                            underline: const SizedBox(),
                            items: statusList
                                .map(
                                  (status) => DropdownMenuItem<String>(
                                    value: status,
                                    child: Text(status),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                project['status'] = value!;
                              });
                            },
                          ),
                        ),
                        DataCell(
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, size: 20),
                                onPressed: () {
                                  _editProject(project);
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, size: 20),
                                onPressed: () {
                                  setState(() {
                                    projects.remove(project);
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _editProject(Map<String, String> project) {
    showDialog(
      context: context,
      builder: (_) {
        final titleController =
            TextEditingController(text: project['title']);
        final descController =
            TextEditingController(text: project['description']);

        return AlertDialog(
          title: const Text('Edit Project'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: descController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  project['title'] = titleController.text;
                  project['description'] = descController.text;
                });
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}

class UsersScreen extends StatelessWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Users Screen', style: TextStyle(fontSize: 24)),
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
