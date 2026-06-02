import '../services/api_service.dart';

class ServiceApi {
  final ApiService _api = ApiService();

  Future<List<dynamic>> getServices({int page = 1, int quantity = 100, String search = ''}) async {
    final response = await _api.get('/services?page=$page&quantity=$quantity&search=$search');
    return response?['data'] ?? [];
  }

  Future<dynamic> createService(Map<String, dynamic> data) async {
    return await _api.post('/services', body: data);
  }

  Future<dynamic> updateService(int id, Map<String, dynamic> data) async {
    return await _api.patch('/services/$id', body: data);
  }

  Future<dynamic> deleteService(int id) async {
    return await _api.delete('/services/$id');
  }

  Future<dynamic> getServiceById(int id) async {
    return await _api.get('/services/$id');
  }
}