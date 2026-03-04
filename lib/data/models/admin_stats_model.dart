class DashboardStats {
  final int totalUsers;
  final int totalProducts;
  final int totalOrders;
  final double totalRevenue;
  final int pendingOrders;

  DashboardStats({
    required this.totalUsers,
    required this.totalProducts,
    required this.totalOrders,
    required this.totalRevenue,
    required this.pendingOrders,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      totalUsers: json['totalUsers'] ?? 0,
      totalProducts: json['totalProducts'] ?? 0,
      totalOrders: json['totalOrders'] ?? 0,
      totalRevenue: (json['totalRevenue'] ?? 0).toDouble(),
      pendingOrders: json['pendingOrders'] ?? 0,
    );
  }
}

class ReportData {
  final String label;
  final double value;
  ReportData(this.label, this.value);
}
