import '../services/api_service.dart';

class CustomerApi {
  final ApiService _api = ApiService();

  Future<List<dynamic>> getCustomers({int page = 1, int quantity = 100, String search = ''}) async {
    final response = await _api.get('/customers?page=$page&quantity=$quantity&search=$search');
    return response?['data'] ?? [];
  }

  Future<dynamic> createCustomer(Map<String, dynamic> data) async {
    return await _api.post('/customers', body: data);
  }

  Future<dynamic> updateCustomer(int id, Map<String, dynamic> data) async {
    return await _api.patch('/customers/$id', body: data);
  }

  Future<dynamic> deleteCustomer(int id) async {
    return await _api.delete('/customers/$id');
  }

  Future<dynamic> getCustomerById(int id) async {
    return await _api.get('/customers/$id');
  }

  Future<dynamic> getMe() async {
    return await _api.get('/customers/me');
  }
}