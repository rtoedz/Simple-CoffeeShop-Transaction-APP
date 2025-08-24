import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/dashboard_controller.dart';
import '../../../widgets/dashboard_stat_card.dart';
import '../../../widgets/sales_chart.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DashboardController>();
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          
          return RefreshIndicator(
            onRefresh: controller.refreshData,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome Section
                  _buildWelcomeSection(controller),
                  const SizedBox(height: 24),
                  
                  // Today's Summary Cards
                  _buildTodaySummary(controller),
                  const SizedBox(height: 24),
                  
                  // Sales Analytics
                  _buildSalesAnalytics(controller),
                  const SizedBox(height: 24),
                  
                  // Recent Activity
                  _buildRecentActivity(controller),
                  const SizedBox(height: 24),
                  
                  // Quick Actions
                  _buildQuickActions(context),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
  
  Widget _buildWelcomeSection(DashboardController controller) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.brown[700]!,
            Colors.brown[500]!,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.brown.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Welcome to KopiKita POS',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Here\'s your business overview for today',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                color: Colors.white.withValues(alpha: 0.8),
                size: 16,
              ),
              const SizedBox(width: 8),
              Obx(() => Text(
                controller.getCurrentDateString(),
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 14,
                ),
              )),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildTodaySummary(DashboardController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Today\'s Overview',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        Obx(() => GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.3,
          children: [
            DashboardStatCard(
               title: 'Total Sales',
               value: 'Rp ${controller.todayStats.value.totalSales.toStringAsFixed(0)}',
               icon: Icons.attach_money,
               color: Colors.green,
               trend: controller.formatTrend(controller.todayStats.value.salesTrend),
               isPositiveTrend: controller.todayStats.value.salesTrend >= 0,
             ),
             DashboardStatCard(
               title: 'Transactions',
               value: '${controller.todayStats.value.totalTransactions}',
               icon: Icons.receipt,
               color: Colors.blue,
               trend: controller.formatTrend(controller.todayStats.value.transactionsTrend),
               isPositiveTrend: controller.todayStats.value.transactionsTrend >= 0,
             ),
             DashboardStatCard(
               title: 'Products Sold',
               value: '${controller.todayStats.value.totalProductsSold}',
               icon: Icons.shopping_bag,
               color: Colors.orange,
               trend: controller.formatTrend(controller.todayStats.value.productsTrend),
               isPositiveTrend: controller.todayStats.value.productsTrend >= 0,
             ),
             DashboardStatCard(
               title: 'Avg. Order',
               value: 'Rp ${controller.todayStats.value.averageOrderValue.toStringAsFixed(0)}',
               icon: Icons.trending_up,
               color: Colors.purple,
               trend: controller.formatTrend(controller.todayStats.value.avgOrderTrend),
               isPositiveTrend: controller.todayStats.value.avgOrderTrend >= 0,
             ),
          ],
        )),
      ],
    );
  }
  
  Widget _buildSalesAnalytics(DashboardController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Sales Analytics',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        Card(
           elevation: 4,
           shape: RoundedRectangleBorder(
             borderRadius: BorderRadius.circular(12),
           ),
           child: Padding(
             padding: const EdgeInsets.all(16),
             child: Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 const Text(
                   'Sales Trend (Last 7 Days)',
                   style: TextStyle(
                     fontSize: 18,
                     fontWeight: FontWeight.w600,
                   ),
                 ),
                 const SizedBox(height: 16),
                 Obx(() => SalesChart(
                     data: controller.weeklyData.toList(),
                   )),
               ],
             ),
           ),
         ),
      ],
    );
  }
  
  Widget _buildRecentActivity(DashboardController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Activity',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Recent Transactions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Obx(() {
                  if (controller.recentTransactions.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Text('No recent transactions'),
                      ),
                    );
                  }
                  
                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: controller.recentTransactions.length.clamp(0, 5),
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      final transaction = controller.recentTransactions[index];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          backgroundColor: Colors.brown[100],
                          child: Icon(
                            Icons.receipt,
                            color: Colors.brown[700],
                            size: 20,
                          ),
                        ),
                        title: Text(
                          'Transaction #${transaction.id}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        subtitle: Text(
                          transaction.createdAt.toString().substring(0, 16),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                        trailing: Text(
                          'Rp ${transaction.finalAmount.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      );
                    },
                  );
                }),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.5,
          children: [
            _buildQuickActionCard(
              'New Sale',
              Icons.point_of_sale,
              Colors.green,
              () => Get.toNamed('/pos'),
            ),
            _buildQuickActionCard(
              'Manage Menu',
              Icons.restaurant_menu,
              Colors.blue,
              () => Get.toNamed('/menu'),
            ),
            _buildQuickActionCard(
              'View Reports',
              Icons.analytics,
              Colors.orange,
              () => Get.snackbar('Info', 'Reports feature coming soon!'),
            ),
            _buildQuickActionCard(
              'Settings',
              Icons.settings,
              Colors.grey,
              () => Get.snackbar('Info', 'Settings feature coming soon!'),
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildQuickActionCard(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 32,
                color: color,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}