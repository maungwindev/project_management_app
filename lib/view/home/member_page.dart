import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pm_app/controller/connection_controller.dart';
import 'package:pm_app/controller/user_controller.dart';
import 'package:pm_app/core/utils/snackbar.dart';
import 'package:pm_app/models/response_models/user_model.dart';

class MemberPage extends StatelessWidget {
  const MemberPage({super.key});

  @override
  Widget build(BuildContext context) {
    final InternetConnectionController internetController = Get.find();
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Members'),
        actions: [
          Obx(() {
            switch (internetController.status.value) {
              case InternetStatus.disconnected:
                return Padding(
                  padding: const EdgeInsets.only(right: 30),
                  child: Icon(Icons.wifi_off_outlined),
                );
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
      floatingActionButton: FloatingActionButton(onPressed: ()=>_showAddMemberDialog(context),child: Icon(Icons.person_add_alt),),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 20,right: 20,top: 20,bottom: 10),
            child: CupertinoSearchTextField(
              placeholder: "Search members",
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Container(
                width: double.infinity,
                child: Column(
                  children: List.generate(50, (index){
                    return Text("index:$index");
                  }),
                ),
              ),
            ),
          )
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
          userController.resetCheckUser();
          Get.back();
        },
        onSuccess: (_) {
          userController.sendInvite(targetUser:userController.userInfoByCheckingMember.value!);
          // print("userId::${userController.userInfoByCheckingMember.toString()}");
        },
      ),
    );
  }
}



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
          child: TextFormField(
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
        ),
        actions: [
          TextButton(
            onPressed: widget.onCancel,
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: userController.checkUserStatus.value ==
                    CheckUserStatus.success
                ? () {
                    widget.onSuccess(userController.userInfoByCheckingMember);
                    Get.back();
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


enum CheckUserStatus {
  idle,
  loading,
  success,
  error,
}