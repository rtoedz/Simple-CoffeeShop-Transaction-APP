import 'package:get/get.dart';
import 'app_routes.dart';
import '../../modules/splash/splash_screen.dart';
import '../../modules/auth/login_screen.dart';
import '../../modules/auth/bindings/auth_binding.dart';
import '../../modules/dashboard/dashboard_screen.dart';
import '../../modules/pos/pos_screen.dart';
import '../../modules/menu/views/menu_screen.dart';
import '../../modules/transaction/transaction_history_screen.dart';
import '../../modules/settings/settings_screen.dart';
import '../../modules/profile/profile_screen.dart';

class AppPages {
  static final routes = [
    GetPage(
      name: AppRoutes.SPLASH,
      page: () => SplashScreen(),
    ),
    GetPage(
      name: AppRoutes.LOGIN,
      page: () => LoginScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.DASHBOARD,
      page: () => DashboardScreen(),
    ),
    GetPage(
      name: AppRoutes.POS,
      page: () => PosScreen(),
    ),
    GetPage(
      name: AppRoutes.MENU_MANAGEMENT,
      page: () => MenuScreen(),
    ),
    GetPage(
      name: AppRoutes.TRANSACTION_HISTORY,
      page: () => TransactionHistoryScreen(),
    ),
    GetPage(
      name: AppRoutes.SETTINGS,
      page: () => SettingsScreen(),
    ),
    GetPage(
      name: AppRoutes.PROFILE,
      page: () => ProfileScreen(),
    ),
  ];
}