import 'package:flutter/material.dart';
import 'dashboard/admin_dashboard_screen.dart';
import 'orders/admin_orders_screen.dart';
import 'products/admin_products_screen.dart';

class AdminMainWrapper extends StatefulWidget {
  const AdminMainWrapper({super.key});

  @override
  State<AdminMainWrapper> createState() => _AdminMainWrapperState();
}

class _AdminMainWrapperState extends State<AdminMainWrapper> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const AdminDashboardScreen(),
    const AdminOrdersScreen(),
    const AdminProductsScreen(),
    const Center(child: Text("Vouchers Management")),
    const Center(child: Text("Users Management")),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            extended: MediaQuery.of(context).size.width > 900,
            backgroundColor: Colors.black,
            unselectedIconTheme: const IconThemeData(color: Colors.white60),
            selectedIconTheme: const IconThemeData(color: Colors.white),
            unselectedLabelTextStyle: const TextStyle(color: Colors.white60),
            selectedLabelTextStyle: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.dashboard_outlined),
                label: Text("Dashboard"),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.shopping_cart_outlined),
                label: Text("Orders"),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.inventory_2_outlined),
                label: Text("Products"),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.confirmation_number_outlined),
                label: Text("Vouchers"),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.people_outline),
                label: Text("Users"),
              ),
            ],
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) =>
                setState(() => _selectedIndex = index),
          ),

          const VerticalDivider(thickness: 1, width: 1),

          Expanded(child: _screens[_selectedIndex]),
        ],
      ),
    );
  }
}
