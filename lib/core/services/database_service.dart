import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';
import '../models/transaction.dart';
import '../models/user_model.dart';

class DatabaseService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Collections
  CollectionReference get _users => _firestore.collection('users');
  CollectionReference get _products => _firestore.collection('products');
  CollectionReference get _transactions => _firestore.collection('transactions');
  
  // User operations
  Future<void> createUser(UserModel user) async {
    try {
      await _users.doc(user.id).set(user.toMap());
    } catch (e) {
      Get.snackbar('Error', 'Failed to create user: ${e.toString()}');
      rethrow;
    }
  }
  
  Future<UserModel?> getUser(String userId) async {
    try {
      final doc = await _users.doc(userId).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      Get.snackbar('Error', 'Failed to get user: ${e.toString()}');
      return null;
    }
  }
  
  // Product operations
  Future<void> addProduct(Product product) async {
    try {
      await _products.add(product.toMap());
      Get.snackbar('Success', 'Product added successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to add product: ${e.toString()}');
      rethrow;
    }
  }
  
  Future<void> updateProduct(String productId, Product product) async {
    try {
      await _products.doc(productId).update(product.toMap());
      Get.snackbar('Success', 'Product updated successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to update product: ${e.toString()}');
      rethrow;
    }
  }
  
  Future<void> deleteProduct(String productId) async {
    try {
      await _products.doc(productId).delete();
      Get.snackbar('Success', 'Product deleted successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete product: ${e.toString()}');
      rethrow;
    }
  }
  
  Stream<List<Product>> getProducts() {
    return _products.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Product.fromMap({...data, 'id': doc.id});
      }).toList();
    });
  }
  
  Future<List<Product>> getProductsByCategory(String category) async {
    try {
      final querySnapshot = await _products
          .where('category', isEqualTo: category)
          .get();
      
      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Product.fromMap({...data, 'id': doc.id});
      }).toList();
    } catch (e) {
      Get.snackbar('Error', 'Failed to get products: ${e.toString()}');
      return [];
    }
  }
  
  // Transaction operations
  Future<String> addTransaction(TransactionModel transaction) async {
    try {
      final docRef = await _transactions.add(transaction.toMap());
      Get.snackbar('Success', 'Transaction completed successfully');
      return docRef.id;
    } catch (e) {
      Get.snackbar('Error', 'Failed to save transaction: ${e.toString()}');
      rethrow;
    }
  }
  
  Stream<List<TransactionModel>> getTransactions() {
    return _transactions
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return TransactionModel.fromMap({...data, 'id': doc.id});
      }).toList();
    });
  }
  
  Future<List<TransactionModel>> getTransactionsByDateRange(
      DateTime startDate, DateTime endDate) async {
    try {
      final querySnapshot = await _transactions
          .where('timestamp', isGreaterThanOrEqualTo: startDate)
          .where('timestamp', isLessThanOrEqualTo: endDate)
          .orderBy('timestamp', descending: true)
          .get();
      
      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return TransactionModel.fromMap({...data, 'id': doc.id});
      }).toList();
    } catch (e) {
      Get.snackbar('Error', 'Failed to get transactions: ${e.toString()}');
      return [];
    }
  }
  
  // Analytics
  Future<Map<String, dynamic>> getDailySales(DateTime date) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(Duration(days: 1));
      
      final querySnapshot = await _transactions
          .where('timestamp', isGreaterThanOrEqualTo: startOfDay)
          .where('timestamp', isLessThan: endOfDay)
          .get();
      
      double totalSales = 0;
      int totalTransactions = querySnapshot.docs.length;
      
      for (var doc in querySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        totalSales += (data['total'] as num).toDouble();
      }
      
      return {
        'totalSales': totalSales,
        'totalTransactions': totalTransactions,
        'averageTransaction': totalTransactions > 0 ? totalSales / totalTransactions : 0,
      };
    } catch (e) {
      Get.snackbar('Error', 'Failed to get daily sales: ${e.toString()}');
      return {
        'totalSales': 0.0,
        'totalTransactions': 0,
        'averageTransaction': 0.0,
      };
    }
  }
}