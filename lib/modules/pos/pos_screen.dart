import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controllers/pos_controller.dart';
import '../../widgets/product_card.dart';
import '../../widgets/cart_item_card.dart';
import '../../widgets/checkout_dialog.dart';

class PosScreen extends StatelessWidget {
  const PosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PosController>();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Point of Sale'),
        backgroundColor: Colors.brown[700],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          Obx(() => Badge(
            label: Text('${controller.totalItemsInCart}'),
            isLabelVisible: controller.cartItemCount > 0,
            child: IconButton(
              icon: const Icon(Icons.shopping_cart),
              onPressed: () => _showCartBottomSheet(context, controller),
            ),
          )),
        ],
      ),
      body: Row(
        children: [
          // Products Section
          Expanded(
            flex: 2,
            child: Column(
              children: [
                // Search and Filter Section
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.grey[100],
                  child: Column(
                    children: [
                      // Search Bar
                      TextField(
                        onChanged: controller.setSearchQuery,
                        decoration: InputDecoration(
                          hintText: 'Search products...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Category Filter
                      SizedBox(
                        height: 40,
                        child: Obx(() => ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: controller.categories.length,
                          itemBuilder: (context, index) {
                            final category = controller.categories[index];
                            final isSelected = controller.selectedCategory.value == category;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: FilterChip(
                                label: Text(category),
                                selected: isSelected,
                                onSelected: (_) => controller.setCategory(category),
                                backgroundColor: Colors.white,
                                selectedColor: Colors.brown[100],
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
                      return const Center(child: CircularProgressIndicator());
                    }
                    
                    if (controller.filteredProducts.isEmpty) {
                      return const Center(
                        child: Text('No products found'),
                      );
                    }
                    
                    return GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 0.8,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: controller.filteredProducts.length,
                      itemBuilder: (context, index) {
                        final product = controller.filteredProducts[index];
                        return ProductCard(
                          product: product,
                          onTap: () => controller.addToCart(product),
                        );
                      },
                    );
                  }),
                ),
              ],
            ),
          ),
          // Cart Section
          Container(
            width: 400,
            decoration: BoxDecoration(
              color: Colors.grey[50],
              border: Border(
                left: BorderSide(color: Colors.grey[300]!),
              ),
            ),
            child: Column(
              children: [
                // Cart Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.brown[700],
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.shopping_cart, color: Colors.white),
                      const SizedBox(width: 8),
                      const Text(
                        'Cart',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Obx(() => Text(
                        '${controller.cartItemCount} items',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      )),
                    ],
                  ),
                ),
                // Cart Items
                Expanded(
                  child: Obx(() {
                    if (controller.cartItems.isEmpty) {
                      return const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.shopping_cart_outlined,
                              size: 64,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Cart is empty',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    
                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: controller.cartItems.length,
                      itemBuilder: (context, index) {
                        final item = controller.cartItems[index];
                        return CartItemCard(
                          item: item,
                          onQuantityChanged: (quantity) => 
                              controller.updateItemQuantity(item.productId, quantity),
                          onRemove: () => controller.removeFromCart(item.productId),
                        );
                      },
                    );
                  }),
                ),
                // Cart Summary
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      top: BorderSide(color: Colors.grey[300]!),
                    ),
                  ),
                  child: Column(
                    children: [
                      Obx(() => Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Subtotal:'),
                              Text('Rp ${controller.totalAmount.value.toStringAsFixed(0)}'),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Tax (10%):'),
                              Text('Rp ${controller.taxAmount.value.toStringAsFixed(0)}'),
                            ],
                          ),
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                'Rp ${controller.finalAmount.value.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ],
                      )),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: Obx(() => ElevatedButton(
                          onPressed: controller.cartItems.isEmpty 
                              ? null 
                              : () => _showCheckoutDialog(context, controller),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.brown[700],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Checkout',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: Obx(() => OutlinedButton(
                          onPressed: controller.cartItems.isEmpty 
                              ? null 
                              : controller.clearCart,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.brown[700],
                            side: BorderSide(color: Colors.brown[700]!),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Clear Cart'),
                        )),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showCartBottomSheet(BuildContext context, PosController controller) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.brown[700],
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.shopping_cart, color: Colors.white),
                  const SizedBox(width: 8),
                  const Text(
                    'Shopping Cart',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Obx(() {
                if (controller.cartItems.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.shopping_cart_outlined,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Cart is empty',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: controller.cartItems.length,
                  itemBuilder: (context, index) {
                    final item = controller.cartItems[index];
                    return CartItemCard(
                       item: item,
                       onQuantityChanged: (quantity) => 
                           controller.updateItemQuantity(item.productId, quantity),
                       onRemove: () => controller.removeFromCart(item.productId),
                     );
                  },
                );
              }),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: Colors.grey[300]!),
                ),
              ),
              child: Column(
                children: [
                  Obx(() => Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Subtotal:'),
                          Text('Rp ${controller.totalAmount.value.toStringAsFixed(0)}'),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Tax (10%):'),
                          Text('Rp ${controller.taxAmount.value.toStringAsFixed(0)}'),
                        ],
                      ),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            'Rp ${controller.finalAmount.value.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ],
                  )),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: Obx(() => ElevatedButton(
                      onPressed: controller.cartItems.isEmpty 
                          ? null 
                          : () {
                              Navigator.pop(context);
                              _showCheckoutDialog(context, controller);
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.brown[700],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Checkout',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCheckoutDialog(BuildContext context, PosController controller) {
    showDialog(
      context: context,
      builder: (context) => CheckoutDialog(
        controller: controller,
      ),
    );
  }
}