import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/firestore_service.dart';
import '../../core/models/user_model.dart';
import '../../core/routes/app_routes.dart';

class ProfileController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  FirestoreService get _firestoreService => Get.find<FirestoreService>();
  
  final user = Rxn<UserModel>();
  final isLoading = true.obs;
  final isUpdating = false.obs;
  
  final nameController = TextEditingController();
  final phoneController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    loadUserProfile();
  }

  @override
  void onClose() {
    nameController.dispose();
    phoneController.dispose();
    super.onClose();
  }

  void loadUserProfile() async {
    try {
      isLoading.value = true;
      final currentUser = _authService.user;
      if (currentUser != null) {
        final userData = await _firestoreService.getUser(currentUser.uid);
        if (userData != null) {
          user.value = userData;
          nameController.text = userData.name;
          phoneController.text = userData.phoneNumber ?? '';
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load profile: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateProfile() async {
    if (user.value == null) return;
    
    try {
      isUpdating.value = true;
      
      final updatedUser = user.value!.copyWith(
        name: nameController.text.trim(),
        phoneNumber: phoneController.text.trim().isEmpty 
            ? null 
            : phoneController.text.trim(),
        updatedAt: DateTime.now(),
      );
      
      await _firestoreService.updateUser(updatedUser.id, {
        'name': updatedUser.name,
        'phoneNumber': updatedUser.phoneNumber,
        'updatedAt': updatedUser.updatedAt?.millisecondsSinceEpoch,
      });
      user.value = updatedUser;
      
      Get.snackbar(
        'Success',
        'Profile updated successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to update profile: $e');
    } finally {
      isUpdating.value = false;
    }
  }

  Future<void> changePassword() async {
    final result = await Get.dialog<Map<String, String>>(
      _ChangePasswordDialog(),
    );
    
    if (result != null) {
      try {
        await _authService.changePassword(
          result['currentPassword']!,
          result['newPassword']!,
        );
        
        Get.snackbar(
          'Success',
          'Password changed successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } catch (e) {
        Get.snackbar('Error', 'Failed to change password: $e');
      }
    }
  }

  Future<void> logout() async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: Text('Logout'),
        content: Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _authService.signOut();
        Get.offAllNamed(AppRoutes.LOGIN);
      } catch (e) {
        Get.snackbar('Error', 'Failed to logout: $e');
      }
    }
  }
}

class ProfileScreen extends StatelessWidget {
  final ProfileController controller = Get.find<ProfileController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }
        
        if (controller.user.value == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'Failed to load profile',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: controller.loadUserProfile,
                  child: Text('Retry'),
                ),
              ],
            ),
          );
        }
        
        return SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              // Profile Header
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Theme.of(context).primaryColor,
                      child: controller.user.value!.avatarUrl != null
                          ? ClipOval(
                              child: Image.network(
                                controller.user.value!.avatarUrl!,
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(
                                    Icons.person,
                                    size: 50,
                                    color: Colors.white,
                                  );
                                },
                              ),
                            )
                          : Icon(
                              Icons.person,
                              size: 50,
                              color: Colors.white,
                            ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      controller.user.value!.name,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      controller.user.value!.email,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 8),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getRoleColor(controller.user.value!.role).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _getRoleColor(controller.user.value!.role),
                        ),
                      ),
                      child: Text(
                        controller.user.value!.role.toUpperCase(),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: _getRoleColor(controller.user.value!.role),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 24),
              
              // Profile Form
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Personal Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16),
                      
                      TextFormField(
                        controller: controller.nameController,
                        decoration: InputDecoration(
                          labelText: 'Full Name',
                          prefixIcon: Icon(Icons.person),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      
                      SizedBox(height: 16),
                      
                      TextFormField(
                        controller: controller.phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: 'Phone Number',
                          prefixIcon: Icon(Icons.phone),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      
                      SizedBox(height: 16),
                      
                      TextFormField(
                        initialValue: controller.user.value!.email,
                        enabled: false,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      
                      SizedBox(height: 20),
                      
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: controller.isUpdating.value 
                              ? null 
                              : controller.updateProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: controller.isUpdating.value
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : Text('Update Profile'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              SizedBox(height: 16),
              
              // Settings Section
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(Icons.lock),
                      title: Text('Change Password'),
                      trailing: Icon(Icons.chevron_right),
                      onTap: controller.changePassword,
                    ),
                    Divider(height: 1),
                    ListTile(
                      leading: Icon(Icons.settings),
                      title: Text('Settings'),
                      trailing: Icon(Icons.chevron_right),
                      onTap: () {
                        Get.snackbar(
                          'Coming Soon',
                          'Settings page will be available soon',
                        );
                      },
                    ),
                    Divider(height: 1),
                    ListTile(
                      leading: Icon(Icons.help),
                      title: Text('Help & Support'),
                      trailing: Icon(Icons.chevron_right),
                      onTap: () {
                        Get.snackbar(
                          'Coming Soon',
                          'Help & Support will be available soon',
                        );
                      },
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 16),
              
              // Logout Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: controller.logout,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: BorderSide(color: Colors.red),
                    padding: EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.logout),
                      SizedBox(width: 8),
                      Text('Logout'),
                    ],
                  ),
                ),
              ),
              
              SizedBox(height: 24),
            ],
          ),
        );
      }),
    );
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return Colors.red;
      case 'manager':
        return Colors.orange;
      case 'cashier':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}

class _ChangePasswordDialog extends StatefulWidget {
  @override
  __ChangePasswordDialogState createState() => __ChangePasswordDialogState();
}

class __ChangePasswordDialogState extends State<_ChangePasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Change Password'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _currentPasswordController,
              obscureText: _obscureCurrentPassword,
              decoration: InputDecoration(
                labelText: 'Current Password',
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureCurrentPassword ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureCurrentPassword = !_obscureCurrentPassword;
                    });
                  },
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter current password';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _newPasswordController,
              obscureText: _obscureNewPassword,
              decoration: InputDecoration(
                labelText: 'New Password',
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureNewPassword ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureNewPassword = !_obscureNewPassword;
                    });
                  },
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter new password';
                }
                if (value.length < 6) {
                  return 'Password must be at least 6 characters';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _confirmPasswordController,
              obscureText: _obscureConfirmPassword,
              decoration: InputDecoration(
                labelText: 'Confirm New Password',
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please confirm new password';
                }
                if (value != _newPasswordController.text) {
                  return 'Passwords do not match';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.of(context).pop({
                'currentPassword': _currentPasswordController.text,
                'newPassword': _newPasswordController.text,
              });
            }
          },
          child: Text('Change Password'),
        ),
      ],
    );
  }
}