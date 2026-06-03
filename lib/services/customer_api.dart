import '../models/customer.dart';
import 'api_service.dart';

class CustomerApi {
  static final ApiService _api = ApiService();

  static Future<List<Customer>> getCustomers() async {
    final response = await _api.get('/customers?page=1&quantity=100');
    final List<dynamic> data = response?['data'] ?? [];
    return data.map((e) => Customer.fromJson(e as Map<String, dynamic>)).toList();
  }

  static Future<void> deleteCustomer(int id) async {
    await _api.delete('/customers/$id');
  }

  static Future<void> updateCustomer(int id, Map<String, dynamic> payload) async {
    await _api.patch('/customers/$id', body: payload);
  }

  static Future<void> createCustomer(Map<String, dynamic> payload) async {
    await _api.post('/customers', body: payload);
  }

  Future getMeDirect(String endpoint) async {}
}