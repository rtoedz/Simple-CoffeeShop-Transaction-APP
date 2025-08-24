import 'package:get/get.dart';
import '../login_screen.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LoginController>(() => LoginController());
  }
}