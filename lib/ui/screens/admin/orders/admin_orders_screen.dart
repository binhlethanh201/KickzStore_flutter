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
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 16,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _adminService.getAllOrders(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.black),
            );
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No orders found."));
          }

          final orders = snapshot.data!;

          return LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: constraints.maxWidth),
                    child: DataTable(
                      columnSpacing: 30,
                      headingTextStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      columns: const [
                        DataColumn(label: Text("ORDER ID")),
                        DataColumn(label: Text("CUSTOMER")),
                        DataColumn(label: Text("TOTAL")),
                        DataColumn(label: Text("STATUS")),
                        DataColumn(label: Text("ACTION")),
                      ],
                      rows: orders.map((order) {
                        final user = order['userId'];
                        final String customerName = user != null
                            ? "${user['firstName']} ${user['lastName']}"
                            : "Deleted User";

                        return DataRow(
                          cells: [
                            DataCell(
                              InkWell(
                                onTap: () => _showOrderDetails(order['_id']),
                                child: Text(
                                  order['_id'].toString().substring(18),
                                  style: const TextStyle(
                                    color: Colors.blue,
                                    decoration: TextDecoration.underline,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            DataCell(Text(customerName)),
                            DataCell(
                              Text(
                                "\$${order['totalPrice']}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            DataCell(_buildStatusBadge(order['status'])),
                            DataCell(
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.edit_note,
                                      color: Colors.blue,
                                    ),
                                    tooltip: "Update Status",
                                    onPressed: () => _showStatusDialog(
                                      order['_id'],
                                      order['status'],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      color: Colors.red,
                                    ),
                                    tooltip: "Delete Order",
                                    onPressed: () =>
                                        _showDeleteConfirm(order['_id']),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color = Colors.grey;
    if (status == 'paid' || status == 'completed') color = Colors.green;
    if (status == 'pending' || status == 'processing') color = Colors.orange;
    if (status == 'cancelled') color = Colors.red;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
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
      builder: (ctx) => AlertDialog(
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
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
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  trailing: currentStatus == s
                      ? const Icon(Icons.check, color: Colors.green)
                      : null,
                  onTap: () async {
                    final success = await _adminService.updateOrderStatus(
                      orderId,
                      s,
                    );

                    // SỬA Ở ĐÂY: Check cả 2 mounted
                    if (!mounted || !ctx.mounted) return;

                    if (success) {
                      setState(() {});
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("STATUS UPDATED")),
                      );
                    }
                  },
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  void _showDeleteConfirm(String orderId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        title: const Text(
          "DELETE ORDER",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        content: const Text("Are you sure you want to delete this order?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("CANCEL", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              final success = await _adminService.deleteOrder(orderId);

              // SỬA Ở ĐÂY: Check cả 2 mounted
              if (!mounted || !ctx.mounted) return;

              if (success) {
                setState(() {});
                Navigator.pop(ctx);
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text("ORDER DELETED")));
              }
            },
            child: const Text(
              "DELETE",
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _showOrderDetails(String orderId) async {
    showDialog(
      context: context,
      builder: (_) =>
          const Center(child: CircularProgressIndicator(color: Colors.white)),
    );

    try {
      final details = await _adminService.getOrderById(orderId);
      if (!mounted) return;
      Navigator.pop(context);

      final items = details['items'] as List;
      final address = details['shippingAddress'] ?? "No address";

      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          title: Text(
            "ORDER ...${orderId.substring(18)}",
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Address: $address",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 10),
                const Divider(),
                ...items.map((item) {
                  final prod = item['productId'] ?? {};
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Image.network(
                      prod['img'] ?? '',
                      width: 40,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.image),
                    ),
                    title: Text(
                      prod['name'] ?? 'Unknown Product',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      "Size: ${item['size']} | Color: ${item['color']} | Qty: ${item['quantity']}",
                      style: const TextStyle(fontSize: 10),
                    ),
                    trailing: Text(
                      "\$${item['price']}",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  );
                }),
                const Divider(),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    "TOTAL: \$${details['totalPrice']}",
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      color: Colors.red,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text(
                "CLOSE",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Error loading details")));
    }
  }
}
