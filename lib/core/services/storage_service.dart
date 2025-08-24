import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class StorageService extends GetxService {
  late GetStorage _box;
  
  @override
  Future<void> onInit() async {
    super.onInit();
    _box = GetStorage();
  }
  
  // Generic methods
  T? read<T>(String key) => _box.read<T>(key);
  
  Future<void> write(String key, dynamic value) async {
    await _box.write(key, value);
  }
  
  Future<void> remove(String key) async {
    await _box.remove(key);
  }
  
  Future<void> clear() async {
    await _box.erase();
  }
  
  bool hasData(String key) => _box.hasData(key);
  
  // User-specific methods
  Future<String?> getUserRole() async {
    return read<String>('user_role');
  }
  
  Future<void> setUserRole(String role) async {
    await write('user_role', role);
  }
  
  Future<void> clearUserData() async {
    await remove('user_role');
    await remove('user_id');
    await remove('user_email');
  }
}