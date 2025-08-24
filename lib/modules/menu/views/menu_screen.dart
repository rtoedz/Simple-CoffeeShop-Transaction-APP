import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/themes/app_theme.dart';
import '../../../core/models/product.dart';
import '../controllers/product_controller.dart';
import '../../../widgets/product_card.dart';
import '../../../widgets/add_product_dialog.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ProductController controller = Get.find<ProductController>();
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Menu Management'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => _showAddProductDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Section
          Container(
            padding: EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Column(
              children: [
                // Search Bar
                TextField(
                  onChanged: controller.setSearchQuery,
                  decoration: InputDecoration(
                    hintText: 'Search products...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                SizedBox(height: 12),
                // Category Filter
                Obx(() => SizedBox(
                  height: 40,
                  child: ListView.builder(
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
                          onSelected: (_) => controller.selectCategory(category),
                          backgroundColor: Colors.white,
                          selectedColor: AppTheme.primaryColor.withValues(alpha: 0.2),
                          checkmarkColor: AppTheme.primaryColor,
                        ),
                      );
                    },
                  ),
                )),
              ],
            ),
          ),
          // Products Grid
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return Center(
                  child: CircularProgressIndicator(
                    color: AppTheme.primaryColor,
                  ),
                );
              }
              
              final products = controller.filteredProducts;
              
              if (products.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.coffee_outlined,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No products found',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Add some products to get started',
                        style: TextStyle(
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                );
              }
              
              return GridView.builder(
                padding: EdgeInsets.all(16),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: _getCrossAxisCount(context),
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  return ProductCard(
                    product: product,
                    onTap: () => _showProductDetails(context, product),
                    onEdit: () => _showEditProductDialog(context, product),
                    onDelete: () => _confirmDeleteProduct(context, product),
                    onToggleAvailability: () => controller.toggleProductAvailability(product),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
  
  int _getCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) return 4;
    if (width > 800) return 3;
    if (width > 600) return 2;
    return 1;
  }
  
  void _showAddProductDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AddProductDialog(),
    );
  }
  
  void _showEditProductDialog(BuildContext context, Product product) {
    showDialog(
      context: context,
      builder: (context) => AddProductDialog(product: product),
    );
  }
  
  void _showProductDetails(BuildContext context, Product product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(product.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Description: ${product.description}'),
            SizedBox(height: 8),
            Text('Price: Rp ${product.price.toStringAsFixed(0)}'),
            SizedBox(height: 8),
            Text('Category: ${product.category}'),
            SizedBox(height: 8),
            Text('Stock: ${product.stock}'),
            SizedBox(height: 8),
            Text('Available: ${product.isAvailable ? "Yes" : "No"}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }
  
  void _confirmDeleteProduct(BuildContext context, Product product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Product'),
        content: Text('Are you sure you want to delete "${product.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Get.find<ProductController>().deleteProduct(product.id ?? '');
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}