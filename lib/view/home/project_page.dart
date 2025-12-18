import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pm_app/controller/project_controller.dart';
import 'package:pm_app/models/response_models/project_model.dart';

class ProjectScreen extends StatefulWidget {
  const ProjectScreen({super.key});

  @override
  State<ProjectScreen> createState() => _ProjectScreenState();
}

class _ProjectScreenState extends State<ProjectScreen> {
  final controller = Get.find<ProjectController>();

  Color _statusColor(ProjectStatus status) {
  switch (status) {
    case ProjectStatus.not_started: // "To Do"
      return const Color(0xFF64748B); // Slate Grey
    case ProjectStatus.ongoing:    // "In Progress"
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
  Widget build(BuildContext context) {
    return Column(
      children: [
        // New Project Button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: () => _showCreateDialog(context),
              child: const Text("New Project"),
            ),
          ),
        ),

        // Project Table
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Expanded(
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
                scrollDirection: Axis.vertical,
                child: Card(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                        minWidth: MediaQuery.of(context).size.width),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
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
                                  // Using .withOpacity() to get that soft pastel look from the image
                                  color: _statusColor(project.status)
                                      .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(
                                      8), // More rectangular like the image
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<ProjectStatus>(
                                    focusColor: Colors.transparent,
                                    value: project.status,
                                    // Re-enable and style the icon
                                    icon: Icon(
                                      Icons.keyboard_arrow_down,
                                      color: _statusColor(project.status),
                                      size: 18,
                                    ),
                                    isDense: true, // Makes the button compact
                                    dropdownColor: Colors.white,
                                    items: ProjectStatus.values.map((status) {
                                      return DropdownMenuItem<ProjectStatus>(
                                        value: status,
                                        child: Text(
                                          status.name,
                                          style: TextStyle(
                                            // Text color matches the primary status color
                                            color: _statusColor(status),
                                            fontWeight: FontWeight.w500,
                                            fontSize: 13,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      // print("value:${value}");
                                      if (value == null) return;
                                      // Logic remains the same
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
                ),
              );
            }),
          ),
        ),
      ],
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
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            SizedBox(height: 10,),
            TextField(
              controller: descController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () =>Get.back(),
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
                          Get.snackbar(
                              'Success', controller.successMessage.value,
                              snackPosition: SnackPosition.BOTTOM);
                        } else if (controller.errorMessage.isNotEmpty) {
                          Get.snackbar('Error', controller.errorMessage.value,
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: Colors.red,
                              colorText: Colors.white);
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
            SizedBox(height: 10,),
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
