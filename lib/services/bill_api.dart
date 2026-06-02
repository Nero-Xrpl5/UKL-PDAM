import '../services/api_service.dart';

class BillApi {
  final ApiService _api = ApiService();

  Future<List<dynamic>> getBills({int page = 1, int quantity = 100, String search = ''}) async {
    final response = await _api.get('/bills?page=$page&quantity=$quantity&search=$search');
    return response?['data'] ?? [];
  }

  Future<List<dynamic>> getMyBills({int page = 1, int quantity = 100, String search = ''}) async {
    final response = await _api.get('/bills/me?page=$page&quantity=$quantity&search=$search');
    return response?['data'] ?? [];
  }

  Future<dynamic> createBill(Map<String, dynamic> data) async {
    return await _api.post('/bills', body: data);
  }

  Future<dynamic> updateBill(int id, Map<String, dynamic> data) async {
    return await _api.patch('/bills/$id', body: data);
  }

  Future<dynamic> deleteBill(int id) async {
    return await _api.delete('/bills/$id');
  }

  Future<dynamic> getBillById(int id) async {
    return await _api.get('/bills/$id');
  }

  Future<dynamic> getMyBillById(int id) async {
    return await _api.get('/bills/me/$id');
  }
}