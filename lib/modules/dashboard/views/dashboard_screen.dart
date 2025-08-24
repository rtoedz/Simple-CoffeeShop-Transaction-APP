import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/dashboard_controller.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final DashboardController controller = Get.find<DashboardController>();
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: controller.logout,
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildDashboardCard(
              'POS',
              Icons.point_of_sale,
              Colors.blue,
              () => Get.toNamed('/pos'),
            ),
            _buildDashboardCard(
              'Menu',
              Icons.restaurant_menu,
              Colors.green,
              () => Get.toNamed('/menu'),
            ),
            _buildDashboardCard(
              'Reports',
              Icons.analytics,
              Colors.orange,
              () => Get.toNamed('/reports'),
            ),
            _buildDashboardCard(
              'Settings',
              Icons.settings,
              Colors.purple,
              () => Get.toNamed('/settings'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCard(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            gradient: LinearGradient(
              colors: [color.withValues(alpha: 0.1), color.withValues(alpha: 0.2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 48,
                color: color,
              ),
              SizedBox(height: 16),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}