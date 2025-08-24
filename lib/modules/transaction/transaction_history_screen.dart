import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../core/services/database_service.dart';
import '../../core/models/transaction.dart';

class TransactionHistoryController extends GetxController {
  final DatabaseService _databaseService = Get.find<DatabaseService>();
  
  final transactions = <TransactionModel>[].obs;
  final isLoading = true.obs;
  final selectedDateRange = Rxn<DateTimeRange>();
  final searchQuery = ''.obs;
  final selectedPaymentMethod = 'All'.obs;
  
  final paymentMethods = <String>['All', 'Cash', 'Card', 'Digital Wallet'].obs;

  @override
  void onInit() {
    super.onInit();
    loadTransactions();
  }

  void loadTransactions() {
    isLoading.value = true;
    _databaseService.getTransactions().listen((transactionList) {
      transactions.value = transactionList;
      isLoading.value = false;
    });
  }

  List<TransactionModel> get filteredTransactions {
    var filtered = transactions.where((transaction) {
      // Date filter
      if (selectedDateRange.value != null) {
        final transactionDate = transaction.timestamp;
        final startDate = selectedDateRange.value!.start;
        final endDate = selectedDateRange.value!.end.add(Duration(days: 1));
        
        if (transactionDate.isBefore(startDate) || transactionDate.isAfter(endDate)) {
          return false;
        }
      }
      
      // Payment method filter
      if (selectedPaymentMethod.value != 'All' && 
          transaction.paymentMethod != selectedPaymentMethod.value) {
        return false;
      }
      
      // Search filter
      if (searchQuery.value.isNotEmpty) {
        final query = searchQuery.value.toLowerCase();
        final matchesId = transaction.id?.toLowerCase().contains(query) ?? false;
        final matchesCashier = transaction.cashierName.toLowerCase().contains(query);
        final matchesItems = transaction.items.any((item) => 
            item.productName.toLowerCase().contains(query));
        
        if (!matchesId && !matchesCashier && !matchesItems) {
          return false;
        }
      }
      
      return true;
    }).toList();
    
    // Sort by timestamp (newest first)
    filtered.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    
    return filtered;
  }

  double get totalRevenue {
    return filteredTransactions.fold(0.0, (sum, transaction) => sum + transaction.total);
  }

  int get totalTransactions => filteredTransactions.length;

  double get averageTransaction {
    if (filteredTransactions.isEmpty) return 0.0;
    return totalRevenue / totalTransactions;
  }

  Future<void> selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(Duration(days: 365)),
      lastDate: DateTime.now(),
      initialDateRange: selectedDateRange.value,
    );
    
    if (picked != null) {
      selectedDateRange.value = picked;
    }
  }

  void clearDateFilter() {
    selectedDateRange.value = null;
  }

  void exportTransactions() {
    // TODO: Implement export functionality
    Get.snackbar(
      'Export',
      'Export functionality will be implemented soon',
      duration: Duration(seconds: 2),
    );
  }
}

class TransactionHistoryScreen extends StatelessWidget {
  final TransactionHistoryController controller = Get.find<TransactionHistoryController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Transaction History'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.file_download),
            onPressed: controller.exportTransactions,
          ),
        ],
      ),
      body: Column(
        children: [
          // Statistics Cards
          Container(
            padding: EdgeInsets.all(16),
            color: Colors.white,
            child: Obx(() => Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Total Revenue',
                    'Rp ${controller.totalRevenue.toStringAsFixed(0)}',
                    Icons.attach_money,
                    Colors.green,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Transactions',
                    '${controller.totalTransactions}',
                    Icons.receipt,
                    Colors.blue,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Average',
                    'Rp ${controller.averageTransaction.toStringAsFixed(0)}',
                    Icons.trending_up,
                    Colors.orange,
                  ),
                ),
              ],
            )),
          ),
          
          // Filters Section
          Container(
            padding: EdgeInsets.all(16),
            color: Colors.grey[50],
            child: Column(
              children: [
                // Search Bar
                TextField(
                  onChanged: (value) => controller.searchQuery.value = value,
                  decoration: InputDecoration(
                    hintText: 'Search transactions...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                
                SizedBox(height: 12),
                
                // Filter Row
                Row(
                  children: [
                    // Date Range Filter
                    Expanded(
                      child: Obx(() => OutlinedButton.icon(
                        onPressed: () => controller.selectDateRange(context),
                        icon: Icon(Icons.date_range),
                        label: Text(
                          controller.selectedDateRange.value != null
                              ? '${DateFormat('MMM dd').format(controller.selectedDateRange.value!.start)} - ${DateFormat('MMM dd').format(controller.selectedDateRange.value!.end)}'
                              : 'Select Date Range',
                        ),
                      )),
                    ),
                    
                    SizedBox(width: 8),
                    
                    // Payment Method Filter
                    Expanded(
                      child: Obx(() => DropdownButtonFormField<String>(
                        value: controller.selectedPaymentMethod.value,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        items: controller.paymentMethods.map((method) {
                          return DropdownMenuItem(
                            value: method,
                            child: Text(method),
                          );
                        }).toList(),
                        onChanged: (value) {
                          controller.selectedPaymentMethod.value = value!;
                        },
                      )),
                    ),
                    
                    SizedBox(width: 8),
                    
                    // Clear Filters
                    Obx(() => controller.selectedDateRange.value != null
                        ? IconButton(
                            onPressed: controller.clearDateFilter,
                            icon: Icon(Icons.clear),
                            tooltip: 'Clear Date Filter',
                          )
                        : SizedBox.shrink()),
                  ],
                ),
              ],
            ),
          ),
          
          // Transactions List
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return Center(child: CircularProgressIndicator());
              }
              
              final transactions = controller.filteredTransactions;
              
              if (transactions.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.receipt_long, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        controller.searchQuery.value.isNotEmpty || 
                        controller.selectedDateRange.value != null ||
                        controller.selectedPaymentMethod.value != 'All'
                            ? 'No transactions found with current filters'
                            : 'No transactions yet',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }
              
              return ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: transactions.length,
                itemBuilder: (context, index) {
                  final transaction = transactions[index];
                  return _buildTransactionCard(transaction);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(TransactionModel transaction) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: _getPaymentMethodColor(transaction.paymentMethod).withOpacity(0.1),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Icon(
            _getPaymentMethodIcon(transaction.paymentMethod),
            color: _getPaymentMethodColor(transaction.paymentMethod),
          ),
        ),
        title: Text(
          'Transaction #${transaction.id?.substring(0, 8) ?? 'Unknown'}',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              DateFormat('MMM dd, yyyy - HH:mm').format(transaction.timestamp),
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            Text(
              'Cashier: ${transaction.cashierName}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'Rp ${transaction.total.toStringAsFixed(0)}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _getPaymentMethodColor(transaction.paymentMethod).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                transaction.paymentMethod,
                style: TextStyle(
                  fontSize: 10,
                  color: _getPaymentMethodColor(transaction.paymentMethod),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Items:',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 8),
                ...transaction.items.map((item) => Padding(
                  padding: EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '${item.quantity}x ${item.productName}',
                          style: TextStyle(fontSize: 13),
                        ),
                      ),
                      Text(
                        'Rp ${(item.price * item.quantity).toStringAsFixed(0)}',
                        style: TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                )).toList(),
                Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Subtotal:'),
                    Text('Rp ${transaction.subtotal.toStringAsFixed(0)}'),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Tax:'),
                    Text('Rp ${transaction.tax.toStringAsFixed(0)}'),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Rp ${transaction.total.toStringAsFixed(0)}',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                if (transaction.paymentMethod == 'Cash') ...[
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Amount Paid:'),
                      Text('Rp ${transaction.amountPaid.toStringAsFixed(0)}'),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Change:'),
                      Text('Rp ${transaction.change.toStringAsFixed(0)}'),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getPaymentMethodIcon(String paymentMethod) {
    switch (paymentMethod) {
      case 'Cash':
        return Icons.money;
      case 'Card':
        return Icons.credit_card;
      case 'Digital Wallet':
        return Icons.account_balance_wallet;
      default:
        return Icons.payment;
    }
  }

  Color _getPaymentMethodColor(String paymentMethod) {
    switch (paymentMethod) {
      case 'Cash':
        return Colors.green;
      case 'Card':
        return Colors.blue;
      case 'Digital Wallet':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}