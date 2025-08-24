import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../core/models/product.dart';
import '../../core/services/firebase_service.dart';

class AddProductDialog extends StatefulWidget {
  final Product? product;

  const AddProductDialog({Key? key, this.product}) : super(key: key);

  @override
  _AddProductDialogState createState() => _AddProductDialogState();
}

class _AddProductDialogState extends State<AddProductDialog> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseService _firebaseService = Get.find<FirebaseService>();
  
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _stockController;
  
  String _selectedCategory = 'Coffee';
  bool _isAvailable = true;
  bool _isLoading = false;
  File? _selectedImage;
  String? _currentImageUrl;
  
  final List<String> _categories = ['Coffee', 'Tea', 'Snacks', 'Pastry'];
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    if (widget.product != null) {
      _nameController = TextEditingController(text: widget.product!.name);
      _descriptionController = TextEditingController(text: widget.product!.description ?? '');
      _priceController = TextEditingController(text: widget.product!.price.toString());
      _stockController = TextEditingController(text: widget.product!.stock?.toString() ?? '');
      _selectedCategory = widget.product!.category;
      _isAvailable = widget.product!.isAvailable;
      _currentImageUrl = widget.product!.imageUrl;
    } else {
      _nameController = TextEditingController();
      _descriptionController = TextEditingController();
      _priceController = TextEditingController();
      _stockController = TextEditingController();
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

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );
      
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to pick image: $e');
    }
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      String? imageUrl = _currentImageUrl;
      
      // Upload new image if selected
      if (_selectedImage != null) {
        imageUrl = await _firebaseService.uploadImage(_selectedImage!);
      }

      final product = Product(
        id: widget.product?.id,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty 
            ? '' 
            : _descriptionController.text.trim(),
        price: double.parse(_priceController.text),
        category: _selectedCategory,
        imageUrl: imageUrl,
        isAvailable: _isAvailable,
        stock: _stockController.text.trim().isEmpty 
            ? 0 
            : int.parse(_stockController.text),
        createdAt: widget.product?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      Navigator.of(context).pop(product);
    } catch (e) {
      Get.snackbar('Error', 'Failed to save product: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: 500,
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.product == null ? 'Add Product' : 'Edit Product',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            
            // Form Content
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image Section
                      Center(
                        child: GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: _selectedImage != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.file(
                                      _selectedImage!,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : _currentImageUrl != null && _currentImageUrl!.isNotEmpty
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.network(
                                          _currentImageUrl!,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                            return _buildImagePlaceholder();
                                          },
                                        ),
                                      )
                                    : _buildImagePlaceholder(),
                          ),
                        ),
                      ),
                      
                      SizedBox(height: 20),
                      
                      // Product Name
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Product Name *',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Product name is required';
                          }
                          return null;
                        },
                      ),
                      
                      SizedBox(height: 16),
                      
                      // Description
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      
                      SizedBox(height: 16),
                      
                      // Price and Stock Row
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _priceController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                              ],
                              decoration: InputDecoration(
                                labelText: 'Price (Rp) *',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Price is required';
                                }
                                final price = double.tryParse(value);
                                if (price == null || price <= 0) {
                                  return 'Enter valid price';
                                }
                                return null;
                              },
                            ),
                          ),
                          
                          SizedBox(width: 12),
                          
                          Expanded(
                            child: TextFormField(
                              controller: _stockController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              decoration: InputDecoration(
                                labelText: 'Stock',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              validator: (value) {
                                if (value != null && value.trim().isNotEmpty) {
                                  final stock = int.tryParse(value);
                                  if (stock == null || stock < 0) {
                                    return 'Enter valid stock';
                                  }
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      
                      SizedBox(height: 16),
                      
                      // Category Dropdown
                      DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        decoration: InputDecoration(
                          labelText: 'Category *',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Available',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Switch(
                            value: _isAvailable,
                            onChanged: (value) {
                              setState(() {
                                _isAvailable = value;
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // Action Buttons
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey[300]!)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                      child: Text('Cancel'),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveProduct,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
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
                          : Text(widget.product == null ? 'Add Product' : 'Update Product'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.add_photo_alternate,
          size: 40,
          color: Colors.grey[400],
        ),
        SizedBox(height: 8),
        Text(
          'Add Photo',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}