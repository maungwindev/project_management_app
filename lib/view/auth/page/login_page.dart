import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pm_app/controller/auth_controller.dart';
import 'package:pm_app/core/component/custom_Inputdecoration.dart';
import 'package:pm_app/core/component/loading_widget.dart';
import 'package:pm_app/core/utils/snackbar.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthController authController = Get.find<AuthController>();

  bool isLoading = false;

  bool isObscured = true;

  // Color Palette from the image
  final Color _backgroundColor = const Color(0xFF12171D);
  final Color _inputBorderColor = const Color(0xFF2D3440);
  final Color _textGrey = const Color(0xFF8F9BB3);

  // Example login function
  void login(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      final success = await authController.login(
        requestBody: {
          'email': emailController.text,
          'password': passwordController.text,
        },
      );

      if (success) {
        Get.offAllNamed('/home');

        showMaterialSnackBar(context,'Login successful');

        // Future.delayed(const Duration(milliseconds: 300), () {
        //   Get.snackbar(
        //     'Success',
        //     'Login successful',
        //     snackPosition: SnackPosition.BOTTOM,
        //     margin: const EdgeInsets.all(16),
        //   );
        // });
      } else {
          showMaterialSnackBar(context,authController.errorValue.value);
        // WidgetsBinding.instance.addPostFrameCallback((_){
        //   Get.snackbar(
        //   'Login Failed',
        //   authController.errorValue.value,
        //   snackPosition: SnackPosition.BOTTOM,
        //   margin: const EdgeInsets.all(16),
        // );
        // });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title
                  Text(
                    'Log in to your account ',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Subtitle
                  Text(
                    'Manage better. Log in to your workspace.',
                    style: TextStyle(
                      color: _textGrey,
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 18),
                  buildLabel('Email '),
                  const SizedBox(height: 8),
                  // Email TextFormField
                  TextFormField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: buildInputDecoration(
                        hintText: "Enter your work email address",
                        prefixIcon: Icons.mail),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      final emailRegex = RegExp(
                          r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$');
                      if (!emailRegex.hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 18),
                  buildLabel('Password'),
                  const SizedBox(height: 8),
                  // Password TextFormField
                  TextFormField(
                    controller: passwordController,
                    obscureText: isObscured,
                    decoration: buildInputDecoration(
                        hintText: "Enter Your Password",
                        prefixIcon: Icons.lock,
                        suffixIcon: GestureDetector(
                          onTap: () {
                            setState(() {
                              isObscured = !isObscured;
                            });
                          },
                          child: isObscured
                              ? Icon(Icons.visibility_off)
                              : Icon(Icons.visibility),
                        )),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 18),
                  // Obx(() {
                  //   return SizedBox(
                  //     width: double.infinity,
                  //     height: 50,
                  //     child: ElevatedButton(
                  //       onPressed:
                  //           authController.isLoading.value ? null : login,
                  //       child: authController.isLoading.value
                  //           ? const CircularProgressIndicator(
                  //               color: Colors.white)
                  //           : const Text('Sign In',
                  //               style: TextStyle(fontSize: 18)),
                  //     ),
                  //   );
                  // }),

                  Obx(() {
                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        
                         onPressed:
                          authController.isLoading.value ? null : ()=>login(context),
                        style: ElevatedButton.styleFrom(
                          // backgroundColor: _backgroundColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          elevation: 0,
                        ),
                        child: authController.isLoading.value
                            ? LoadingWidget()
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Log In',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  // SizedBox(width: 8),
                                  // Icon(Icons.arrow_forward_rounded),
                                ],
                              ),
                      ),
                    );
                  }),

                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account yet?",
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Get.offNamed('/register');
                          },
                          child: const Text('Sign Up'),
                          style: TextButton.styleFrom(
                              textStyle: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          )),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Helper widget for the toggle buttons
  // Widget _buildToggleButton({
  //   required String text,
  //   required bool isSelected,
  //   required VoidCallback onTap,
  // }) {
  //   return Expanded(
  //     child: GestureDetector(
  //       onTap: onTap,
  //       child: Container(
  //         padding: const EdgeInsets.symmetric(vertical: 12.0),
  //         decoration: BoxDecoration(
  //           color: isSelected ? _backgroundColor : const Color.fromARGB(0, 146, 19, 19),
  //           borderRadius: BorderRadius.circular(14.0),
  //         ),
  //         child: Center(
  //           child: Text(
  //             text,
  //             style: TextStyle(
  //               color: isSelected ? _cardColor : _textGrey,
  //               fontSize: 16,
  //               fontWeight: FontWeight.w600,
  //             ),
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }
}
