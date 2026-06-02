import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class AppProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  User? _user;
  String? _role;
  bool _isLoading = false;
  String? _error;
  int _bottomNavIndex = 0;

  User? get user => _user;
  String? get role => _role;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get bottomNavIndex => _bottomNavIndex;
  bool get isLoggedIn => _user != null;
  bool get isAdmin => _role?.toUpperCase() == 'ADMIN';
  bool get isCustomer => _role?.toUpperCase() == 'CUSTOMER';

  void setBottomNavIndex(int index) {
    _bottomNavIndex = index;
    notifyListeners();
  }

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void setError(String? value) {
    _error = value;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<bool> checkAuth() async {
    await _authService.init();
    _user = await _authService.getCurrentUser();
    _role = await _authService.getRole();
    notifyListeners();
    return _user != null;
  }

  Future<bool> login(String username, String password) async {
    setLoading(true);
    clearError();
    try {
      final user = await _authService.login(username, password);
      if (user != null) {
        _user = user;
        _role = user.role ?? 'CUSTOMER';
        setLoading(false);
        notifyListeners();
        return true;
      } else {
        setError('Login gagal. Periksa kembali username dan password.');
        setLoading(false);
        return false;
      }
    } catch (e) {
      setError('Login gagal: ${e.toString()}');
      setLoading(false);
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    _role = null;
    _bottomNavIndex = 0;
    notifyListeners();
  }

  Future<bool> registerCustomer(Map<String, dynamic> data) async {
    setLoading(true);
    clearError();
    try {
      final result = await _authService.registerCustomer(data);
      setLoading(false);
      if (!result) {
        setError('Registrasi customer gagal. Silakan coba lagi.');
      }
      return result;
    } catch (e) {
      setError('Registrasi gagal: ${e.toString()}');
      setLoading(false);
      return false;
    }
  }

  Future<bool> registerAdmin(Map<String, dynamic> data) async {
    setLoading(true);
    clearError();
    try {
      final result = await _authService.registerAdmin(data);
      setLoading(false);
      if (!result) {
        setError('Registrasi admin gagal. Silakan coba lagi.');
      }
      return result;
    } catch (e) {
      setError('Registrasi gagal: ${e.toString()}');
      setLoading(false);
      return false;
    }
  }
}