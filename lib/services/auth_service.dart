import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/api.dart';
import '../models/user.dart';
import 'api_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final ApiService _api = ApiService();
  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  Future<User?> login(String username, String password) async {
    final response = await _api.post(ApiConfig.auth, body: {
      'username': username,
      'password': password,
    });

    if (response == null) return null;

    String? token;
    String? role;
    Map<String, dynamic>? userData;

    if (response['data'] != null) {
      final data = response['data'] as Map<String, dynamic>;
      token = data['token']?.toString();
      role = data['role']?.toString() ?? 'CUSTOMER';
      userData = Map<String, dynamic>.from(data);
    } else if (response['token'] != null) {
      token = response['token']?.toString();
      role = response['role']?.toString() ?? 'CUSTOMER';
      userData = {
        'token': token,
        'role': role,
        'username': username,
      };
    }

    if (token == null || token.isEmpty) return null;

    _api.setToken(token);
    await _storage.write(key: 'token', value: token);
    await _storage.write(key: 'role', value: role);
    if (userData != null) {
      await _storage.write(key: 'user', value: jsonEncode(userData));
    }
    return User.fromJson(userData!);
  }

  Future<bool> registerCustomer(Map<String, dynamic> data) async {
    final response = await _api.post(ApiConfig.customers, body: data);
    return response != null &&
        (response['success'] == true || response['data'] != null);
  }

  Future<bool> registerAdmin(Map<String, dynamic> data) async {
    final response = await _api.post(ApiConfig.admins, body: data);
    return response != null &&
        (response['success'] == true || response['data'] != null);
  }

  Future<void> logout() async {
    _api.clearToken();
    await _storage.deleteAll();
  }

  Future<User?> getCurrentUser() async {
    final userStr = await _storage.read(key: 'user');
    if (userStr != null) {
      return User.fromJson(jsonDecode(userStr));
    }
    return null;
  }

  Future<String?> getToken() async => _storage.read(key: 'token');
  Future<String?> getRole() async => _storage.read(key: 'role');

  Future<void> init() async {
    final token = await _storage.read(key: 'token');
    if (token != null) _api.setToken(token);
  }
}