import 'package:flutter/material.dart';
import '../../../../data/services/admin_service.dart';

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  final AdminService _adminService = AdminService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "ORDERS MANAGEMENT",
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
        ),
        backgroundColor: Colors.white,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _adminService.getAllOrders(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return const Center(child: CircularProgressIndicator());
          if (!snapshot.hasData || snapshot.data!.isEmpty)
            return const Center(child: Text("No orders found."));

          final orders = snapshot.data!;

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              child: DataTable(
                columns: const [
                  DataColumn(label: Text("ORDER ID")),
                  DataColumn(label: Text("CUSTOMER")),
                  DataColumn(label: Text("TOTAL")),
                  DataColumn(label: Text("STATUS")),
                  DataColumn(label: Text("ACTION")),
                ],
                rows: orders.map((order) {
                  return DataRow(
                    cells: [
                      DataCell(Text(order['_id'].toString().substring(18))),
                      DataCell(
                        Text(
                          "${order['userId']['firstName']} ${order['userId']['lastName']}",
                        ),
                      ),
                      DataCell(Text("\$${order['totalPrice']}")),
                      DataCell(_buildStatusBadge(order['status'])),
                      DataCell(
                        IconButton(
                          icon: const Icon(Icons.edit_note, color: Colors.blue),
                          onPressed: () =>
                              _showStatusDialog(order['_id'], order['status']),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color = Colors.grey;
    if (status == 'paid') color = Colors.green;
    if (status == 'pending') color = Colors.orange;
    if (status == 'cancelled') color = Colors.red;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showStatusDialog(String orderId, String currentStatus) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          "UPDATE STATUS",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ["processing", "shipped", "completed", "cancelled"]
              .map(
                (s) => ListTile(
                  title: Text(
                    s.toUpperCase(),
                    style: const TextStyle(fontSize: 13),
                  ),
                  trailing: currentStatus == s
                      ? const Icon(Icons.check, color: Colors.green)
                      : null,
                  onTap: () async {
                    final success = await _adminService.updateOrderStatus(
                      orderId,
                      s,
                    );
                    if (success && mounted) {
                      setState(() {});
                      Navigator.pop(context);
                    }
                  },
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
