import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../../../../data/services/admin_service.dart';
import '../../../../providers/auth_provider.dart';
import '../../auth/login_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final adminService = AdminService();
    final authProv = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "DASHBOARD OVERVIEW",
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
        ),
        actions: [
          IconButton(
            onPressed: () => _showLogoutDialog(context, authProv),
            icon: const Icon(Icons.logout, color: Colors.black, size: 20),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: FutureBuilder(
        future: adminService.getDashboardStats(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final stats = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _buildStatCard(
                      "REVENUE",
                      "\$${stats['totalRevenue']}",
                      Colors.green,
                    ),
                    _buildStatCard(
                      "ORDERS",
                      "${stats['totalOrders']}",
                      Colors.blue,
                    ),
                    _buildStatCard(
                      "USERS",
                      "${stats['totalUsers']}",
                      Colors.orange,
                    ),
                    _buildStatCard(
                      "PENDING",
                      "${stats['pendingOrders']}",
                      Colors.red,
                    ),
                  ],
                ),

                const SizedBox(height: 40),
                const Text(
                  "REVENUE TREND (MONTHLY)",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),

                Container(
                  height: 300,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: _buildRevenueChart(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AuthProvider authProv) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        title: const Text(
          "CONFIRM LOGOUT",
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
        ),
        content: const Text("Are you sure you want to exit Admin Panel?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("CANCEL", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              authProv.logout();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            },
            child: const Text(
              "LOGOUT",
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(left: BorderSide(color: color, width: 4)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueChart() {
    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: true),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: const [
              FlSpot(0, 3),
              FlSpot(2, 5),
              FlSpot(4, 4),
              FlSpot(6, 8),
            ],
            isCurved: true,
            color: Colors.black,
            barWidth: 4,
            belowBarData: BarAreaData(
              show: true,
              color: Colors.black.withValues(alpha: 0.1),
            ),
          ),
        ],
      ),
    );
  }
}
