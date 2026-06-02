import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api.dart';
import '../models/user.dart';
import 'api_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal() {
    ApiService.setAppOwnerToken(ApiConfig.appOwnerToken);
  }

  final ApiService _api = ApiService();

  Future<User?> login(String username, String password) async {
    try {
      print('Login attempt: username=$username');
      final response = await _api.post(ApiConfig.auth, body: {
        'username': username,
        'password': password,
      });
      print('Login response: $response');

      if (response == null) return null;

      if (response['data'] != null) {
        final data = response['data'];
        final user = User.fromJson(data);
        if (user.token != null && user.token!.isNotEmpty) {
          _api.setToken(user.token!);
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', user.token!);
          await prefs.setString('role', user.role ?? 'CUSTOMER');
          await prefs.setString('user', jsonEncode(data));
        }
        return user;
      } else if (response['token'] != null) {
        final data = {
          'token': response['token'],
          'role': response['role'] ?? 'CUSTOMER',
          'username': username,
        };
        final user = User.fromJson(data);
        _api.setToken(response['token']);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', response['token']);
        await prefs.setString('role', response['role'] ?? 'CUSTOMER');
        await prefs.setString('user', jsonEncode(data));
        return user;
      }
      return null;
    } catch (e) {
      print('Login error: $e');
      rethrow;
    }
  }

  Future<bool> registerCustomer(Map<String, dynamic> data) async {
    try {
      print('Register Customer Payload: ${jsonEncode(data)}');
      final response = await _api.post(ApiConfig.customers, body: data);
      print('Register Customer Response: $response');
      if (response != null) {
        if (response['success'] == true || response['data'] != null) {
          return true;
        } else if (response['message'] != null) {
          throw Exception(response['message']);
        }
      }
      return false;
    } catch (e) {
      print('Register Customer Error: $e');
      rethrow;
    }
  }

  Future<bool> registerAdmin(Map<String, dynamic> data) async {
    try {
      print('Register Admin Payload: ${jsonEncode(data)}');
      final response = await _api.post(ApiConfig.admins, body: data);
      print('Register Admin Response: $response');
      if (response != null) {
        if (response['success'] == true || response['data'] != null) {
          return true;
        } else if (response['message'] != null) {
          throw Exception(response['message']);
        }
      }
      return false;
    } catch (e) {
      print('Register Admin Error: $e');
      rethrow;
    }
  }

  Future<void> logout() async {
    _api.clearToken();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userStr = prefs.getString('user');
    if (userStr != null) {
      return User.fromJson(jsonDecode(userStr));
    }
    return null;
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<String?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('role');
  }

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token != null) {
      _api.setToken(token);
    }
  }
}