import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../models/user_model.dart';
import '../models/product.dart';
import '../models/transaction_model.dart';

class FirestoreService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Collections
  static const String usersCollection = 'users';
  static const String productsCollection = 'products';
  static const String transactionsCollection = 'transactions';
  static const String categoriesCollection = 'categories';

  // User Operations
  Future<void> createUser(UserModel user) async {
    try {
      await _firestore
          .collection(usersCollection)
          .doc(user.id)
          .set(user.toMap());
    } catch (e) {
      throw Exception('Failed to create user: $e');
    }
  }

  Future<UserModel?> getUser(String userId) async {
    try {
      final doc = await _firestore
          .collection(usersCollection)
          .doc(userId)
          .get();
      
      if (doc.exists && doc.data() != null) {
        return UserModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user: $e');
    }
  }

  Future<UserModel?> getUserByEmail(String email) async {
    try {
      final query = await _firestore
          .collection(usersCollection)
          .where('email', isEqualTo: email)
          .limit(1)
          .get();
      
      if (query.docs.isNotEmpty) {
        final doc = query.docs.first;
        return UserModel.fromMap(doc.data(), doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user by email: $e');
    }
  }

  Future<void> updateUser(String userId, Map<String, dynamic> data) async {
    try {
      data['updatedAt'] = DateTime.now().millisecondsSinceEpoch;
      await _firestore
          .collection(usersCollection)
          .doc(userId)
          .update(data);
    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }

  Stream<List<UserModel>> getUsersStream() {
    return _firestore
        .collection(usersCollection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => UserModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Product Operations
  Future<void> createProduct(Product product) async {
    try {
      await _firestore
          .collection(productsCollection)
          .add(product.toMap());
    } catch (e) {
      throw Exception('Failed to create product: $e');
    }
  }

  Future<Product?> getProduct(String productId) async {
    try {
      final doc = await _firestore
          .collection(productsCollection)
          .doc(productId)
          .get();
      
      if (doc.exists && doc.data() != null) {
        return Product.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get product: $e');
    }
  }

  Future<void> updateProduct(String productId, Map<String, dynamic> data) async {
    try {
      data['updatedAt'] = DateTime.now().millisecondsSinceEpoch;
      await _firestore
          .collection(productsCollection)
          .doc(productId)
          .update(data);
    } catch (e) {
      throw Exception('Failed to update product: $e');
    }
  }

  Future<void> deleteProduct(String productId) async {
    try {
      await _firestore
          .collection(productsCollection)
          .doc(productId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete product: $e');
    }
  }

  Stream<List<Product>> getProductsStream() {
    return _firestore
        .collection(productsCollection)
        .where('isAvailable', isEqualTo: true)
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Product.fromMap(doc.data(), doc.id))
            .toList().cast<Product>());
  }

  Stream<List<Product>> getProductsByCategoryStream(String category) {
    return _firestore
        .collection(productsCollection)
        .where('category', isEqualTo: category)
        .where('isAvailable', isEqualTo: true)
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Product.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Transaction Operations
  Future<void> createTransaction(TransactionModel transaction) async {
    try {
      await _firestore
          .collection(transactionsCollection)
          .add(transaction.toMap());
    } catch (e) {
      throw Exception('Failed to create transaction: $e');
    }
  }

  Future<TransactionModel?> getTransaction(String transactionId) async {
    try {
      final doc = await _firestore
          .collection(transactionsCollection)
          .doc(transactionId)
          .get();
      
      if (doc.exists && doc.data() != null) {
        return TransactionModel.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get transaction: $e');
    }
  }

  Stream<List<TransactionModel>> getTransactionsStream() {
    return _firestore
        .collection(transactionsCollection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TransactionModel.fromMap(doc.data()))
            .toList());
  }

  Stream<List<TransactionModel>> getTransactionsByUserStream(String userId) {
    return _firestore
        .collection(transactionsCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TransactionModel.fromMap(doc.data()))
            .toList());
  }

  // Dashboard Analytics Methods
  Future<List<TransactionModel>> getTransactionsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final query = await _firestore
          .collection(transactionsCollection)
          .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('createdAt', isLessThan: Timestamp.fromDate(endDate))
          .orderBy('createdAt', descending: true)
          .get();
      
      return query.docs
          .map((doc) => TransactionModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to get transactions by date range: $e');
    }
  }

  Future<List<TransactionModel>> getRecentTransactions({int limit = 10}) async {
    try {
      final query = await _firestore
          .collection(transactionsCollection)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();
      
      return query.docs
          .map((doc) => TransactionModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to get recent transactions: $e');
    }
  }

  // Category Operations
  Future<List<String>> getCategories() async {
    try {
      final query = await _firestore
          .collection(productsCollection)
          .get();
      
      final categories = <String>{};
      for (final doc in query.docs) {
        final data = doc.data();
        if (data['category'] != null) {
          categories.add(data['category']);
        }
      }
      
      return categories.toList()..sort();
    } catch (e) {
      throw Exception('Failed to get categories: $e');
    }
  }

  // Initialize default data
  Future<void> initializeDefaultData() async {
    try {
      // Add delay to ensure Firebase is fully initialized
      await Future.delayed(Duration(milliseconds: 1000));
      
      // Check if admin user exists
      final adminUser = await getUserByEmail('admin@kopikita.com');
      if (adminUser == null) {
        await _createDefaultUser(
          email: 'admin@kopikita.com',
          password: 'admin123',
          name: 'Administrator',
          role: 'admin',
        );
      }
      
      // Create cashier user if not exists
      final cashierUser = await getUserByEmail('cashier@kopikita.com');
      if (cashierUser == null) {
        await _createDefaultUser(
          email: 'cashier@kopikita.com',
          password: 'cashier123',
          name: 'Cashier',
          role: 'cashier',
        );
      }
      
      // Check if products exist
      final productsQuery = await _firestore
          .collection(productsCollection)
          .limit(1)
          .get();
      
      if (productsQuery.docs.isEmpty) {
        await _createDefaultProducts();
      }
    } catch (e) {
      print('Error in initializeDefaultData: $e');
    }
  }
  
  Future<void> _createDefaultUser({
    required String email,
    required String password,
    required String name,
    required String role,
  }) async {
    try {
      // Create user in Firebase Auth first
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Create default user in Firestore
      final defaultUser = UserModel(
        id: userCredential.user!.uid,
        email: email,
        name: name,
        role: role,
        createdAt: DateTime.now(),
      );
      await createUser(defaultUser);
      
      print('Default $role user created successfully');
    } catch (authError) {
      // If user already exists in Auth but not in Firestore
      if (authError.toString().contains('email-already-in-use')) {
        try {
          // Sign in to get the user ID
          final signInResult = await _auth.signInWithEmailAndPassword(
            email: email,
            password: password,
          );
          
          // Create user in Firestore with the existing Auth user ID
          final defaultUser = UserModel(
            id: signInResult.user!.uid,
            email: email,
            name: name,
            role: role,
            createdAt: DateTime.now(),
          );
          await createUser(defaultUser);
          
          // Sign out after creating the user
          await _auth.signOut();
          
          print('Default $role user synced with existing Auth user');
        } catch (e) {
          print('Error syncing $role user: $e');
        }
      } else {
        print('Error creating $role user in Auth: $authError');
      }
    }
  }
  
  Future<void> _createDefaultProducts() async {
    try {
      // Create default products
      final defaultProducts = [
        Product(
          id: '',
          name: 'Espresso',
          description: 'Kopi espresso klasik',
          price: 15000,
          category: 'Coffee',
          stock: 100,
          createdAt: DateTime.now(),
        ),
        Product(
          id: '',
          name: 'Cappuccino',
          description: 'Kopi cappuccino dengan foam susu',
          price: 25000,
          category: 'Coffee',
          stock: 100,
          createdAt: DateTime.now(),
        ),
        Product(
          id: '',
          name: 'Latte',
          description: 'Kopi latte dengan susu steamed',
          price: 28000,
          category: 'Coffee',
          stock: 100,
          createdAt: DateTime.now(),
        ),
      ];

      for (final product in defaultProducts) {
        await createProduct(product);
      }
      
      print('Default products created successfully');
    } catch (e) {
      print('Error creating default products: $e');
    }
  }
}