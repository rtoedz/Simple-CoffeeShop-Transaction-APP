import 'package:flutter/material.dart';
import '../core/models/product.dart';
import '../core/themes/app_theme.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onToggleAvailability;
  final bool showActions;
  final bool showAddToCart;
  final bool showAddButton;
  final VoidCallback? onAddToCart;
  
  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onToggleAvailability,
    this.showActions = true,
    this.showAddToCart = false,
    this.showAddButton = true,
    this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image Placeholder
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.primaryColor.withValues(alpha: 0.1),
                      AppTheme.primaryColor.withValues(alpha: 0.3),
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Icon(
                        Icons.coffee,
                        size: 48,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    // Availability Badge
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: product.isAvailable ? Colors.green : Colors.red,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          product.isAvailable ? 'Available' : 'Unavailable',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    // Stock Badge
                    if (product.stock <= 10)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: product.stock == 0 ? Colors.red : Colors.orange,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            product.stock == 0 ? 'Out of Stock' : 'Low Stock',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            // Product Info
            Expanded(
              flex: 2,
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Name
                    Text(
                      product.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    // Category
                    Text(
                      product.category,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 4),
                    // Description
                    Text(
                      product.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[700],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Spacer(),
                    // Price and Actions
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Rp ${product.price.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        if (showAddToCart && onAddToCart != null)
                          IconButton(
                            icon: Icon(Icons.add_shopping_cart),
                            onPressed: product.isAvailable && product.stock > 0 ? onAddToCart : null,
                            color: AppTheme.primaryColor,
                            iconSize: 20,
                          ),
                        if (showActions)
                          PopupMenuButton<String>(
                            onSelected: (value) {
                              switch (value) {
                                case 'edit':
                                  onEdit?.call();
                                  break;
                                case 'delete':
                                  onDelete?.call();
                                  break;
                                case 'toggle':
                                  onToggleAvailability?.call();
                                  break;
                              }
                            },
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                value: 'edit',
                                child: Row(
                                  children: [
                                    Icon(Icons.edit, size: 16),
                                    SizedBox(width: 8),
                                    Text('Edit'),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                value: 'toggle',
                                child: Row(
                                  children: [
                                    Icon(
                                      product.isAvailable ? Icons.visibility_off : Icons.visibility,
                                      size: 16,
                                    ),
                                    SizedBox(width: 8),
                                    Text(product.isAvailable ? 'Hide' : 'Show'),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(Icons.delete, size: 16, color: Colors.red),
                                    SizedBox(width: 8),
                                    Text('Delete', style: TextStyle(color: Colors.red)),
                                  ],
                                ),
                              ),
                            ],
                            child: Icon(
                              Icons.more_vert,
                              size: 20,
                              color: Colors.grey[600],
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}