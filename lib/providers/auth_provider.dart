import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'cart_provider.dart';
import 'wishlist_provider.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  String? _token;
  bool get isAuthenticated => _token != null;

  Map<String, dynamic>? _userProfile;
  Map<String, dynamic>? get userProfile => _userProfile;

  Future<bool> register(
    String firstName,
    String lastName,
    String email,
    String password,
  ) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.register(
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Gọi hàm này trong main hoặc khởi tạo Provider
  Future<void> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('jwt_token');

    if (_token != null) {
      await fetchProfile();
    }
    notifyListeners();
  }

  Future<bool> login(
    String email,
    String password,
    BuildContext context,
  ) async {
    try {
      _token = await _authService.login(email, password);

      // Lấy thông tin Profile ngay lập tức
      await fetchProfile();

      // TỰ ĐỘNG FETCH DỮ LIỆU SAU KHI LOGIN
      final userId = _userProfile?['id'];
      if (userId != null) {
        Provider.of<CartProvider>(context, listen: false).fetchCart(userId);
        Provider.of<WishlistProvider>(
          context,
          listen: false,
        ).fetchWishlist(userId);
      }

      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  void logout() async {
    await _authService.logout();
    _token = null;
    notifyListeners();
  }

  Future<void> fetchProfile() async {
    _isLoading = true;
    notifyListeners();
    try {
      _userProfile = await _authService.getProfile();
    } catch (e) {
      _userProfile = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProfile(Map<String, dynamic> userData) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _authService.updateProfile(userData);
      if (success) {
        await fetchProfile();
        return true;
      }
      return false;
    } catch (e) {
      // Lưu lại thông báo lỗi từ catch để hiển thị lên SnackBar
      _errorMessage = e.toString();
      debugPrint("UPDATE ERROR: $e"); // Xem ở debug console của Flutter
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> changePassword(String oldPassword, String newPassword) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _authService.changePassword(
        oldPassword,
        newPassword,
      );
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
