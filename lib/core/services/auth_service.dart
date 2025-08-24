import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'storage_service.dart';
import 'firestore_service.dart';
import '../models/user_model.dart';

class AuthService extends GetxService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  StorageService get _storage => Get.find<StorageService>();
  FirestoreService get _firestore => Get.find<FirestoreService>();
  
  final Rx<User?> _user = Rx<User?>(null);
  User? get user => _user.value;
  
  final Rx<UserModel?> _currentUser = Rx<UserModel?>(null);
  UserModel? get currentUser => _currentUser.value;
  
  final RxBool isLoggedIn = false.obs;
  final RxString userRole = ''.obs;
  
  // Getter for auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  
  @override
  void onInit() {
    super.onInit();
    _user.bindStream(_auth.authStateChanges());
    ever(_user, _setInitialScreen);
  }
  
  _setInitialScreen(User? user) async {
    // Wait for the widget tree to be ready
    await Future.delayed(Duration(milliseconds: 500));
    
    if (user == null) {
      // User is not logged in
      isLoggedIn.value = false;
      userRole.value = '';
      _currentUser.value = null;
      
      // Use WidgetsBinding to ensure navigation happens after widget tree is ready
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (Get.context != null) {
          Get.offAllNamed('/login');
        }
      });
    } else {
      // User is logged in
      isLoggedIn.value = true;
      await _loadUserData(user);
      
      // Use WidgetsBinding to ensure navigation happens after widget tree is ready
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (Get.context != null) {
          Get.offAllNamed('/dashboard');
        }
      });
    }
  }
  
  Future<void> _loadUserData(User user) async {
    try {
      // Load user data from Firestore
      final userData = await _firestore.getUser(user.uid);
      if (userData != null) {
        _currentUser.value = userData;
        userRole.value = userData.role;
        
        // Save user info to storage
        _storage.write('user_id', user.uid);
        _storage.write('user_email', user.email);
        _storage.write('user_role', userData.role);
      } else {
        // Create user data if not exists
        final newUser = UserModel(
          id: user.uid,
          email: user.email ?? '',
          name: user.displayName ?? 'User',
          role: 'cashier',
          createdAt: DateTime.now(),
        );
        await _firestore.createUser(newUser);
        _currentUser.value = newUser;
        userRole.value = 'cashier';
      }
    } catch (e) {
      print('Error loading user data: $e');
      userRole.value = 'cashier'; // Default role
    }
  }
  
  Future<UserCredential?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential result = await _auth
          .signInWithEmailAndPassword(email: email, password: password);
      return result;
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }
  
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      _storage.remove('user_id');
      _storage.remove('user_email');
      _storage.remove('user_role');
      _currentUser.value = null;
    } catch (e) {
      throw Exception('Sign out failed: $e');
    }
  }
  
  Future<UserCredential?> createUserWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential result = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      return result;
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }
  
  Future<void> changePassword(String currentPassword, String newPassword) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('No user logged in');
      }
      
      // Re-authenticate user with current password
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      
      await user.reauthenticateWithCredential(credential);
      
      // Update password
      await user.updatePassword(newPassword);
    } catch (e) {
      throw Exception('Password change failed: $e');
    }
  }

  // Role checking methods
  bool get isAdmin => userRole.value == 'admin';
  bool get isCashier => userRole.value == 'cashier';
  bool get isManager => userRole.value == 'manager';
}