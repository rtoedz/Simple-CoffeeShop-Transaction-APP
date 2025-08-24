import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/database_service.dart';
import '../../core/routes/app_routes.dart';
import '../../widgets/sales_chart.dart';
import 'controllers/dashboard_controller.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  DashboardController get controller => Get.find<DashboardController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: controller.loadDashboardData,
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'profile':
                  Get.toNamed(AppRoutes.PROFILE);
                  break;
                case 'settings':
                  Get.toNamed(AppRoutes.SETTINGS);
                  break;
                case 'logout':
                  controller.logout();
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(Icons.person),
                    SizedBox(width: 8),
                    Text('Profile'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings),
                    SizedBox(width: 8),
                    Text('Settings'),
                  ],
                ),
              ),
              PopupMenuDivider(),
              PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Logout', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }
        
        return RefreshIndicator(
          onRefresh: controller.loadDashboardData,
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Section
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).primaryColor,
                        Theme.of(context).primaryColor.withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome back!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Obx(() => Text(
                        'Role: ${Get.find<AuthService>().userRole.value.toUpperCase()}',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      )),
                    ],
                  ),
                ),
                SizedBox(height: 24),
                
                // Stats Cards
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Today Sales',
                        'Rp ${controller.todayStats.value.totalSales.toStringAsFixed(0)}',
                        Icons.attach_money,
                        Colors.green,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'Transactions',
                        '${controller.todayStats.value.totalTransactions}',
                        Icons.receipt,
                        Colors.blue,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Average',
                        'Rp ${controller.todayStats.value.averageOrderValue.toStringAsFixed(0)}',
                        Icons.trending_up,
                        Colors.orange,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'Status',
                        'Online',
                        Icons.circle,
                        Colors.green,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24),
                
                // Sales Chart
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sales Overview',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 16),
                        Container(
                          height: 200,
                          child: SalesChart(
                            data: controller.weeklyData.value,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 24),
                
                // Quick Actions
                Text(
                  'Quick Actions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
                GridView.count(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.5,
                  children: [
                    _buildActionCard(
                      'POS System',
                      Icons.point_of_sale,
                      Colors.blue,
                      () => Get.toNamed(AppRoutes.POS),
                    ),
                    _buildActionCard(
                      'Menu Management',
                      Icons.restaurant_menu,
                      Colors.green,
                      () => Get.toNamed(AppRoutes.MENU_MANAGEMENT),
                    ),
                    _buildActionCard(
                      'Transaction History',
                      Icons.history,
                      Colors.orange,
                      () => Get.toNamed(AppRoutes.TRANSACTION_HISTORY),
                    ),
                    _buildActionCard(
                      'Settings',
                      Icons.settings,
                      Colors.grey,
                      () => Get.toNamed(AppRoutes.SETTINGS),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 24),
                Container(
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: color),
              SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}