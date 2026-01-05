import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pm_app/controller/connection_controller.dart';
import 'package:pm_app/controller/task_controller.dart';
import 'package:pm_app/controller/user_controller.dart';
import 'package:pm_app/core/utils/snackbar.dart';
import 'package:pm_app/models/response_models/user_model.dart';

class MemberPage extends StatelessWidget {
  const MemberPage({super.key});

  @override
  Widget build(BuildContext context) {
    final InternetConnectionController internetController = Get.find();
    final UserController userController = Get.find();
    final TaskController taskController = Get.find();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Members'),
        actions: [
          Obx(() {
            switch (internetController.status.value) {
              case InternetStatus.disconnected:
                return const Padding(
                  padding: EdgeInsets.only(right: 30),
                  child: Icon(Icons.wifi_off_outlined),
                );
              case InternetStatus.connected:
              case InternetStatus.initial:
              case InternetStatus.loading:
                return const SizedBox.shrink();
            }
          }),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddMemberDialog(context),
        child: const Icon(Icons.person_add_alt),
      ),
      body: Column(
        children: [
          Padding(
            padding:
                const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 10),
            child: CupertinoSearchTextField(
              placeholder: "Search members",
            ),
          ),

          // ================= NEW: Show pending invites =================
          Obx(() {
            final invites = userController.pendingInvites;
            if (invites.isEmpty) return const SizedBox.shrink();

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Pending Invitations',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Column(
                    children: List.generate(invites.length, (index) {
                      final invite = invites[index];
                      final InvitedByName = invite['invitedByName'];
                      final pairKey = invite['pairKey'];

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          title: Text(
                            '$InvitedByName',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600),
                          ), // Ideally fetch user name
                          subtitle: Text('Status: ${invite['status']}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.check,
                                    color: Colors.green),
                                onPressed: () {
                                  userController.respondToInvite(
                                      pairKey: pairKey, accept: true);
                                  taskController.subscribeUsers();
                                },
                              ),
                              IconButton(
                                icon:
                                    const Icon(Icons.close, color: Colors.red),
                                onPressed: () {
                                  userController.respondToInvite(
                                      pairKey: pairKey, accept: false);
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            );
          }),
          Expanded(
            child: Obx(() {
              final users = taskController.allUsers;

              if (users.isEmpty) {
                return const Center(
                  child: Text("No members yet"),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: users.length,
                itemBuilder: (_, index) {
                  final user = users[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      title: Text(user.name),
                      subtitle: Text(user.email),
                      trailing: const Icon(Icons.person),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  void _showAddMemberDialog(BuildContext context) {
    final userController = Get.find<UserController>();
    userController.resetCheckUser();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AddMemberDialog(
        onCancel: () {
           Get.back();
          userController.resetCheckUser();
          userController.sameUserEmail.value = '';
         
        },
        onSuccess: (_) {
          userController.sendInvite(
              targetUser: userController.userInfoByCheckingMember.value!);
        },
      ),
    );
  }
}

// ================= AddMemberDialog =================
class AddMemberDialog extends StatefulWidget {
  final VoidCallback onCancel;
  final ValueChanged<dynamic> onSuccess;

  const AddMemberDialog({
    super.key,
    required this.onCancel,
    required this.onSuccess,
  });

  @override
  State<AddMemberDialog> createState() => _AddMemberDialogState();
}

class _AddMemberDialogState extends State<AddMemberDialog> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final UserController userController = Get.find();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return AlertDialog(
        title: const Text('Add New Member'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _controller,
                focusNode: _focusNode,
                decoration: InputDecoration(
                  labelText: 'Member Email',
                  border: const OutlineInputBorder(),
                  suffixIcon: _buildSuffixIcon(),
                ),
                onChanged: (_) {
                  userController.resetCheckUser();
                },
                onFieldSubmitted: (_) {
                  userController.checkUser(email: _controller.text);
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Email required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 5,),
              if(userController.sameUserEmail.value.isNotEmpty)
              Text("** ${userController.sameUserEmail}",style: TextStyle(fontSize: 14,color: Colors.red),)
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: widget.onCancel,
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: userController.checkUserStatus.value ==
                    CheckUserStatus.success
                ? () async {
                   Get.back();
                    widget.onSuccess(userController.userInfoByCheckingMember);

                    // await Future.delayed(const Duration(milliseconds: 300));
                    // if (Get.isDialogOpen == true) {
                    //   Get.back();
                    // }
                  }
                : null,
            child: const Text('Send Invite'),
          ),
        ],
      );
    });
  }

  Widget? _buildSuffixIcon() {
    switch (userController.checkUserStatus.value) {
      case CheckUserStatus.loading:
        return const Padding(
          padding: EdgeInsets.all(8),
          child: SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        );
      case CheckUserStatus.success:
        return const Icon(Icons.check_circle, color: Colors.green);
      case CheckUserStatus.error:
        return const Icon(Icons.cancel, color: Colors.red);
      case CheckUserStatus.idle:
      default:
        return null;
    }
  }
}
