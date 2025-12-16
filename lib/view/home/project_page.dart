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
        Expanded(
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
                        DataColumn(label: Text('ID')),
                        DataColumn(label: Text('Title')),
                        DataColumn(label: Text('Description')),
                        DataColumn(label: Text('Status')),
                        DataColumn(label: Text('Actions')),
                      ],
                      rows: controller.projectList.map((project) {
                        return DataRow(
                          cells: [
                            DataCell(TextButton(
                              child: Text(project.id),
                              onPressed: () {
                                Get.toNamed(
                                  '/tasks',
                                  arguments: {'projectId': project.id},
                                );
                              },
                            )),
                            DataCell(Text(project.title)),
                            DataCell(Text(project.description)),
                            DataCell(
                              DropdownButton<ProjectStatus>(
                                value: project.status,
                                underline: const SizedBox(),
                                items: ProjectStatus.values.map((status) {
                                  return DropdownMenuItem(
                                    value: status,
                                    child: Text(status.name),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  if (value == null) return;
                                  project.status = value;
                                  controller.updatedProjectStatus(
                                      status: project.status.toString(),
                                      projectId: project.id);
                                  // TODO: Call update project in repo
                                },
                              ),
                            ),
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
          Obx(() => ElevatedButton(
                onPressed: controller.isCreating.value
                    ? null
                    : () async {
                        await controller.createProject(
                          title: titleController.text,
                          description: descController.text,
                        );

                        Navigator.pop(context);

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
            onPressed: () async {
              project.title = titleController.text;
              project.description = descController.text;
              controller.update();

              Navigator.pop(context);

              Get.snackbar(
                'Success',
                'Project updated',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }
}
