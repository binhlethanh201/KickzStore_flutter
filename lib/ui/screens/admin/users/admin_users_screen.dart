import 'package:flutter/material.dart';
import '../../../../data/services/admin_service.dart';
import '../users/admin_users_detail_screen.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  final AdminService _adminService = AdminService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "USERS MANAGEMENT",
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
        ),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _adminService.getAllUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.black),
            );
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No users found."));
          }

          final users = snapshot.data!;
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: users.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final user = users[index];
              final String role = user['role'] ?? 'user';

              return ListTile(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          AdminUserDetailsScreen(userId: user['_id']),
                    ),
                  );
                },
                leading: CircleAvatar(
                  backgroundColor: Colors.grey[200],
                  child: Text(
                    user['firstName'][0].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(
                  "${user['firstName']} ${user['lastName']}".toUpperCase(),
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user['email'], style: const TextStyle(fontSize: 12)),
                    const SizedBox(height: 4),
                    _buildRoleBadge(role),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.admin_panel_settings_outlined,
                        size: 20,
                      ),
                      onPressed: () => _showRoleDialog(user['_id'], role),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.red,
                        size: 20,
                      ),
                      onPressed: () =>
                          _showDeleteConfirm(user['_id'], user['email']),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildRoleBadge(String role) {
    bool isAdmin = role == 'admin';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isAdmin ? Colors.red : Colors.black,
        borderRadius: BorderRadius.circular(2),
      ),
      child: Text(
        role.toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showRoleDialog(String userId, String currentRole) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        title: const Text(
          "CHANGE USER ROLE",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['user', 'admin']
              .map(
                (role) => ListTile(
                  title: Text(role.toUpperCase()),
                  trailing: currentRole == role
                      ? const Icon(Icons.check, color: Colors.green)
                      : null,
                  onTap: () async {
                    final success = await _adminService.updateUserRole(
                      userId,
                      role,
                    );
                    if (!context.mounted) return;
                    if (success) {
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

  void _showDeleteConfirm(String userId, String email) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        title: const Text(
          "DELETE USER",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        content: Text(
          "Are you sure you want to delete $email? This action cannot be undone.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("CANCEL", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              final success = await _adminService.deleteUser(userId);
              if (!context.mounted) return;
              if (success) {
                setState(() {});
                Navigator.pop(context);
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
}
