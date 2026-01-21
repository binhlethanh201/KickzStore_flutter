import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../widgets/uniqlo_widgets.dart';

class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _streetController;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthProvider>(context, listen: false).userProfile;
    _firstNameController = TextEditingController(
      text: user?['firstName'] ?? '',
    );
    _lastNameController = TextEditingController(text: user?['lastName'] ?? '');
    _emailController = TextEditingController(text: user?['email'] ?? '');
    _phoneController = TextEditingController(text: user?['phone'] ?? '');
    // Kiểm tra kỹ cấu trúc address từ backend trả về
    _streetController = TextEditingController(
      text: user?['address']?['street'] ?? '',
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _streetController.dispose();
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
        title: const Text(
          "PERSONAL INFORMATION",
          style: TextStyle(
            color: Colors.black,
            fontSize: 13,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "EDIT PROFILE",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 30),

            Row(
              children: [
                Expanded(
                  child: UniqloInput(
                    label: "First Name",
                    controller: _firstNameController,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: UniqloInput(
                    label: "Last Name",
                    controller: _lastNameController,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 25),
            UniqloInput(
              label: "Email",
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 25),
            UniqloInput(
              label: "Phone",
              controller: _phoneController,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 25),
            UniqloInput(label: "Street Address", controller: _streetController),

            const SizedBox(height: 50),

            UniqloButton(
              text: "Save Changes",
              isLoading: authProv.isLoading,
              onPressed: () async {
                FocusScope.of(context).unfocus();
                final Map<String, dynamic> updateData = {
                  "firstName": _firstNameController.text.trim(),
                  "lastName": _lastNameController.text.trim(),
                  "email": _emailController.text.trim(),
                  "phone": _phoneController.text.trim(),
                };
                if (_streetController.text.trim().isNotEmpty) {
                  updateData["address"] = {
                    "street": _streetController.text.trim(),
                    "city": authProv.userProfile?['address']?['city'] ?? "",
                    "district":
                        authProv.userProfile?['address']?['district'] ?? "",
                    "country":
                        authProv.userProfile?['address']?['country'] ?? "",
                  };
                }
                if (authProv.userProfile?['dateOfBirth'] != null) {
                  updateData["dateOfBirth"] =
                      authProv.userProfile!['dateOfBirth'];
                }

                final success = await authProv.updateProfile(updateData);

                if (mounted) {
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Profile updated!"),
                        backgroundColor: Colors.black,
                      ),
                    );
                    Navigator.pop(context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(authProv.errorMessage ?? "Update failed"),
                        backgroundColor: Colors.red,
                      ),
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
