import 'dart:io';
import '../constants/api.dart';
import '../services/api_service.dart';

class PaymentApi {
  final ApiService _api = ApiService();

  Future<List<dynamic>> getPayments({int page = 1, int quantity = 100, String search = ''}) async {
    final response = await _api.get('/payments?page=$page&quantity=$quantity&search=$search');
    return response?['data'] ?? [];
  }

  Future<List<dynamic>> getMyPayments({int page = 1, int quantity = 100, String search = ''}) async {
    final response = await _api.get('/payments/me?page=$page&quantity=$quantity&search=$search');
    return response?['data'] ?? [];
  }

  Future<dynamic> createPayment(int billId, File file) async {
    return await _api.postMultipart(
      '/payments',
      fields: {'bill_id': billId.toString()},
      file: file,
      fileField: 'file',
    );
  }

  Future<dynamic> verifyPayment(int id) async {
    return await _api.patch('/payments/$id');
  }

  Future<dynamic> rejectPayment(int id) async {
    return await _api.delete('/payments/$id');
  }

  Future<dynamic> getPaymentById(int id) async {
    return await _api.get('/payments/$id');
  }

  Future<dynamic> getMyPaymentById(int id) async {
    return await _api.get('/payments/me/$id');
  }

  String getPaymentProofUrl(String filename) {
    return '${ApiConfig.baseUrl}/payment-proof/$filename';
  }
}