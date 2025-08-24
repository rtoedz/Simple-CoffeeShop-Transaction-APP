import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/storage_service.dart';

class AuthController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final StorageService _storageService = Get.find<StorageService>();
  
  final RxBool isLoading = false.obs;
  final Rx<User?> user = Rx<User?>(null);
  final RxString userRole = ''.obs;
  
  @override
  void onInit() {
    super.onInit();
    // Listen to auth state changes
    ever(user, _setInitialScreen);
    user.bindStream(_authService.authStateChanges);
  }
  
  void _setInitialScreen(User? user) {
    if (user == null) {
      Get.offAllNamed('/login');
    } else {
      _loadUserRole();
      Get.offAllNamed('/dashboard');
    }
  }
  
  Future<void> _loadUserRole() async {
    try {
      final role = await _storageService.getUserRole();
      userRole.value = role ?? 'cashier';
    } catch (e) {
      userRole.value = 'cashier';
    }
  }
  
  Future<void> signIn(String email, String password) async {
    try {
      isLoading.value = true;
      await _authService.signInWithEmailAndPassword(email, password);
    } catch (e) {
      Get.snackbar('Error', 'Login failed: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> signOut() async {
    try {
      await _authService.signOut();
      await _storageService.clearUserData();
    } catch (e) {
      Get.snackbar('Error', 'Logout failed: ${e.toString()}');
    }
  }
  
  bool get isAdmin => userRole.value == 'admin';
  bool get isCashier => userRole.value == 'cashier';
  bool get isLoggedIn => user.value != null;
}