import 'package:get/get.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    // LoginController is already initialized in InitialBinding
    // No need to initialize it again here
  }
}