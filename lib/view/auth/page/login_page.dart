import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pm_app/controller/auth_controller.dart';

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

  // Example login function
  void login() async {
    if (_formKey.currentState!.validate()) {
      final success = await authController.login(
        requestBody: {
          'email': emailController.text,
          'password': passwordController.text,
        },
      );

      if (success) {
        Get.snackbar(
          'Success',
          'Login successful',
          snackPosition: SnackPosition.BOTTOM,
        );

        // Navigate to home/dashboard
        Get.offAllNamed('/home');
      } else {
        Get.snackbar(
          'Login Failed',
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
                    'Login',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 32),
                  // Email TextFormField
                  TextFormField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email),
                    ),
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
                  const SizedBox(height: 16),
                  // Password TextFormField
                  TextFormField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock),
                    ),
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
                  const SizedBox(height: 24),
                  Obx(() {
                    return SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed:
                            authController.isLoading.value ? null : login,
                        child: authController.isLoading.value
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            : const Text('Login',
                                style: TextStyle(fontSize: 18)),
                      ),
                    );
                  }),

                  const SizedBox(height: 16),
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
