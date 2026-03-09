import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../data/services/order_service.dart';
import '../../../providers/auth_provider.dart';
import 'order_detail_screen.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  final OrderService _orderService = OrderService();
  late Future<List<dynamic>> _ordersFuture;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  void _loadOrders() {
    final authProv = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProv.userProfile?['id'] ?? authProv.userProfile?['_id'];

    if (userId != null) {
      setState(() {
        _ordersFuture = _orderService.getUserOrders(userId.toString());
      });
    } else {
      _ordersFuture = Future.error("User not logged in");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          "MY ORDERS",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
            fontSize: 14,
          ),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _ordersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.black),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error: ${snapshot.error}",
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          final orders = snapshot.data ?? [];
          if (orders.isEmpty) {
            return const Center(
              child: Text(
                "You haven't placed any orders yet.",
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }

          return RefreshIndicator(
            color: Colors.black,
            onRefresh: () async => _loadOrders(),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: orders.length,
              separatorBuilder: (context, index) => const SizedBox(height: 15),
              itemBuilder: (context, index) {
                final order = orders[index];
                return _buildOrderCard(order);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    final String status = order['status'] ?? 'unknown';
    final items = order['items'] as List;
    final int totalItems = items.fold(
      0,
      (sum, item) => sum + (item['quantity'] as int),
    );

    final DateTime createdAt = DateTime.parse(order['createdAt']);
    final String dateStr = DateFormat('MMM dd, yyyy').format(createdAt);

    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrderDetailScreen(orderId: order['_id']),
          ),
        );
        if (result == true && mounted) {
          _loadOrders();
        }
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Order #${order['_id'].toString().substring(18).toUpperCase()}",
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                  ),
                ),
                _buildStatusBadge(status),
              ],
            ),
            const SizedBox(height: 15),
            const Divider(height: 1),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Date Placed",
                      style: TextStyle(color: Colors.grey, fontSize: 11),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dateStr,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      "Total Items",
                      style: TextStyle(color: Colors.grey, fontSize: 11),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "$totalItems",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      "Total Price",
                      style: TextStyle(color: Colors.grey, fontSize: 11),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "\$${order['totalPrice']}",
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color = Colors.grey;
    if (status == 'paid' || status == 'completed') color = Colors.green;
    if (status == 'pending' || status == 'processing') color = Colors.orange;
    if (status == 'cancelled') color = Colors.red;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        border: Border.all(color: color),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w900,
          letterSpacing: 1,
        ),
      ),
    );
  }
}
