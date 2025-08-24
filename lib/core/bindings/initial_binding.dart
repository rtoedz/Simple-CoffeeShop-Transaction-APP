import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../services/storage_service.dart';
import '../services/firebase_service.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../../modules/auth/controllers/auth_controller.dart';
import '../../modules/auth/controllers/login_controller.dart';

import '../../modules/pos/controllers/pos_controller.dart';
import '../../modules/menu/controllers/product_controller.dart';
import '../../modules/profile/profile_screen.dart';
import '../../modules/dashboard/controllers/dashboard_controller.dart';
import '../../modules/settings/settings_screen.dart';
import '../../modules/transaction/transaction_history_screen.dart';
import '../../modules/menu/menu_screen.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Initialize GetStorage first
    Get.putAsync(() => GetStorage.init().then((_) => GetStorage()), permanent: true);
    
    // Core Services - use synchronous initialization
    Get.put(StorageService(), permanent: true);
    Get.put(FirebaseService(), permanent: true);
    Get.put(FirestoreService(), permanent: true);
    Get.put(AuthService(), permanent: true);
    
    // Initialize default data after all services are ready
    _initializeDefaultDataSafely();
    
    // Controllers
    Get.lazyPut(() => AuthController());
    Get.put(LoginController(), permanent: true);
    Get.lazyPut(() => PosController());
    Get.lazyPut(() => ProductController());
    Get.lazyPut(() => ProfileController());
    Get.lazyPut(() => DashboardController());
    Get.lazyPut(() => SettingsController());
    Get.lazyPut(() => TransactionHistoryController());
    Get.lazyPut(() => MenuController());
  }
  
  void _initializeDefaultDataSafely() {
    // Initialize default data in background after all services are ready
    Future.delayed(Duration(seconds: 2), () async {
      try {
        // Wait for all services to be ready
        await Get.find<StorageService>();
        final firestoreService = Get.find<FirestoreService>();
        await Get.find<AuthService>();
        
        // Now initialize default data
        await firestoreService.initializeDefaultData();
        print('Default data initialized successfully');
      } catch (e) {
        print('Error initializing default data: $e');
      }
    });
  }
}