import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'personal_info_screen.dart';
import 'change_password_screen.dart';
import '../../../providers/auth_provider.dart';
import '../auth/login_screen.dart';
import '../../widgets/uniqlo_widgets.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Gọi API lấy thông tin profile ngay khi người dùng vào tab Profile
    Future.microtask(() {
      final authProv = Provider.of<AuthProvider>(context, listen: false);
      if (authProv.isAuthenticated) {
        authProv.fetchProfile();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProv = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "MY ACCOUNT",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
          ),
        ),
        centerTitle: true,
      ),
      body: authProv.isAuthenticated
          ? _buildMemberView(authProv)
          : _buildGuestView(context),
    );
  }

  // Giao diện hiển thị cho khách (chưa đăng nhập)
  Widget _buildGuestView(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.person_outline, size: 100, color: Color(0xFFEEEEEE)),
          const SizedBox(height: 30),
          const Text(
            "JOIN THE KICKZ CLUB",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),
          const Text(
            "Log in to access your orders, wishlist, and personalized recommendations.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, height: 1.5),
          ),
          const SizedBox(height: 40),
          UniqloButton(
            text: "Log In / Register",
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
            ),
          ),
        ],
      ),
    );
  }

  // Giao diện hiển thị cho thành viên (đã đăng nhập)
  Widget _buildMemberView(AuthProvider prov) {
    if (prov.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.black),
      );
    }

    final user = prov.userProfile;

    return ListView(
      children: [
        // Phần Welcome Box
        Container(
          padding: const EdgeInsets.all(24),
          color: const Color(0xFFF7F7F7),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "WELCOME,",
                style: TextStyle(color: Colors.grey[600], letterSpacing: 1),
              ),
              const SizedBox(height: 4),
              Text(
                "${user?['firstName'] ?? ''} ${user?['lastName'] ?? ''}"
                    .toUpperCase(),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                user?['email'] ?? '',
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),

        // Danh sách Menu tùy chọn
        _buildMenuTile(
          Icons.shopping_bag_outlined,
          "MY ORDERS",
          "View and track your orders",
          onTap: () {
            // Sẽ phát triển trang Order History sau
          },
        ),
        _buildMenuTile(
          Icons.favorite_border,
          "WISHLIST",
          "Your favorite sneakers",
          onTap: () {
            // Sẽ phát triển trang Wishlist sau
          },
        ),
        _buildMenuTile(
          Icons.person_outline,
          "PERSONAL INFORMATION",
          "Update your profile and address",
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const PersonalInfoScreen(),
              ),
            );
          },
        ),
        _buildMenuTile(
          Icons.lock_outline,
          "PASSWORD & SECURITY",
          "Change your password",
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ChangePasswordScreen(),
              ),
            );
          },
        ),

        const SizedBox(height: 40),

        // Nút Đăng xuất
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: TextButton(
            onPressed: () => prov.logout(),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 18),
              side: const BorderSide(color: Colors.black),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
            ),
            child: const Text(
              "SIGN OUT",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  // Widget dùng chung cho các hàng Menu
  Widget _buildMenuTile(
    IconData icon,
    String title,
    String subtitle, {
    VoidCallback? onTap,
  }) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 10,
        ),
        leading: Icon(icon, color: Colors.black),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            letterSpacing: 1,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 14,
          color: Colors.black,
        ),
        onTap: onTap,
      ),
    );
  }
}