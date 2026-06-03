import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';

class PaymentApi {
  final ApiService _api = ApiService();

  /// Customer: Upload bukti pembayaran
  Future<dynamic> createPayment(int billId, XFile file) async {
    return await _api.postMultipart(
      '/payments',
      fields: {'bill_id': billId.toString()},
      file: file,
      fileField: 'file',
    );
  }

  /// Admin: Terima/Verifikasi pembayaran (PATCH)
  Future<dynamic> verifyPayment(int paymentId) async {
    return await _api.patch('/payments/$paymentId');
  }

  /// Admin: Tolak/Hapus pembayaran (DELETE)
  Future<dynamic> rejectPayment(int paymentId) async {
    return await _api.delete('/payments/$paymentId');
  }

  /// Admin: Lihat semua pembayaran
  Future<List<dynamic>> getPayments({int page = 1, int quantity = 100}) async {
    final response = await _api.get('/payments?page=$page&quantity=$quantity&search=');
    return response?['data'] ?? [];
  }

  /// Customer: Lihat pembayaran saya
  Future<List<dynamic>> getMyPayments({int page = 1, int quantity = 100}) async {
    final response = await _api.get('/payments/me?page=$page&quantity=$quantity&search=');
    return response?['data'] ?? [];
  }
}