import 'package:get/get.dart';
import '../../../core/models/product.dart';
import '../../../core/models/transaction_model.dart';
import '../../../core/services/firestore_service.dart';
import '../../../core/services/auth_service.dart';
import 'package:uuid/uuid.dart';

class PosController extends GetxController {
  FirestoreService get _firestore => Get.find<FirestoreService>();
  final AuthService _auth = Get.find<AuthService>();
  final Uuid _uuid = Uuid();

  // Observable variables
  final RxList<Product> products = <Product>[].obs;
  final RxList<Product> filteredProducts = <Product>[].obs;
  final RxList<TransactionItem> cartItems = <TransactionItem>[].obs;
  final RxString selectedCategory = 'All'.obs;
  final RxList<String> categories = <String>['All'].obs;
  final RxString searchQuery = ''.obs;
  final RxBool isLoading = false.obs;
  final RxDouble totalAmount = 0.0.obs;
  final RxDouble taxAmount = 0.0.obs;
  final RxDouble finalAmount = 0.0.obs;
  final RxString paymentMethod = 'cash'.obs;

  // Tax rate (10%)
  final double taxRate = 0.10;

  @override
  void onInit() {
    super.onInit();
    loadProducts();
    loadCategories();
    
    // Listen to cart changes to update totals
    ever(cartItems, (_) => calculateTotals());
  }

  // Load products from Firestore
  void loadProducts() {
    isLoading.value = true;
    _firestore.getProductsStream().listen((productList) {
      products.value = productList;
      filterProducts();
      isLoading.value = false;
    });
  }

  // Load categories
  void loadCategories() async {
    try {
      final categoryList = await _firestore.getCategories();
      categories.value = ['All', ...categoryList];
    } catch (e) {
      Get.snackbar('Error', 'Failed to load categories: $e');
    }
  }

  // Filter products based on category and search
  void filterProducts() {
    var filtered = products.where((product) {
      final matchesCategory = selectedCategory.value == 'All' || 
                            product.category == selectedCategory.value;
      final matchesSearch = searchQuery.value.isEmpty ||
                          product.name.toLowerCase().contains(searchQuery.value.toLowerCase());
      return matchesCategory && matchesSearch && product.isAvailable;
    }).toList();
    
    filteredProducts.value = filtered;
  }

  // Set selected category
  void setCategory(String category) {
    selectedCategory.value = category;
    filterProducts();
  }

  // Set search query
  void setSearchQuery(String query) {
    searchQuery.value = query;
    filterProducts();
  }

  // Add product to cart
  void addToCart(Product product) {
    final existingIndex = cartItems.indexWhere(
      (item) => item.productId == product.id!
    );

    if (existingIndex >= 0) {
      // Update existing item
      final existingItem = cartItems[existingIndex];
      final newQuantity = existingItem.quantity + 1;
      final newSubtotal = product.price * newQuantity;
      
      cartItems[existingIndex] = existingItem.copyWith(
        quantity: newQuantity,
        subtotal: newSubtotal,
      );
    } else {
      // Add new item
      cartItems.add(TransactionItem(
        productId: product.id!,
        productName: product.name,
        price: product.price,
        quantity: 1,
        subtotal: product.price,
      ));
    }
  }

  // Remove product from cart
  void removeFromCart(String productId) {
    cartItems.removeWhere((item) => item.productId == productId);
  }

  // Update item quantity
  void updateItemQuantity(String productId, int quantity) {
    if (quantity <= 0) {
      removeFromCart(productId);
      return;
    }

    final index = cartItems.indexWhere((item) => item.productId == productId);
    if (index >= 0) {
      final item = cartItems[index];
      final newSubtotal = item.price * quantity;
      
      cartItems[index] = item.copyWith(
        quantity: quantity,
        subtotal: newSubtotal,
      );
    }
  }

  // Calculate totals
  void calculateTotals() {
    totalAmount.value = cartItems.fold(0.0, (sum, item) => sum + item.subtotal);
    taxAmount.value = totalAmount.value * taxRate;
    finalAmount.value = totalAmount.value + taxAmount.value;
  }

  // Set payment method
  void setPaymentMethod(String method) {
    paymentMethod.value = method;
  }

  // Process transaction
  Future<void> processTransaction() async {
    if (cartItems.isEmpty) {
      Get.snackbar('Error', 'Cart is empty');
      return;
    }

    if (_auth.currentUser == null) {
      Get.snackbar('Error', 'User not authenticated');
      return;
    }

    try {
      isLoading.value = true;

      final transaction = TransactionModel(
        id: _uuid.v4(),
        userId: _auth.currentUser!.id,
        items: cartItems.toList(),
        totalAmount: totalAmount.value,
        taxAmount: taxAmount.value,
        finalAmount: finalAmount.value,
        paymentMethod: paymentMethod.value,
        createdAt: DateTime.now(),
      );

      await _firestore.createTransaction(transaction);
      
      // Clear cart after successful transaction
      clearCart();
      
      Get.snackbar(
        'Success', 
        'Transaction completed successfully',
        snackPosition: SnackPosition.TOP,
      );
      
    } catch (e) {
      Get.snackbar('Error', 'Failed to process transaction: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Clear cart
  void clearCart() {
    cartItems.clear();
    paymentMethod.value = 'cash';
  }

  // Get cart item count
  int get cartItemCount => cartItems.length;

  // Get total items in cart
  int get totalItemsInCart => cartItems.fold(0, (sum, item) => sum + item.quantity);
}