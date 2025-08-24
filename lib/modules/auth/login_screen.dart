import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/services/auth_service.dart';
import '../../core/routes/app_routes.dart';

class LoginController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  
  final isLoading = false.obs;
  final isPasswordVisible = false.obs;
  bool _isDisposed = false;

  @override
  void onClose() {
    _isDisposed = true;
    super.onClose();
  }

  bool get isDisposed => _isDisposed;

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  Future<void> login(String email, String password) async {
    if (isDisposed) return;
    
    if (email.isEmpty || password.isEmpty) {
      if (!isDisposed) {
        Get.snackbar('Error', 'Please fill all fields');
      }
      return;
    }

    try {
      if (isDisposed) return;
      isLoading.value = true;
      
      final userCredential = await _authService.signInWithEmailAndPassword(
        email.trim(),
        password.trim(),
      );
      
      if (userCredential != null && !isDisposed) {
        Get.offAllNamed(AppRoutes.DASHBOARD);
      }
    } catch (e) {
      if (!isDisposed) {
        Get.snackbar('Error', 'Login failed: $e');
      }
    } finally {
      if (!isDisposed) {
        isLoading.value = false;
      }
    }
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final LoginController controller;
  late final TextEditingController emailController;
  late final TextEditingController passwordController;

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    controller = Get.put(LoginController());
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    Get.delete<LoginController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.coffee,
                    size: 80,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                SizedBox(height: 32),
                
                // Title
                Text(
                  'KopiKita POS',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Point of Sale System',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
                SizedBox(height: 48),
                
                // Login Form
                Container(
                  padding: EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Login',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 24),
                      
                      // Email Field
                      TextFormField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      
                      // Password Field
                      Obx(() => TextFormField(
                        controller: passwordController,
                        obscureText: !controller.isPasswordVisible.value,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(
                              controller.isPasswordVisible.value
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: controller.togglePasswordVisibility,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      )),
                      SizedBox(height: 24),
                      
                      // Login Button
                      Obx(() {
                        if (controller.isDisposed) {
                          return SizedBox.shrink();
                        }
                        return ElevatedButton(
                          onPressed: controller.isLoading.value ? null : () => controller.login(emailController.text, passwordController.text),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: controller.isLoading.value
                              ? SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : Text(
                                  'Login',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        );
                      }),
                      SizedBox(height: 16),
                      
                      // Demo Credentials
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Demo Credentials:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Admin: admin@kopikita.com / admin123',
                              style: TextStyle(fontSize: 11),
                            ),
                            Text(
                              'Cashier: cashier@kopikita.com / cashier123',
                              style: TextStyle(fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}