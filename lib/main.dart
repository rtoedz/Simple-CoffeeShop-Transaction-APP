import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get_storage/get_storage.dart';
import 'firebase_options.dart';
import 'core/routes/app_routes.dart';
import 'core/routes/app_pages.dart';
import 'core/theme/app_theme.dart';
import 'core/bindings/initial_binding.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Initialize Firebase
    await Firebase.initializeApp();
    print('Firebase initialized successfully');
    
    // Initialize GetStorage
    await GetStorage.init();
    print('GetStorage initialized successfully');
    
    // Services will be initialized through InitialBinding
    
    print('All services initialized successfully');
  } catch (e) {
    print('Error during initialization: $e');
    // Continue with app launch even if some services fail
  }
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'KopiKita POS',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      initialRoute: AppRoutes.SPLASH,
      getPages: AppPages.routes,
      initialBinding: InitialBinding(),
      debugShowCheckedModeBanner: false,
    );
  }
}
