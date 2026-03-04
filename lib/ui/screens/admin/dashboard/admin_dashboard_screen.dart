import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../data/services/admin_service.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final adminService = AdminService();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "DASHBOARD OVERVIEW",
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
        ),
      ),
      body: FutureBuilder(
        future: adminService.getDashboardStats(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());
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

  Widget _buildStatCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(left: BorderSide(color: color, width: 4)),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
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
              color: Colors.black.withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }
}
