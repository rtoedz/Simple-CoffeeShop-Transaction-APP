import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/models/product.dart';
import '../core/themes/app_theme.dart';
import '../modules/menu/controllers/product_controller.dart';

class AddProductDialog extends StatefulWidget {
  final Product? product;
  
  const AddProductDialog({super.key, this.product});

  @override
  State<AddProductDialog> createState() => _AddProductDialogState();
}

class _AddProductDialogState extends State<AddProductDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  
  String _selectedCategory = 'Coffee';
  bool _isAvailable = true;
  bool _isLoading = false;
  
  final List<String> _categories = [
    'Coffee',
    'Tea',
    'Pastry',
    'Snack',
    'Beverage',
    'Other',
  ];
  
  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _nameController.text = widget.product!.name;
      _descriptionController.text = widget.product!.description;
      _priceController.text = widget.product!.price.toString();
      _stockController.text = widget.product!.stock.toString();
      _selectedCategory = widget.product!.category;
      _isAvailable = widget.product!.isAvailable;
    }
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.product != null;
    
    return AlertDialog(
      title: Text(isEditing ? 'Edit Product' : 'Add New Product'),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Product Name
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Product Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: Icon(Icons.coffee),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter product name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                // Description
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: Icon(Icons.description),
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter description';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                // Price
                TextFormField(
                  controller: _priceController,
                  decoration: InputDecoration(
                    labelText: 'Price (Rp)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: Icon(Icons.attach_money),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter price';
                    }
                    final price = double.tryParse(value);
                    if (price == null || price <= 0) {
                      return 'Please enter valid price';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                // Stock
                TextFormField(
                  controller: _stockController,
                  decoration: InputDecoration(
                    labelText: 'Stock',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: Icon(Icons.inventory),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter stock quantity';
                    }
                    final stock = int.tryParse(value);
                    if (stock == null || stock < 0) {
                      return 'Please enter valid stock quantity';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                // Category Dropdown
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: Icon(Icons.category),
                  ),
                  items: _categories.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value!;
                    });
                  },
                ),
                SizedBox(height: 16),
                // Availability Switch
                Row(
                  children: [
                    Icon(Icons.visibility, color: Colors.grey[600]),
                    SizedBox(width: 12),
                    Text('Available for sale'),
                    Spacer(),
                    Switch(
                      value: _isAvailable,
                      onChanged: (value) {
                        setState(() {
                          _isAvailable = value;
                        });
                      },
                      activeColor: AppTheme.primaryColor,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _saveProduct,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
          ),
          child: _isLoading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(isEditing ? 'Update' : 'Add'),
        ),
      ],
    );
  }
  
  void _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final controller = Get.find<ProductController>();
      
      if (widget.product != null) {
        // Update existing product
        await controller.updateProduct(widget.product!.id ?? '', {
          'name': _nameController.text.trim(),
          'description': _descriptionController.text.trim(),
          'price': double.parse(_priceController.text),
          'stock': int.parse(_stockController.text),
          'category': _selectedCategory,
          'isAvailable': _isAvailable,
        });
      } else {
        // Create new product
        final product = Product(
          id: '',
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          price: double.parse(_priceController.text),
          stock: int.parse(_stockController.text),
          category: _selectedCategory,
          isAvailable: _isAvailable,
          createdAt: DateTime.now(),
        );
        
        await controller.addProduct(product);
      }
      
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to save product: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}