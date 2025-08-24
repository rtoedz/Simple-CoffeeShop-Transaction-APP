import 'package:get/get.dart';
import '../../../core/services/firestore_service.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/models/transaction_model.dart';
import 'package:intl/intl.dart';

class DashboardStats {
  final double totalSales;
  final int totalTransactions;
  final int totalProductsSold;
  final double averageOrderValue;
  final double salesTrend;
  final double transactionsTrend;
  final double productsTrend;
  final double avgOrderTrend;

  DashboardStats({
    this.totalSales = 0.0,
    this.totalTransactions = 0,
    this.totalProductsSold = 0,
    this.averageOrderValue = 0.0,
    this.salesTrend = 0.0,
    this.transactionsTrend = 0.0,
    this.productsTrend = 0.0,
    this.avgOrderTrend = 0.0,
  });
}

class WeeklyData {
  final String day;
  final double sales;
  final int transactions;

  WeeklyData({
    required this.day,
    required this.sales,
    required this.transactions,
  });
}

class TopProduct {
  final String name;
  final int quantity;
  final double revenue;

  TopProduct({
    required this.name,
    required this.quantity,
    required this.revenue,
  });
}

class DashboardController extends GetxController {
  FirestoreService get _firestore => Get.find<FirestoreService>();
  final AuthService _authService = Get.find<AuthService>();

  // Observable variables
  final RxBool isLoading = false.obs;
  final Rx<DashboardStats> todayStats = DashboardStats().obs;
  final RxList<WeeklyData> weeklyData = <WeeklyData>[].obs;
  final RxList<TransactionModel> recentTransactions = <TransactionModel>[].obs;
  final RxList<TopProduct> topProducts = <TopProduct>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadDashboardData();
  }

  // Load all dashboard data
  Future<void> loadDashboardData() async {
    isLoading.value = true;
    try {
      await Future.wait([
        loadTodayStats(),
        loadWeeklyData(),
        loadRecentTransactions(),
        loadTopProducts(),
      ]);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load dashboard data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Refresh all data
  Future<void> refreshData() async {
    await loadDashboardData();
  }

  // Load today's statistics
  Future<void> loadTodayStats() async {
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));
      
      // Get today's transactions
      final todayTransactions = await _firestore.getTransactionsByDateRange(
        startOfDay,
        endOfDay,
      );
      
      // Get yesterday's transactions for trend calculation
      final yesterday = startOfDay.subtract(const Duration(days: 1));
      final yesterdayTransactions = await _firestore.getTransactionsByDateRange(
        yesterday,
        startOfDay,
      );
      
      // Calculate today's stats
      final totalSales = todayTransactions.fold<double>(
        0.0,
        (sum, transaction) => sum + transaction.finalAmount,
      );
      
      final totalTransactions = todayTransactions.length;
      
      final totalProductsSold = todayTransactions.fold<int>(
        0,
        (sum, transaction) => sum + transaction.items.fold<int>(
          0,
          (itemSum, item) => itemSum + item.quantity,
        ),
      );
      
      final averageOrderValue = totalTransactions > 0 
          ? totalSales / totalTransactions 
          : 0.0;
      
      // Calculate trends (percentage change from yesterday)
      final yesterdaySales = yesterdayTransactions.fold<double>(
        0.0,
        (sum, transaction) => sum + transaction.finalAmount,
      );
      
      final yesterdayTransactionsCount = yesterdayTransactions.length;
      
      final yesterdayProductsSold = yesterdayTransactions.fold<int>(
        0,
        (sum, transaction) => sum + transaction.items.fold<int>(
          0,
          (itemSum, item) => itemSum + item.quantity,
        ),
      );
      
      final yesterdayAvgOrder = yesterdayTransactionsCount > 0 
          ? yesterdaySales / yesterdayTransactionsCount 
          : 0.0;
      
      final salesTrend = yesterdaySales > 0 
          ? ((totalSales - yesterdaySales) / yesterdaySales) * 100 
          : 0.0;
      
      final transactionsTrend = yesterdayTransactionsCount > 0 
          ? ((totalTransactions - yesterdayTransactionsCount) / yesterdayTransactionsCount) * 100 
          : 0.0;
      
      final productsTrend = yesterdayProductsSold > 0 
          ? ((totalProductsSold - yesterdayProductsSold) / yesterdayProductsSold) * 100 
          : 0.0;
      
      final avgOrderTrend = yesterdayAvgOrder > 0 
          ? ((averageOrderValue - yesterdayAvgOrder) / yesterdayAvgOrder) * 100 
          : 0.0;
      
      todayStats.value = DashboardStats(
        totalSales: totalSales,
        totalTransactions: totalTransactions,
        totalProductsSold: totalProductsSold,
        averageOrderValue: averageOrderValue,
        salesTrend: salesTrend,
        transactionsTrend: transactionsTrend,
        productsTrend: productsTrend,
        avgOrderTrend: avgOrderTrend,
      );
    } catch (e) {
      print('Error loading today stats: $e');
    }
  }

  // Load weekly data for chart
  Future<void> loadWeeklyData() async {
    try {
      final now = DateTime.now();
      final weeklyDataList = <WeeklyData>[];
      
      for (int i = 6; i >= 0; i--) {
        final date = now.subtract(Duration(days: i));
        final startOfDay = DateTime(date.year, date.month, date.day);
        final endOfDay = startOfDay.add(const Duration(days: 1));
        
        final dayTransactions = await _firestore.getTransactionsByDateRange(
          startOfDay,
          endOfDay,
        );
        
        final daySales = dayTransactions.fold<double>(
          0.0,
          (sum, transaction) => sum + transaction.finalAmount,
        );
        
        weeklyDataList.add(WeeklyData(
          day: DateFormat('E').format(date), // Mon, Tue, etc.
          sales: daySales,
          transactions: dayTransactions.length,
        ));
      }
      
      weeklyData.value = weeklyDataList;
    } catch (e) {
      print('Error loading weekly data: $e');
    }
  }

  // Load recent transactions
  Future<void> loadRecentTransactions() async {
    try {
      final transactions = await _firestore.getRecentTransactions(limit: 10);
      recentTransactions.value = transactions;
    } catch (e) {
      print('Error loading recent transactions: $e');
    }
  }

  // Load top products
  Future<void> loadTopProducts() async {
    try {
      final now = DateTime.now();
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      final startOfWeekDay = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
      final endOfWeek = startOfWeekDay.add(const Duration(days: 7));
      
      final weekTransactions = await _firestore.getTransactionsByDateRange(
        startOfWeekDay,
        endOfWeek,
      );
      
      // Calculate product sales
      final Map<String, TopProduct> productSales = {};
      
      for (final transaction in weekTransactions) {
        for (final item in transaction.items) {
          if (productSales.containsKey(item.productName)) {
            final existing = productSales[item.productName]!;
            productSales[item.productName] = TopProduct(
              name: item.productName,
              quantity: existing.quantity + item.quantity,
              revenue: existing.revenue + item.subtotal,
            );
          } else {
            productSales[item.productName] = TopProduct(
              name: item.productName,
              quantity: item.quantity,
              revenue: item.subtotal,
            );
          }
        }
      }
      
      // Sort by quantity and take top 5
      final sortedProducts = productSales.values.toList()
        ..sort((a, b) => b.quantity.compareTo(a.quantity));
      
      topProducts.value = sortedProducts.take(5).toList();
    } catch (e) {
      print('Error loading top products: $e');
    }
  }

  // Get current date string
  String getCurrentDateString() {
    return DateFormat('EEEE, MMMM d, y').format(DateTime.now());
  }

  // Format currency
  String formatCurrency(double amount) {
    return 'Rp ${amount.toStringAsFixed(0)}';
  }

  // Format trend percentage
  String formatTrend(double trend) {
    final sign = trend >= 0 ? '+' : '';
    return '$sign${trend.toStringAsFixed(1)}%';
  }
  
  Future<void> logout() async {
    try {
      await _authService.signOut();
      Get.offAllNamed('/login');
    } catch (e) {
      Get.snackbar(
        'Error',
        'Logout gagal: ${e.toString()}',
      );
    }
  }
}