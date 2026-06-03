import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/service_request.dart';

class ServiceRequestService {
  static const String _key = 'service_requests';

  Future<List<ServiceRequest>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_key);
    if (data == null || data.isEmpty) {
      final dummy = _getDummyData();
      await saveAll(dummy);
      return dummy;
    }
    final List<dynamic> decoded = jsonDecode(data);
    return decoded.map((e) => ServiceRequest.fromJson(e)).toList();
  }

  Future<void> saveAll(List<ServiceRequest> list) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _key, jsonEncode(list.map((e) => e.toJson()).toList()));
  }

  Future<void> updateStatus(String id, String status) async {
    final list = await getAll();
    final index = list.indexWhere((r) => r.id == id);
    if (index != -1) {
      final old = list[index];
      list[index] = ServiceRequest(
        id: old.id,
        customerName: old.customerName,
        customerNumber: old.customerNumber,
        serviceName: old.serviceName,
        serviceType: old.serviceType,
        price: old.price,
        status: status,
        createdAt: old.createdAt,
      );
      await saveAll(list);
    }
  }

  List<ServiceRequest> _getDummyData() {
    return [
      ServiceRequest(
        id: '1',
        customerName: 'Siti Rahayu',
        customerNumber: 'PDAM-2024-00845',
        serviceName: 'Pemasangan Baru',
        serviceType: 'installation',
        price: 750000,
        status: 'Baru',
        createdAt: DateTime(2026, 7, 20, 8, 30),
      ),
      ServiceRequest(
        id: '2',
        customerName: 'Agus Prasetyo',
        customerNumber: 'PDAM-2022-00747',
        serviceName: 'Perbaikan Pipa',
        serviceType: 'repair',
        price: 250000,
        status: 'Baru',
        createdAt: DateTime(2026, 7, 19, 8, 30),
      ),
      ServiceRequest(
        id: '3',
        customerName: 'Hendra Susanto',
        customerNumber: 'PDAM-2012-00099',
        serviceName: 'Perbaikan Pipa',
        serviceType: 'repair',
        price: 250000,
        status: 'Diproses',
        createdAt: DateTime(2026, 7, 18, 8, 30),
      ),
      ServiceRequest(
        id: '4',
        customerName: 'Hendra Susanto',
        customerNumber: 'PDAM-2012-00099',
        serviceName: 'Pemutusan PDAM',
        serviceType: 'disconnection',
        price: 100000,
        status: 'Diproses',
        createdAt: DateTime(2026, 7, 17, 8, 30),
      ),
    ];
  }
}