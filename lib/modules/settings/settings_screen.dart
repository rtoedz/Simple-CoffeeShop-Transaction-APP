import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/database_service.dart';
import '../../core/models/user_model.dart';

class SettingsController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final DatabaseService _databaseService = Get.find<DatabaseService>();
  final GetStorage _storage = GetStorage();
  
  final isDarkMode = false.obs;
  final isNotificationEnabled = true.obs;
  final autoBackup = true.obs;
  final receiptPrinting = true.obs;
  final soundEnabled = true.obs;
  final user = Rxn<UserModel>();
  
  final businessNameController = TextEditingController();
  final businessAddressController = TextEditingController();
  final businessPhoneController = TextEditingController();
  final taxRateController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    loadSettings();
    loadUserProfile();
  }

  @override
  void onClose() {
    businessNameController.dispose();
    businessAddressController.dispose();
    businessPhoneController.dispose();
    taxRateController.dispose();
    super.onClose();
  }

  void loadSettings() {
    isDarkMode.value = _storage.read('dark_mode') ?? false;
    isNotificationEnabled.value = _storage.read('notifications') ?? true;
    autoBackup.value = _storage.read('auto_backup') ?? true;
    receiptPrinting.value = _storage.read('receipt_printing') ?? true;
    soundEnabled.value = _storage.read('sound_enabled') ?? true;
    
    // Load business settings
    businessNameController.text = _storage.read('business_name') ?? 'KopiKita POS';
    businessAddressController.text = _storage.read('business_address') ?? '';
    businessPhoneController.text = _storage.read('business_phone') ?? '';
    taxRateController.text = (_storage.read('tax_rate') ?? 10.0).toString();
  }

  void loadUserProfile() async {
    try {
      final currentUser = _authService.user;
      if (currentUser != null) {
        final userData = await _databaseService.getUser(currentUser.uid);
        if (userData != null) {
          user.value = userData;
        }
      }
    } catch (e) {
      print('Error loading user profile: $e');
    }
  }

  void toggleDarkMode(bool value) {
    isDarkMode.value = value;
    _storage.write('dark_mode', value);
    Get.changeThemeMode(value ? ThemeMode.dark : ThemeMode.light);
  }

  void toggleNotifications(bool value) {
    isNotificationEnabled.value = value;
    _storage.write('notifications', value);
  }

  void toggleAutoBackup(bool value) {
    autoBackup.value = value;
    _storage.write('auto_backup', value);
  }

  void toggleReceiptPrinting(bool value) {
    receiptPrinting.value = value;
    _storage.write('receipt_printing', value);
  }

  void toggleSound(bool value) {
    soundEnabled.value = value;
    _storage.write('sound_enabled', value);
  }

  Future<void> saveBusinessSettings() async {
    try {
      _storage.write('business_name', businessNameController.text.trim());
      _storage.write('business_address', businessAddressController.text.trim());
      _storage.write('business_phone', businessPhoneController.text.trim());
      
      final taxRate = double.tryParse(taxRateController.text) ?? 10.0;
      _storage.write('tax_rate', taxRate);
      
      Get.snackbar(
        'Success',
        'Business settings saved successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to save settings: $e');
    }
  }

  Future<void> exportData() async {
    try {
      // Simulate data export
      await Future.delayed(Duration(seconds: 2));
      
      Get.snackbar(
        'Success',
        'Data exported successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to export data: $e');
    }
  }

  Future<void> importData() async {
    try {
      // Simulate data import
      await Future.delayed(Duration(seconds: 2));
      
      Get.snackbar(
        'Success',
        'Data imported successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to import data: $e');
    }
  }

  Future<void> clearCache() async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: Text('Clear Cache'),
        content: Text('This will clear all cached data. Are you sure?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('Clear'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        // Clear cache logic here
        await Future.delayed(Duration(seconds: 1));
        
        Get.snackbar(
          'Success',
          'Cache cleared successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } catch (e) {
        Get.snackbar('Error', 'Failed to clear cache: $e');
      }
    }
  }

  Future<void> resetSettings() async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: Text('Reset Settings'),
        content: Text('This will reset all settings to default. Are you sure?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('Reset'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        // Reset to default values
        _storage.remove('dark_mode');
        _storage.remove('notifications');
        _storage.remove('auto_backup');
        _storage.remove('receipt_printing');
        _storage.remove('sound_enabled');
        _storage.remove('business_name');
        _storage.remove('business_address');
        _storage.remove('business_phone');
        _storage.remove('tax_rate');
        
        // Reload settings
        loadSettings();
        
        Get.snackbar(
          'Success',
          'Settings reset to default',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } catch (e) {
        Get.snackbar('Error', 'Failed to reset settings: $e');
      }
    }
  }
}

class SettingsScreen extends StatelessWidget {
  final SettingsController controller = Get.find<SettingsController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App Settings Section
            _buildSectionTitle('App Settings'),
            Card(
              child: Column(
                children: [
                  Obx(() => SwitchListTile(
                    title: Text('Dark Mode'),
                    subtitle: Text('Enable dark theme'),
                    value: controller.isDarkMode.value,
                    onChanged: controller.toggleDarkMode,
                    secondary: Icon(Icons.dark_mode),
                  )),
                  Divider(height: 1),
                  Obx(() => SwitchListTile(
                    title: Text('Notifications'),
                    subtitle: Text('Enable push notifications'),
                    value: controller.isNotificationEnabled.value,
                    onChanged: controller.toggleNotifications,
                    secondary: Icon(Icons.notifications),
                  )),
                  Divider(height: 1),
                  Obx(() => SwitchListTile(
                    title: Text('Sound Effects'),
                    subtitle: Text('Enable sound effects'),
                    value: controller.soundEnabled.value,
                    onChanged: controller.toggleSound,
                    secondary: Icon(Icons.volume_up),
                  )),
                ],
              ),
            ),
            
            SizedBox(height: 24),
            
            // Business Settings Section
            _buildSectionTitle('Business Settings'),
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextFormField(
                      controller: controller.businessNameController,
                      decoration: InputDecoration(
                        labelText: 'Business Name',
                        prefixIcon: Icon(Icons.business),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: controller.businessAddressController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: 'Business Address',
                        prefixIcon: Icon(Icons.location_on),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: controller.businessPhoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: 'Business Phone',
                        prefixIcon: Icon(Icons.phone),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: controller.taxRateController,
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: 'Tax Rate (%)',
                        prefixIcon: Icon(Icons.percent),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: controller.saveBusinessSettings,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text('Save Business Settings'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 24),
            
            // POS Settings Section
            _buildSectionTitle('POS Settings'),
            Card(
              child: Column(
                children: [
                  Obx(() => SwitchListTile(
                    title: Text('Auto Backup'),
                    subtitle: Text('Automatically backup data'),
                    value: controller.autoBackup.value,
                    onChanged: controller.toggleAutoBackup,
                    secondary: Icon(Icons.backup),
                  )),
                  Divider(height: 1),
                  Obx(() => SwitchListTile(
                    title: Text('Receipt Printing'),
                    subtitle: Text('Enable automatic receipt printing'),
                    value: controller.receiptPrinting.value,
                    onChanged: controller.toggleReceiptPrinting,
                    secondary: Icon(Icons.print),
                  )),
                ],
              ),
            ),
            
            SizedBox(height: 24),
            
            // Data Management Section
            _buildSectionTitle('Data Management'),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.file_download),
                    title: Text('Export Data'),
                    subtitle: Text('Export all data to file'),
                    trailing: Icon(Icons.chevron_right),
                    onTap: controller.exportData,
                  ),
                  Divider(height: 1),
                  ListTile(
                    leading: Icon(Icons.file_upload),
                    title: Text('Import Data'),
                    subtitle: Text('Import data from file'),
                    trailing: Icon(Icons.chevron_right),
                    onTap: controller.importData,
                  ),
                  Divider(height: 1),
                  ListTile(
                    leading: Icon(Icons.clear_all),
                    title: Text('Clear Cache'),
                    subtitle: Text('Clear all cached data'),
                    trailing: Icon(Icons.chevron_right),
                    onTap: controller.clearCache,
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 24),
            
            // System Section
            _buildSectionTitle('System'),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.info),
                    title: Text('App Version'),
                    subtitle: Text('1.0.0'),
                    trailing: Text(
                      'Latest',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Divider(height: 1),
                  ListTile(
                    leading: Icon(Icons.refresh, color: Colors.orange),
                    title: Text('Reset Settings'),
                    subtitle: Text('Reset all settings to default'),
                    trailing: Icon(Icons.chevron_right),
                    onTap: controller.resetSettings,
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 24),
            
            // User Info (if admin)
            Obx(() {
              if (controller.user.value?.role == 'admin') {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Admin Tools'),
                    Card(
                      child: Column(
                        children: [
                          ListTile(
                            leading: Icon(Icons.people),
                            title: Text('User Management'),
                            subtitle: Text('Manage system users'),
                            trailing: Icon(Icons.chevron_right),
                            onTap: () {
                              Get.snackbar(
                                'Coming Soon',
                                'User management will be available soon',
                              );
                            },
                          ),
                          Divider(height: 1),
                          ListTile(
                            leading: Icon(Icons.analytics),
                            title: Text('System Analytics'),
                            subtitle: Text('View system performance'),
                            trailing: Icon(Icons.chevron_right),
                            onTap: () {
                              Get.snackbar(
                                'Coming Soon',
                                'System analytics will be available soon',
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 24),
                  ],
                );
              }
              return SizedBox.shrink();
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.grey[700],
        ),
      ),
    );
  }
}