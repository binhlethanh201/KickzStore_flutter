import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../widgets/uniqlo_widgets.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void _showSnackBar(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message.toUpperCase(), 
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
        backgroundColor: isError ? Colors.red[900] : Colors.black,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(20),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("CREATE ACCOUNT", style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
            const SizedBox(height: 10),
            const Text("Become a member and enjoy exclusive benefits.", 
              style: TextStyle(color: Colors.grey, fontSize: 16)),
            const SizedBox(height: 40),

            Row(
              children: [
                Expanded(child: UniqloInput(label: "First Name", controller: _firstNameController)),
                const SizedBox(width: 15),
                Expanded(child: UniqloInput(label: "Last Name", controller: _lastNameController)),
              ],
            ),
            const SizedBox(height: 20),
            UniqloInput(
              label: "Email Address",
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),
            UniqloInput(
              label: "Password",
              controller: _passwordController,
              isPassword: true,
            ),
            
            const SizedBox(height: 40),
            UniqloButton(
              text: "Register",
              isLoading: authProvider.isLoading,
              onPressed: () async {
                // Validation cơ bản
                if (_firstNameController.text.isEmpty || _emailController.text.isEmpty || _passwordController.text.isEmpty) {
                  _showSnackBar("Please fill in all required fields");
                  return;
                }

                final success = await authProvider.register(
                  _firstNameController.text.trim(),
                  _lastNameController.text.trim(),
                  _emailController.text.trim(),
                  _passwordController.text,
                );

                if (mounted) {
                  if (success) {
                    _showSnackBar("Account created! Please log in.", isError: false);
                    Navigator.pop(context);
                  } else {
                    _showSnackBar(authProvider.errorMessage ?? "Registration failed");
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