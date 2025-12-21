// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:pm_app/controller/task_controller.dart';
// import 'package:pm_app/models/response_models/response_model.dart';

// class TaskScreen extends StatefulWidget {
//   const TaskScreen({super.key});

//   @override
//   State<TaskScreen> createState() => _TaskScreenState();
// }

// class _TaskScreenState extends State<TaskScreen> {
//   final TaskController controller = Get.find<TaskController>();
//   late final String projectId;
//   late final String ownerId;

//   @override
//   void initState() {
//     super.initState();
//     projectId = Get.arguments['projectId'];
//     ownerId = Get.arguments['ownerId'];
//     controller.subscribeTasks(projectId: projectId, ownerId: ownerId);
//     controller.subscribeUsers();
//   }

//   Color _statusColor(TaskStatus status) {
//     switch (status) {
//       case TaskStatus.todo:
//         return const Color(0xFF3B82F6); // Blue
//       case TaskStatus.inProgress:
//         return const Color.fromARGB(255, 255, 227, 70); // Yellow
//       case TaskStatus.done:
//         return const Color.fromARGB(255, 2, 154, 68); // Green
//       default:
//         return Colors.black;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isMobile = MediaQuery.of(context).size.width < 600;

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Tasks'),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: (){
//           Get.toNamed('/create-task',arguments: {
//             'projectId':projectId
//           });
//         // _showCreateTaskDialog(context);
//         },
//         child: Icon(Icons.add),
//       ),
//       body: Obx(() {
//         if (controller.isLoading.value) {
//           return const Center(child: CircularProgressIndicator());
//         }

//         if (controller.errorMessage.isNotEmpty) {
//           return Center(child: Text(controller.errorMessage.value));
//         }

//         if (controller.taskList.isEmpty) {
//           return const Center(child: Text('No tasks found'));
//         }

//         return isMobile
//             ? ListView.builder(
//                 itemCount: controller.taskList.length,
//                 itemBuilder: (_, index) {
//                   final task = controller.taskList[index];
//                   return _taskCard(task);
//                 },
//               )
//             : SingleChildScrollView(
//                 scrollDirection: Axis.horizontal,
//                 child: DataTable(
//                   columns: const [
//                     DataColumn(label: Text('Task Name')),
//                     DataColumn(label: Text('Description')),
//                     DataColumn(label: Text('Priority')),
//                     DataColumn(label: Text('Assignees')),
//                     DataColumn(label: Text('Due Date')),
//                     DataColumn(label: Text("Status")),
//                     DataColumn(label: Text('Actions')),
//                   ],
//                   rows: controller.taskList.map((task) {
//                     return DataRow(
//                       cells: [
//                         DataCell(Text(task.title)),
//                         DataCell(Text(task.description)),
//                         DataCell(Text(task.priority.name)),
//                         DataCell(assigneeRow(task)),
//                         DataCell(Text("${task.dueDate}")),
//                         DataCell(Container(
//                           padding: const EdgeInsets.symmetric(
//                               horizontal: 12, vertical: 4),
//                           decoration: BoxDecoration(
//                             color: _statusColor(task.status).withOpacity(0.1),
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                           child: DropdownButtonHideUnderline(
//                             child: DropdownButton<TaskStatus>(
//                               focusColor: Colors.transparent,
//                               value: task.status,
//                               icon: Icon(
//                                 Icons.keyboard_arrow_down,
//                                 color: _statusColor(task.status),
//                                 size: 18,
//                               ),
//                               isDense: true,
//                               dropdownColor: Colors.white,
//                               items: TaskStatus.values.map((status) {
//                                 return DropdownMenuItem<TaskStatus>(
//                                   value: status,
//                                   child: Text(
//                                     status.name,
//                                     style: TextStyle(
//                                       color: _statusColor(status),
//                                       fontWeight: FontWeight.w500,
//                                       fontSize: 13,
//                                     ),
//                                   ),
//                                 );
//                               }).toList(),
//                               onChanged: (value) {
//                                 if (value == null) return;
//                                 task.status = value;
//                                 controller.updateTaskStatus(
//                                   taskId: task.id,
//                                   status: task.status.toString(),
//                                   projectId: projectId,
//                                 );
//                               },
//                             ),
//                           ),
//                         )),
//                         DataCell(Row(
//                           children: [
//                             IconButton(
//                               icon: const Icon(Icons.edit),
//                               onPressed: () =>
//                                   _showEditTaskDialog(context, task),
//                             ),
//                             IconButton(
//                               icon: const Icon(Icons.delete, color: Colors.red),
//                               onPressed: () {
//                                 controller.deleteTask(
//                                   projectId: projectId,
//                                   taskId: task.id,
//                                 );
//                               },
//                             ),
//                           ],
//                         )),
//                       ],
//                     );
//                   }).toList(),
//                 ),
//               );
//       }),
//     );
//   }

//   // ---------------- MOBILE CARD ----------------
//   Widget _taskCard(TaskResponseModel task) {
//     return Card(
//       margin: const EdgeInsets.all(10),
//       child: Padding(
//         padding: const EdgeInsets.all(12),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(task.title,
//                 style:
//                     const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//             const SizedBox(height: 4),
//             Text(task.description),
//             const SizedBox(height: 4),
//             Text('Priority: ${task.priority}'),
//             const SizedBox(height: 6),
//             assigneeRow(task),
//             const SizedBox(height: 6),
//             Text('Due: ${task.dueDate}'),
//             const SizedBox(height: 6),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.end,
//               children: [
//                 IconButton(
//                   icon: const Icon(Icons.edit),
//                   onPressed: () => _showEditTaskDialog(context, task),
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.delete, color: Colors.red),
//                   onPressed: () {
//                     controller.deleteTask(
//                       projectId: projectId,
//                       taskId: task.id,
//                     );
//                   },
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ---------------- ASSIGNEE ROW ----------------
//   Widget assigneeRow(TaskResponseModel task) {


//       return SingleChildScrollView(
//         scrollDirection: Axis.horizontal,
//         child: Row(
//           children: [
//             ...task.assignees.map((userId) => Padding(
//                   padding: const EdgeInsets.only(right: 4),
//                   child: Container(
//                     padding:
//                         const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                     decoration: BoxDecoration(
//                       color: Colors.grey[200],
//                       borderRadius: BorderRadius.circular(16),
//                       border: Border.all(color: Colors.grey),
//                     ),
//                     child: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Text(userId, style: const TextStyle(fontSize: 14)),
//                         const SizedBox(width: 4),
//                         GestureDetector(
//                           onTap: () {
//                             controller.removeAssignee(
//                               projectId: projectId,
//                               taskId: task.id,
//                               userId: userId,
//                             );
//                           },
//                           child: const Icon(Icons.cancel,
//                               size: 18, color: Colors.black54),
//                         ),
//                       ],
//                     ),
//                   ),
//                 )),
//             GestureDetector(
//               onTap: () => _showAddAssigneeDialog(context, task.id),
//               child: CircleAvatar(
//                 radius: 16,
//                 backgroundColor: Colors.blue,
//                 child: const Icon(Icons.add, color: Colors.white, size: 20),
//               ),
//             ),
//           ],
//         ),
//       );
    
//   }

//   // ---------------- CREATE TASK ----------------
//   void _showCreateTaskDialog(BuildContext context) {
//     final titleCtrl = TextEditingController();
//     final descCtrl = TextEditingController();
//     final selectedPriority = RxString('Low');
//     final selectedDueDate = Rx<DateTime>(DateTime.now());

//     showDialog(
//       context: context,
//       builder: (_) => Obx(() => AlertDialog(
//             title: const Text('Create Task'),
//             content: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 TextField(
//                   controller: titleCtrl,
//                   decoration: const InputDecoration(labelText: 'Title'),
//                 ),
//                 const SizedBox(height: 10),
//                 TextField(
//                   controller: descCtrl,
//                   decoration: const InputDecoration(labelText: 'Description'),
//                 ),
//                 const SizedBox(height: 10),
//                 DropdownButtonFormField<String>(
//                   value: selectedPriority.value,
//                   decoration: const InputDecoration(labelText: 'Priority'),
//                   items: const [
//                     DropdownMenuItem(value: 'Low', child: Text('Low')),
//                     DropdownMenuItem(value: 'Medium', child: Text('Medium')),
//                     DropdownMenuItem(value: 'High', child: Text('High')),
//                   ],
//                   onChanged: (val) {
//                     if (val != null) selectedPriority.value = val;
//                   },
//                 ),
//                 const SizedBox(height: 10),
//                 InkWell(
//                   onTap: () async {
//                     final picked = await showDatePicker(
//                       context: context,
//                       initialDate: selectedDueDate.value,
//                       firstDate: DateTime.now(),
//                       lastDate: DateTime(2100),
//                     );
//                     if (picked != null) selectedDueDate.value = picked;
//                   },
//                   child: InputDecorator(
//                     decoration: const InputDecoration(labelText: 'Due Date'),
//                     child: Text(
//                         '${selectedDueDate.value.day}/${selectedDueDate.value.month}/${selectedDueDate.value.year}'),
//                   ),
//                 ),
//               ],
//             ),
//             actions: [
//               TextButton(
//                   onPressed: () => Get.back(), child: const Text('Cancel')),
//               ElevatedButton(
//                 onPressed: controller.isCreating.value
//                     ? null
//                     : () async {
//                         await controller.createTask(
//                           projectId: projectId,
//                           title: titleCtrl.text,
//                           description: descCtrl.text,
//                           status: 'todo',
//                           priority: selectedPriority.value,
//                           assignees: [],
//                           dueDate: selectedDueDate.value,
//                         );
//                         Get.back();
//                       },
//                 child: controller.isCreating.value
//                     ? const CircularProgressIndicator()
//                     : const Text('Create'),
//               ),
//             ],
//           )),
//     );
//   }

//   // ---------------- EDIT TASK ----------------
//   void _showEditTaskDialog(BuildContext context, TaskResponseModel task) {
//     final titleCtrl = TextEditingController(text: task.title);
//     final descCtrl = TextEditingController(text: task.description);

//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: const Text('Edit Task'),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             TextField(controller: titleCtrl),
//             TextField(controller: descCtrl),
//           ],
//         ),
//         actions: [
//           TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
//           ElevatedButton(
//             onPressed: () async {
//               await controller.updateTask(
//                 projectId: projectId,
//                 taskId: task.id,
//                 data: {
//                   'title': titleCtrl.text,
//                   'description': descCtrl.text,
//                 },
//               );
//               Get.back();
//             },
//             child: const Text('Save'),
//           ),
//         ],
//       ),
//     );
//   }

//   // ---------------- ADD ASSIGNEE ----------------
//   void _showAddAssigneeDialog(
//     BuildContext context,
//     String taskId, {
//     List<String> initialAssignees = const [],
//   }) {
//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: const Text('Select Assignees'),
//         content: Obx(() {
//           if (controller.allUsers.isEmpty) {
//             return const Center(child: Text('No users found'));
//           }

//           return SizedBox(
//             width: double.maxFinite,
//             child: ListView(
//               shrinkWrap: true,
//               children: controller.allUsers.map((user) {
//                 final isSelected =
//                     controller.selectedAssignees.contains(user.id);

//                 return CheckboxListTile(
//                   value: isSelected,
//                   title: Text(user.name),
//                   onChanged: (val) {
//                     if (val == true) {
//                       controller.selectedAssignees.add(user.id);
//                     } else {
//                       controller.selectedAssignees.remove(user.id);
//                     }
//                   },
//                 );
//               }).toList(),
//             ),
//           );
//         }),
//         actions: [
//           TextButton(
//             onPressed: () => Get.back(),
//             child: const Text('Cancel'),
//           ),
//           ElevatedButton(
//             onPressed: () async {
//               for (final userId in controller.selectedAssignees) {
//                 await controller.addAssignee(
//                   projectId: projectId,
//                   taskId: taskId,
//                   userId: userId,
//                 );
//               }
//               Get.back();
//             },
//             child: const Text('Assign'),
//           ),
//         ],
//       ),
//     );
//   }
// }
