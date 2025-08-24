import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/services/database_service.dart';
import '../../core/services/firebase_service.dart';
import '../../core/models/product.dart';
import '../../widgets/product_card.dart';
import 'add_product_dialog.dart';

class MenuController extends GetxController {
  final DatabaseService _databaseService = Get.find<DatabaseService>();
  final FirebaseService _firebaseService = Get.find<FirebaseService>();
  
  final products = <Product>[].obs;
  final selectedCategory = 'All'.obs;
  final categories = <String>['All', 'Coffee', 'Tea', 'Snacks', 'Pastry'].obs;
  final isLoading = true.obs;
  final searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadProducts();
  }

  void loadProducts() {
    isLoading.value = true;
    _databaseService.getProducts().listen((productList) {
      products.value = productList;
      isLoading.value = false;
    });
  }

  List<Product> get filteredProducts {
    var filtered = products.where((product) {
      final matchesCategory = selectedCategory.value == 'All' || 
                            product.category == selectedCategory.value;
      final matchesSearch = searchQuery.value.isEmpty ||
                          product.name.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
                          (product.description?.toLowerCase().contains(searchQuery.value.toLowerCase()) ?? false);
      return matchesCategory && matchesSearch;
    }).toList();
    
    return filtered;
  }

  Future<void> addProduct() async {
    final result = await Get.dialog<Product>(
      AddProductDialog(),
    );

    if (result != null) {
      try {
        await _databaseService.addProduct(result);
        Get.snackbar(
          'Success',
          'Product added successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } catch (e) {
        Get.snackbar('Error', 'Failed to add product: $e');
      }
    }
  }

  Future<void> editProduct(Product product) async {
    final result = await Get.dialog<Product>(
      AddProductDialog(product: product),
    );

    if (result != null) {
      try {
        await _databaseService.updateProduct(result.id!, result);
        Get.snackbar(
          'Success',
          'Product updated successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } catch (e) {
        Get.snackbar('Error', 'Failed to update product: $e');
      }
    }
  }

  Future<void> deleteProduct(Product product) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: Text('Delete Product'),
        content: Text('Are you sure you want to delete "${product.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _databaseService.deleteProduct(product.id!);
        
        // Delete image if exists
        if (product.imageUrl != null && product.imageUrl!.isNotEmpty) {
          await _firebaseService.deleteImage(product.imageUrl!);
        }
        
        Get.snackbar(
          'Success',
          'Product deleted successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } catch (e) {
        Get.snackbar('Error', 'Failed to delete product: $e');
      }
    }
  }

  void toggleAvailability(Product product) async {
    try {
      final updatedProduct = product.copyWith(
        isAvailable: !product.isAvailable,
      );
      await _databaseService.updateProduct(product.id!, updatedProduct);
      
      Get.snackbar(
        'Success',
        'Product availability updated',
        duration: Duration(seconds: 1),
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to update product: $e');
    }
  }
}

class MenuScreen extends StatelessWidget {
  final MenuController controller = Get.find<MenuController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Menu Management'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: controller.addProduct,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Section
          Container(
            padding: EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              children: [
                // Search Bar
                TextField(
                  onChanged: (value) => controller.searchQuery.value = value,
                  decoration: InputDecoration(
                    hintText: 'Search products...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                ),
                
                SizedBox(height: 12),
                
                // Category Filter
                Container(
                  height: 40,
                  child: Obx(() => ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: controller.categories.length,
                    itemBuilder: (context, index) {
                      final category = controller.categories[index];
                      final isSelected = controller.selectedCategory.value == category;
                      
                      return Padding(
                        padding: EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(category),
                          selected: isSelected,
                          onSelected: (selected) {
                            controller.selectedCategory.value = category;
                          },
                          backgroundColor: Colors.grey[200],
                          selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
                          checkmarkColor: Theme.of(context).primaryColor,
                        ),
                      );
                    },
                  )),
                ),
              ],
            ),
          ),
          
          // Products Grid
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return Center(child: CircularProgressIndicator());
              }
              
              final products = controller.filteredProducts;
              
              if (products.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inventory_2, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        controller.searchQuery.value.isNotEmpty
                            ? 'No products found'
                            : 'No products available',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      if (controller.searchQuery.value.isEmpty)
                        Padding(
                          padding: EdgeInsets.only(top: 16),
                          child: ElevatedButton.icon(
                            onPressed: controller.addProduct,
                            icon: Icon(Icons.add),
                            label: Text('Add Product'),
                          ),
                        ),
                    ],
                  ),
                );
              }
              
              return GridView.builder(
                padding: EdgeInsets.all(16),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.75,
                ),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  return GestureDetector(
                    onLongPress: () => _showProductOptions(context, product),
                    child: ProductCard(
                      product: product,
                      showAddButton: false,
                      onTap: () => controller.editProduct(product),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  void _showProductOptions(BuildContext context, Product product) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.edit),
              title: Text('Edit Product'),
              onTap: () {
                Get.back();
                controller.editProduct(product);
              },
            ),
            ListTile(
              leading: Icon(
                product.isAvailable ? Icons.visibility_off : Icons.visibility,
              ),
              title: Text(
                product.isAvailable ? 'Mark Unavailable' : 'Mark Available',
              ),
              onTap: () {
                Get.back();
                controller.toggleAvailability(product);
              },
            ),
            ListTile(
              leading: Icon(Icons.delete, color: Colors.red),
              title: Text('Delete Product', style: TextStyle(color: Colors.red)),
              onTap: () {
                Get.back();
                controller.deleteProduct(product);
              },
            ),
          ],
        ),
      ),
    );
  }
}