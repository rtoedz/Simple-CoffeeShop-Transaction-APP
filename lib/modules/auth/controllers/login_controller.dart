import 'package:get/get.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/routes/app_routes.dart';

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
    print('Login button pressed with email: $email');
    if (isDisposed) {
      print('Controller is disposed, returning');
      return;
    }

    try {
      isLoading.value = true;
      print('Setting isLoading to true: ${isLoading.value}');
      
      final result = await _authService.signInWithEmailAndPassword(email, password);
      print('Firebase sign in result: $result');
      
      if (result != null) {
        print('Login successful, navigating to dashboard');
        Get.offAllNamed(AppRoutes.DASHBOARD);
      }
    } catch (e) {
      print('Login error: $e');
      Get.snackbar(
        'Error',
        'Login failed: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      if (!isDisposed) {
        isLoading.value = false;
        print('Setting isLoading to false: ${isLoading.value}');
      }
    }
  }
}