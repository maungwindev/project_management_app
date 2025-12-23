import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pm_app/controller/project_controller.dart';
import 'package:pm_app/controller/project_ui_controller.dart';
import 'package:pm_app/core/component/custom_Inputdecoration.dart';
import 'package:pm_app/core/utils/snackbar.dart';
import 'package:pm_app/models/response_models/project_model.dart';
import 'package:pm_app/view/home/project_card.dart';
import 'package:responsive_builder/responsive_builder.dart';

class ProjectScreen extends StatefulWidget {
  const ProjectScreen({super.key});

  @override
  State<ProjectScreen> createState() => _ProjectScreenState();
}

class _ProjectScreenState extends State<ProjectScreen> {
  final controller = Get.find<ProjectController>();
  late final ProjectUIController uiController;
  late Worker _createDialogWorker;

  Color _statusColor(ProjectStatus status) {
    switch (status) {
      case ProjectStatus.onhold:
        return const Color(0xFF64748B); // Slate Grey
      case ProjectStatus.ongoing:
        return const Color(0xFF3B82F6); // Bright Blue
      case ProjectStatus.completed:
        return const Color(0xFF10B981); // Emerald Green
      case ProjectStatus.archived:
        return const Color(0xFF6366F1); // Indigo
      default:
        return Colors.black;
    }
  }

  @override
  void initState() {
    super.initState();
    uiController = Get.find<ProjectUIController>();

    // Listen to openCreateDialog flag
    _createDialogWorker = ever(uiController.openCreateDialog, (value) {
      if (value == true) {
        _showCreateDialog(context);
        uiController.reset();
      }
    });
  }

  @override
  void dispose() {
    _createDialogWorker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenTypeLayout.builder(
      mobile: (context) => _mobileResponsive(),
      desktop: (context) => _webResponsive(),
    );
  }

  // ------------------ WEB ------------------
  Widget _webResponsive() {
    return Column(
      children: [
        // New Project Button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: () {
                Get.find<ProjectUIController>().openCreate();
              },
              child: const Text("New Project"),
            ),
          ),
        ),

        // Project Table
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.errorMessage.isNotEmpty) {
                return Center(
                  child: Text(
                    controller.errorMessage.value,
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              }

              if (controller.projectList.isEmpty) {
                return const Center(child: Text('No projects found'));
              }

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Card(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                        minWidth: MediaQuery.of(context).size.width),
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Title')),
                        DataColumn(label: Text('Description')),
                        DataColumn(label: Text('Status')),
                        DataColumn(label: Text('Created By')),
                        DataColumn(label: Text('Members')),
                        DataColumn(label: Text('Actions')),
                      ],
                      rows: controller.projectList.map((project) {
                        return DataRow(
                          cells: [
                            DataCell(TextButton(
                              child: Text(project.title),
                              onPressed: () {
                                Get.toNamed(
                                  '/tasks',
                                  arguments: {
                                    'projectId': project.id,
                                    'ownerId': project.ownerId
                                  },
                                );
                              },
                            )),
                            DataCell(Text(project.description)),
                            DataCell(Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: _statusColor(project.status)
                                    .withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<ProjectStatus>(
                                  value: project.status,
                                  icon: Icon(
                                    Icons.keyboard_arrow_down,
                                    color: _statusColor(project.status),
                                  ),
                                  items: ProjectStatus.values.map((status) {
                                    return DropdownMenuItem<ProjectStatus>(
                                      value: status,
                                      child: Text(
                                        status.name.toUpperCase(),
                                        style: TextStyle(
                                          color: _statusColor(status),
                                          fontWeight: FontWeight.w500,
                                          fontSize: 13,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    if (value == null) return;
                                    project.status = value;
                                    controller.updatedProjectStatus(
                                      status: project.status.toString(),
                                      projectId: project.id,
                                    );
                                  },
                                ),
                              ),
                            )),
                            DataCell(Text(project.description)),
                            DataCell(Text(project.members.length.toString())),
                            DataCell(Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, size: 20),
                                  onPressed: () =>
                                      _showEditDialog(context, project),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, size: 20),
                                  onPressed: () {
                                    // TODO: Delete project
                                  },
                                ),
                              ],
                            )),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  // ------------------ MOBILE ------------------
  Widget _mobileResponsive() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            // Header
            const Text(
              'My Projects',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 25),

            // Filter Tabs
            Obx(() {
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterTab("All"),
                    _buildFilterTab("Ongoing"),
                    _buildFilterTab("Completed"),
                    _buildFilterTab("On Hold"),
                  ],
                ),
              );
            }),
            const SizedBox(height: 25),

            // Projects List
            Expanded(
              child: Obx(() {
                final filter = uiController.selectedFilter.value;
                final filteredList = controller.projectList.where((project) {
                  switch (filter) {
                    case 'All':
                      return true;
                    case 'Ongoing':
                      return project.status == ProjectStatus.ongoing;
                    case 'Completed':
                      return project.status == ProjectStatus.completed;
                    case 'On Hold':
                      return project.status == ProjectStatus.onhold;
                    default:
                      return true;
                  }
                }).toList();

                if (filteredList.isEmpty) {
                  return const Center(child: Text('No projects found'));
                }

                return ListView(
                  physics: const BouncingScrollPhysics(),
                  children: filteredList.map((project) {
                    return GestureDetector(
                      onTap: () {
                        Get.toNamed(
                          '/tasks',
                          arguments: {
                            'projectId': project.id,
                            'ownerId': project.ownerId
                          },
                        );
                      },
                      child: ProjectCard(
                        projectModel: project,
                        priority: "HIGH PRIORITY",
                        priorityBg: const Color(0xFF451A1A),
                        priorityText: const Color(0xFFF87171),
                        title: project.title,
                        description: project.description,
                        status: project.status.name.toUpperCase(),
                        statusColor: Colors.blue,
                        avatarCount: project.members.length,
                      ),
                    );
                  }).toList(),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterTab(String label) {
    final isActive = uiController.selectedFilter.value == label;
    return GestureDetector(
      onTap: () => uiController.selectFilter(label),
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF3B82F6) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: isActive
              ? Border.all(color: Colors.transparent)
              : Border.all(color: Colors.blue.shade200),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.black,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  // ------------------ CREATE PROJECT ------------------
  void _showCreateDialog(BuildContext context) {
    final titleController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Create Project"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration:  buildInputDecoration(hintText: 'Title',isPrefix: false),
            ),
            const SizedBox(height: 10),
            Container(
                      height: 150,
                      // decoration: BoxDecoration(
                      //   border: Border.all(color: Colors.grey),
                      //   borderRadius: BorderRadius.circular(12),
                      // ),
                      child: TextField(
                        controller: descController,
                        maxLines: null,
                        expands: true,
                        textAlignVertical: TextAlignVertical.top,
                        decoration: buildInputDecoration(
                          hintText: 'Add details...',
                          isPrefix: false,
                        ),
                      ),
                    ),
            
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          Obx(() => ElevatedButton(
                onPressed: controller.isCreating.value
                    ? null
                    : () async {
                        await controller.createProject(
                          title: titleController.text,
                          description: descController.text,
                        );
                        Get.back();

                        if (controller.successMessage.isNotEmpty) {
                          showMaterialSnackBar(context, controller.successMessage.value);
                          // Get.snackbar('Success', controller.successMessage.value,
                          //     snackPosition: SnackPosition.BOTTOM);
                        } else if (controller.errorMessage.isNotEmpty) {
                          showMaterialSnackBar(context, controller.errorMessage.value);
                          // Get.snackbar('Error', controller.errorMessage.value,
                          //     snackPosition: SnackPosition.BOTTOM,
                          //     backgroundColor: Colors.red,
                          //     colorText: Colors.white);
                        }
                      },
                child: controller.isCreating.value
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text("Create"),
              )),
        ],
      ),
    );
  }

  // ------------------ EDIT PROJECT ------------------
  void _showEditDialog(BuildContext context, ProjectResponseModel project) {
    final titleController = TextEditingController(text: project.title);
    final descController = TextEditingController(text: project.description);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit Project"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: descController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              project.title = titleController.text;
              project.description = descController.text;
              controller.update();

              Get.back();

              Get.snackbar(
                'Success',
                'Project updated',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }
}
