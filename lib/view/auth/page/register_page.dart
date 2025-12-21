import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pm_app/controller/user_controller.dart';
import 'package:pm_app/core/component/custom_Inputdecoration.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmpasswordController =
      TextEditingController();
  final UserController userController = Get.find<UserController>();

  bool isLoading = false;
  bool isObscured = false;

  // Example login function
  void register() async {
    if (_formKey.currentState!.validate()) {
      final success = await userController.createUser(
          name: nameController.text,
          email: emailController.text,
          password: passwordController.text);

      if (success) {
        print("what happen:${success}");
        Get.offAllNamed('/home');
        // Then show snackbar (or use a GetX controller in home to show success)
        // Future.delayed(Duration(milliseconds: 300), () {
        //   Get.snackbar(
        //     'Success',
        //     'Register successful',
        //     snackPosition: SnackPosition.BOTTOM,
        //   );
        // });

        // Navigate to home/dashboard
      } else {
        Get.snackbar(
          'Register Failed',
          'Invalid email or password',
          snackPosition: SnackPosition.BOTTOM,
        );
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
                  const Text(
                    'Welcome to PM',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                   const SizedBox(height: 8),
                  // Subtitle
                  Text(
                    'Get started - it\'s free. No credit card needed.',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 32),
                  buildLabel('Name '),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: nameController,
                    keyboardType: TextInputType.text,
                    decoration: buildInputDecoration(
                      hintText: 'Enter Your Name',prefixIcon: Icons.person
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your name';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 18),
                  buildLabel('Email '),
                  const SizedBox(height: 8),
                  // Email TextFormField
                  TextFormField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: buildInputDecoration(hintText: 'Enter Your Email', prefixIcon: Icons.email),
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
                  buildLabel('Password '),
                  const SizedBox(height: 8),
                  // Password TextFormField
                  TextFormField(
                    controller: passwordController,
                    obscureText: !isObscured,
                    decoration: buildInputDecoration(
                      hintText: 'Enter Your Password', prefixIcon: Icons.lock,suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                isObscured = !isObscured;
                              });
                            },
                            icon: isObscured
                                ? Icon(Icons.visibility)
                                : Icon(Icons.visibility_off))),
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
                  buildLabel('Confirm Password '),
                  const SizedBox(height: 8),
                  // Password TextFormField
                  TextFormField(
                    controller: confirmpasswordController,
                    obscureText: !isObscured,
                    decoration: buildInputDecoration(hintText: 'Re-Enter Your Password', prefixIcon: Icons.lock),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      if (value != passwordController.text) {
                        return 'Password doesn\'t same.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  Obx(() {
                    return SizedBox(
                      width: double.infinity,
                      height: 40,
                      child: ElevatedButton(
                        onPressed:
                            userController.isRegister.value ? null : register,
                        child: userController.isRegister.value
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            : const Text('Sign Up',
                                style: TextStyle(fontSize: 18)),
                      ),
                    );
                  }),

                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Already have an account yet?",style: TextStyle(
                            fontSize: 16,
                          ),),
                        TextButton(
                          onPressed: () {
                            Get.offNamed('/login');
                    
                          },
                          child: const Text('Sign In'),
                          style: TextButton.styleFrom(
                            textStyle: TextStyle(
                              fontWeight: FontWeight.bold,fontSize: 16
                            )
                          ),
                        ),
                      ],
                    ),
                  ),
                  // TextButton(
                  //   onPressed: () {},
                  //   child: const Text('Forgot password?'),
                  // ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
