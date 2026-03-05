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
  late TextEditingController _cityController;
  late TextEditingController _districtController;

  String _selectedGender = "M";

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

    final address = user?['address'];
    _streetController = TextEditingController(text: address?['street'] ?? '');
    _cityController = TextEditingController(text: address?['city'] ?? '');
    _districtController = TextEditingController(
      text: address?['district'] ?? '',
    );

    _selectedGender = user?['gender'] ?? "M";
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _districtController.dispose();
    super.dispose();
  }

  Widget _buildGenderOption(String value, String label) {
    bool isSelected = _selectedGender == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedGender = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 15),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected ? Colors.black : Colors.grey[300]!,
              width: isSelected ? 2 : 1,
            ),
            color: isSelected ? Colors.black : Colors.white,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : Colors.black,
            ),
          ),
        ),
      ),
    );
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

            const Text(
              "GENDER",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _buildGenderOption("M", "MALE"),
                const SizedBox(width: 10),
                _buildGenderOption("F", "FEMALE"),
                const SizedBox(width: 10),
                _buildGenderOption("O", "OTHER"),
              ],
            ),
            const SizedBox(height: 25),

            UniqloInput(
              label: "Email Address",
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 25),
            UniqloInput(
              label: "Phone Number",
              controller: _phoneController,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 35),

            const Text(
              "SHIPPING ADDRESS",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 20),
            UniqloInput(label: "Street", controller: _streetController),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: UniqloInput(
                    label: "District",
                    controller: _districtController,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: UniqloInput(
                    label: "City",
                    controller: _cityController,
                  ),
                ),
              ],
            ),

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
                  "gender": _selectedGender,
                  "address": {
                    "street": _streetController.text.trim(),
                    "city": _cityController.text.trim(),
                    "district": _districtController.text.trim(),
                    "country":
                        authProv.userProfile?['address']?['country'] ??
                        "Vietnam",
                  },
                };

                if (authProv.userProfile?['dateOfBirth'] != null) {
                  updateData["dateOfBirth"] =
                      authProv.userProfile!['dateOfBirth'];
                }

                final success = await authProv.updateProfile(updateData);
                if (!context.mounted) return;

                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("PROFILE UPDATED SUCCESSFULLY!"),
                      backgroundColor: Colors.black,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(authProv.errorMessage ?? "UPDATE FAILED"),
                      backgroundColor: Colors.red[900],
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
