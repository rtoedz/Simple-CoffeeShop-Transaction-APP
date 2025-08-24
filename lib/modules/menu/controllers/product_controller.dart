import 'package:get/get.dart';
import '../../../core/models/product.dart';
import '../../../core/services/firestore_service.dart';

class ProductController extends GetxController {
  FirestoreService get _firestoreService => Get.find<FirestoreService>();
  
  final RxList<Product> products = <Product>[].obs;
  final RxList<String> categories = <String>[].obs;
  final RxString selectedCategory = 'All'.obs;
  final RxBool isLoading = false.obs;
  final RxString searchQuery = ''.obs;
  
  @override
  void onInit() {
    super.onInit();
    loadProducts();
    loadCategories();
  }
  
  void loadProducts() {
    isLoading.value = true;
    _firestoreService.getProductsStream().listen(
      (productList) {
        products.value = productList;
        isLoading.value = false;
      },
      onError: (error) {
        isLoading.value = false;
        Get.snackbar('Error', 'Failed to load products: $error');
      },
    );
  }
  
  void loadCategories() async {
    try {
      final categoryList = await _firestoreService.getCategories();
      categories.value = ['All', ...categoryList];
    } catch (e) {
      Get.snackbar('Error', 'Failed to load categories: $e');
    }
  }
  
  void selectCategory(String category) {
    selectedCategory.value = category;
  }
  
  void setSearchQuery(String query) {
    searchQuery.value = query;
  }
  
  List<Product> get filteredProducts {
    var filtered = products.where((product) {
      final matchesCategory = selectedCategory.value == 'All' || 
                            product.category == selectedCategory.value;
      final matchesSearch = searchQuery.value.isEmpty ||
                          product.name.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
                          product.description.toLowerCase().contains(searchQuery.value.toLowerCase());
      return matchesCategory && matchesSearch && product.isAvailable;
    }).toList();
    
    return filtered;
  }
  
  Future<void> addProduct(Product product) async {
    try {
      isLoading.value = true;
      await _firestoreService.createProduct(product);
      Get.snackbar('Success', 'Product added successfully');
      loadCategories(); // Refresh categories
    } catch (e) {
      Get.snackbar('Error', 'Failed to add product: $e');
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> updateProduct(String productId, Map<String, dynamic> data) async {
    try {
      isLoading.value = true;
      await _firestoreService.updateProduct(productId, data);
      Get.snackbar('Success', 'Product updated successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to update product: $e');
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> deleteProduct(String productId) async {
    try {
      isLoading.value = true;
      await _firestoreService.deleteProduct(productId);
      Get.snackbar('Success', 'Product deleted successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete product: $e');
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> toggleProductAvailability(Product product) async {
    try {
      await updateProduct(product.id ?? '', {
        'isAvailable': !product.isAvailable,
      });
    } catch (e) {
      Get.snackbar('Error', 'Failed to update product availability: $e');
    }
  }
}