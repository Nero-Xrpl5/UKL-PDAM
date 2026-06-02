import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/colors.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_card.dart';
import '../widgets/custom_textfield.dart';

class ComplaintScreen extends StatefulWidget {
  const ComplaintScreen({Key? key}) : super(key: key);

  @override
  State<ComplaintScreen> createState() => _ComplaintScreenState();
}

class _ComplaintScreenState extends State<ComplaintScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  String _category = 'Pemeliharaan';
  List<Map<String, dynamic>> complaints = [];
  bool isLoading = true;

  final List<String> _categories = [
    'Pemeliharaan',
    'Ganti Meteran',
    'Pemutusan Sementara',
    'Perbaikan Pipa'
  ];

  @override
  void initState() {
    super.initState();
    _loadComplaints();
  }

  Future<void> _loadComplaints() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('complaints');
    if (saved != null) {
      final List<dynamic> decoded = jsonDecode(saved);
      setState(() {
        complaints = decoded.map((e) => Map<String, dynamic>.from(e)).toList();
        isLoading = false;
      });
    } else {
      // Default dummy data if never saved before
      setState(() {
        complaints = [
          {
            'title': 'Pipa Bocor di Jalan Utama',
            'location': 'Jl. Soekarno No.10',
            'time': '10 Menit Lalu',
            'status': 'Baru',
            'category': 'Perbaikan Pipa',
          },
          {
            'title': 'Meter Air Rusak',
            'location': 'Jl. Merdeka No.5',
            'time': '3 Jam Lalu',
            'status': 'Proses',
            'category': 'Ganti Meteran',
          },
          {
            'title': 'Air Keruh',
            'location': 'Jl. Ahmad Yani No.12',
            'time': '1 Hari Lalu',
            'status': 'Selesai',
            'category': 'Pemeliharaan',
          },
        ];
        isLoading = false;
      });
      _saveComplaints();
    }
  }

  Future<void> _saveComplaints() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('complaints', jsonEncode(complaints));
  }

  void _submitComplaint() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        complaints.insert(0, {
          'title': _titleCtrl.text,
          'description': _descCtrl.text,
          'location': _locationCtrl.text.isNotEmpty ? _locationCtrl.text : 'Lokasi saya',
          'time': 'Baru saja',
          'status': 'Baru',
          'category': _category,
        });
      });
      _titleCtrl.clear();
      _descCtrl.clear();
      _locationCtrl.clear();
      _saveComplaints();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pengaduan berhasil dikirim!'), backgroundColor: AppColors.success),
      );
    }
  }

  void _updateStatus(int index, String newStatus) {
    setState(() {
      complaints[index]['status'] = newStatus;
    });
    _saveComplaints();
  }

  void _deleteComplaint(int index) {
    setState(() {
      complaints.removeAt(index);
    });
    _saveComplaints();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        title: const Text('Pengaduan'),
        backgroundColor: AppColors.mainColor,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomCard(
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Buat Pengaduan Baru', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 16),
                          CustomTextField(
                            label: 'Judul Pengaduan',
                            hint: 'Masukkan judul',
                            icon: Icons.title,
                            controller: _titleCtrl,
                            validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
                          ),
                          const SizedBox(height: 16),
                          CustomTextField(
                            label: 'Lokasi',
                            hint: 'Alamat lokasi pengaduan',
                            icon: Icons.location_on_outlined,
                            controller: _locationCtrl,
                            validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
                          ),
                          const SizedBox(height: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Kategori', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.dark1)),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                decoration: BoxDecoration(
                                  color: AppColors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [BoxShadow(color: AppColors.dark4.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 2))],
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: _category,
                                    isExpanded: true,
                                    icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.mainColor),
                                    items: _categories
                                        .map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 14))))
                                        .toList(),
                                    onChanged: (v) => setState(() => _category = v!),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          CustomTextField(
                            label: 'Deskripsi',
                            hint: 'Jelaskan detail pengaduan...',
                            icon: Icons.description_outlined,
                            controller: _descCtrl,
                            maxLines: 4,
                            validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
                          ),
                          const SizedBox(height: 20),
                          CustomButton(text: 'Kirim Pengaduan', onPressed: _submitComplaint),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text('Riwayat Pengaduan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  if (complaints.isEmpty)
                    const Center(child: Text('Belum ada pengaduan'))
                  else
                    ...complaints.asMap().entries.map((entry) {
                      final index = entry.key;
                      final c = entry.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: CustomCard(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(c['status']!).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(Icons.report_problem_outlined, color: _getStatusColor(c['status']!)),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(c['title'] ?? '-', style: const TextStyle(fontWeight: FontWeight.bold)),
                                        Text(c['location'] ?? '-', style: TextStyle(fontSize: 12, color: AppColors.dark3)),
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(color: AppColors.subtle, borderRadius: BorderRadius.circular(8)),
                                              child: Text(c['category'] ?? '-', style: const TextStyle(fontSize: 10, color: AppColors.mainColor, fontWeight: FontWeight.w600)),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(c['time'] ?? '-', style: TextStyle(fontSize: 11, color: AppColors.dark3)),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(c['status']!).withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(c['status']!, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _getStatusColor(c['status']!))),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              // Admin actions to change status
                              Wrap(
                                spacing: 8,
                                children: [
                                  _statusChip(index, 'Baru', AppColors.error),
                                  _statusChip(index, 'Proses', AppColors.warning),
                                  _statusChip(index, 'Selesai', AppColors.success),
                                  ActionChip(
                                    label: const Text('Hapus', style: TextStyle(fontSize: 11)),
                                    onPressed: () => _deleteComplaint(index),
                                    backgroundColor: AppColors.error.withOpacity(0.1),
                                    side: BorderSide.none,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                ],
              ),
            ),
    );
  }

  Widget _statusChip(int index, String status, Color color) {
    final isSelected = complaints[index]['status'] == status;
    return ActionChip(
      label: Text(status, style: TextStyle(fontSize: 11, color: isSelected ? AppColors.white : color)),
      onPressed: () => _updateStatus(index, status),
      backgroundColor: isSelected ? color : color.withOpacity(0.1),
      side: BorderSide.none,
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Baru': return AppColors.error;
      case 'Proses': return AppColors.warning;
      case 'Selesai': return AppColors.success;
      default: return AppColors.mainColor;
    }
  }
}