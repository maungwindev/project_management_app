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
  bool _isSignIn = true;
  bool _isPasswordHidden = true;

  // Color Palette from the image
  final Color _backgroundColor = const Color(0xFF12171D);
  final Color _cardColor = Colors.white;
  final Color _inputFillColor = const Color(0xFF212730);
  final Color _inputBorderColor = const Color(0xFF2D3440);
  final Color _primaryBlue = const Color(0xFF007AFF);
  final Color _textGrey = const Color(0xFF8F9BB3);

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
            constraints: const BoxConstraints(maxWidth: 500),
         
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title
                   Text(
                    'Welcome Back',
                    style: TextStyle(
                      color: _backgroundColor,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Subtitle
                  Text(
                    'Manage better. Log in to your workspace.',
                    style: TextStyle(
                      color:_textGrey,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Sign In / Sign Up Toggle
                  Container(
                    padding: const EdgeInsets.all(4.0),
                    decoration: BoxDecoration(
                      color: _inputFillColor,
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    child: Row(
                      children: [
                        _buildToggleButton(
                          text: 'Sign In',
                          isSelected: _isSignIn,
                          onTap: () => setState(() => _isSignIn = true),
                        ),
                        _buildToggleButton(
                          text: 'Sign Up',
                          isSelected: !_isSignIn,
                          onTap: () => setState(() => _isSignIn = false),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  _buildLabel('Email Address'),
                const SizedBox(height: 8),
                  // Email TextFormField
                  TextFormField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: _buildInputDecoration(hintText: "Enter Your Email",prefixIcon: Icons.mail),
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
                  _buildLabel('Password'),
                const SizedBox(height: 8),
                  // Password TextFormField
                  TextFormField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: _buildInputDecoration(hintText:"Enter Your Password",prefixIcon: Icons.password,suffixIcon: Icon(Icons.visibility_off)),
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

                  Obx((){
                    return  SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                  onPressed:
                            authController.isLoading.value ? null : login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _backgroundColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      elevation: 0,
                    ),
                    child: authController.isLoading.value
                            ? const CircularProgressIndicator(
                                color: Colors.white): const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'SignIn',
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

                  const SizedBox(height: 16),
                  // Row(
                  //   children: [
                  //     Text("Don't have an account yet?"),
                  //     TextButton(
                  //       onPressed: () {
                  //         Get.offNamed('/register');
                  //       },
                  //       child: const Text('Sign Up'),
                  //       style: TextButton.styleFrom(
                  //           textStyle: TextStyle(fontWeight: FontWeight.bold)),
                  //     ),
                  //   ],
                  // ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Helper widget for labels
  Widget _buildLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style:  TextStyle(
          color: _backgroundColor,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // Helper for input decoration
  InputDecoration _buildInputDecoration({
    required String hintText,
    required IconData prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      hintText: hintText,
      hintStyle: TextStyle(color: _textGrey),
      prefixIcon: Icon(prefixIcon, color: _textGrey),
      suffixIcon: suffixIcon,
      contentPadding: const EdgeInsets.symmetric(vertical: 16.0),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.0),
        borderSide: BorderSide(color: _inputBorderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.0),
        borderSide: BorderSide(color: _inputBorderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.0),
        borderSide: BorderSide(color: _inputBorderColor, width: 1.5),
      ),
    );
  }

  // Helper widget for the toggle buttons
  Widget _buildToggleButton({
    required String text,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          decoration: BoxDecoration(
            color: isSelected ? _backgroundColor : const Color.fromARGB(0, 146, 19, 19),
            borderRadius: BorderRadius.circular(14.0),
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                color: isSelected ? _cardColor : _textGrey,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
