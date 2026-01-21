import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../widgets/uniqlo_widgets.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProv = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text("PASSWORD & SECURITY", 
          style: TextStyle(color: Colors.black, fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("CHANGE PASSWORD", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
            const SizedBox(height: 10),
            const Text("Ensure your account is using a long, random password to stay secure.", 
              style: TextStyle(color: Colors.grey, fontSize: 14)),
            const SizedBox(height: 40),

            UniqloInput(
              label: "Current Password", 
              controller: _oldPasswordController, 
              isPassword: true
            ),
            const SizedBox(height: 25),
            UniqloInput(
              label: "New Password", 
              controller: _newPasswordController, 
              isPassword: true
            ),
            const SizedBox(height: 25),
            UniqloInput(
              label: "Confirm New Password", 
              controller: _confirmPasswordController, 
              isPassword: true
            ),
            
            const SizedBox(height: 50),

            UniqloButton(
              text: "Update Password",
              isLoading: authProv.isLoading,
              onPressed: () async {
                // 1. Kiểm tra khớp mật khẩu mới
                if (_newPasswordController.text != _confirmPasswordController.text) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("New passwords do not match"), backgroundColor: Colors.red),
                  );
                  return;
                }

                // 2. Gọi API thông qua Provider
                final success = await authProv.changePassword(
                  _oldPasswordController.text, 
                  _newPasswordController.text
                );

                if (mounted) {
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Password updated successfully"), backgroundColor: Colors.black),
                    );
                    Navigator.pop(context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(authProv.errorMessage ?? "Update failed"), backgroundColor: Colors.red),
                    );
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}