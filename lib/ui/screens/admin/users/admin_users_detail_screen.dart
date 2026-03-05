import 'package:flutter/material.dart';
import '../../../../data/services/admin_service.dart';

class AdminUserDetailsScreen extends StatefulWidget {
  final String userId;
  const AdminUserDetailsScreen({super.key, required this.userId});

  @override
  State<AdminUserDetailsScreen> createState() => _AdminUserDetailsScreenState();
}

class _AdminUserDetailsScreenState extends State<AdminUserDetailsScreen> {
  final AdminService _adminService = AdminService();
  late Future<Map<String, dynamic>> _userFuture;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    setState(() {
      _userFuture = _adminService.getUserById(widget.userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("USER DETAILS", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () => _showDeleteConfirm(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.black));
          }
          if (snapshot.hasError) {
            return const Center(child: Text("Error loading user data"));
          }
          
          final user = snapshot.data!;
          final address = user['address'] ?? {};
          final String role = user['role'] ?? 'user';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildSectionHeader("ACCOUNT INFO"),
                    TextButton.icon(
                      onPressed: () => _showRoleDialog(context, role),
                      icon: const Icon(Icons.edit, size: 14, color: Colors.blue),
                      label: const Text("EDIT ROLE", style: TextStyle(fontSize: 12, color: Colors.blue, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const Divider(height: 10),
                _buildDetailRow("Full Name", "${user['firstName']} ${user['lastName']}"),
                _buildDetailRow("Email", user['email']),
                _buildDetailRow("Role", role.toUpperCase()),
                _buildDetailRow("User ID", user['_id']),
                
                const SizedBox(height: 40),
                _buildSectionHeader("CONTACT & ADDRESS"),
                const Divider(height: 20),
                _buildDetailRow("Phone", user['phone'] ?? "N/A"),
                _buildDetailRow("Street", address['street'] ?? "N/A"),
                _buildDetailRow("District", address['district'] ?? "N/A"),
                _buildDetailRow("City", address['city'] ?? "N/A"),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1.2, color: Colors.grey),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black)),
        ],
      ),
    );
  }

  void _showRoleDialog(BuildContext context, String currentRole) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        title: const Text("UPDATE ROLE", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['user', 'admin'].map((role) => ListTile(
            title: Text(role.toUpperCase(), style: const TextStyle(fontSize: 13)),
            trailing: currentRole == role ? const Icon(Icons.check, color: Colors.green) : null,
            onTap: () async {
              final success = await _adminService.updateUserRole(widget.userId, role);
              
              // FIX: Kiểm tra context.mounted thay vì chỉ mounted
              if (!context.mounted) return;

              if (success) {
                Navigator.pop(ctx);
                _loadUserData();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("ROLE UPDATED")));
              }
            },
          )).toList(),
        ),
      ),
    );
  }

  void _showDeleteConfirm(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        title: const Text("DELETE ACCOUNT", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        content: const Text("This action is permanent. Are you sure?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("CANCEL", style: TextStyle(color: Colors.grey))),
          TextButton(
            onPressed: () async {
              final success = await _adminService.deleteUser(widget.userId);

              // FIX: Kiểm tra context.mounted ngay sau khi await
              if (!context.mounted) return;

              if (success) {
                Navigator.pop(ctx); // Đóng dialog
                Navigator.pop(context); // Thoát khỏi trang Detail
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("USER DELETED")));
              }
            },
            child: const Text("DELETE", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}