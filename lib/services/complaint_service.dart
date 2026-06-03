import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/complaint.dart';

class ComplaintService {
  static final ComplaintService _instance = ComplaintService._internal();
  factory ComplaintService() => _instance;
  ComplaintService._internal();

  static const String _storageKey = 'complaints_data';

  Future<List<Complaint>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonStr = prefs.getString(_storageKey);
    if (jsonStr == null || jsonStr.isEmpty) return [];
    final List<dynamic> decoded = jsonDecode(jsonStr);
    return decoded.map((e) => Complaint.fromJson(e)).toList();
  }

  Future<void> saveAll(List<Complaint> complaints) async {
    final prefs = await SharedPreferences.getInstance();
    final String jsonStr =
        jsonEncode(complaints.map((c) => c.toJson()).toList());
    await prefs.setString(_storageKey, jsonStr);
  }

  Future<Complaint> create(Complaint complaint) async {
    final list = await getAll();
    final newComplaint = Complaint(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      serviceName: complaint.serviceName,
      description: complaint.description,
      category: complaint.category,
      isActive: complaint.isActive,
      createdAt: DateTime.now(),
    );
    list.add(newComplaint);
    await saveAll(list);
    return newComplaint;
  }

  Future<Complaint> update(Complaint complaint) async {
    final list = await getAll();
    final index = list.indexWhere((c) => c.id == complaint.id);
    if (index != -1) {
      list[index] = complaint;
      await saveAll(list);
    }
    return complaint;
  }

  Future<void> delete(String id) async {
    final list = await getAll();
    list.removeWhere((c) => c.id == id);
    await saveAll(list);
  }
}