import 'package:flutter/material.dart';
import '../constants/colors.dart';

class ComplaintScreen extends StatefulWidget {
  const ComplaintScreen({super.key});

  @override
  State<ComplaintScreen> createState() => _ComplaintScreenState();
}

class _ComplaintScreenState extends State<ComplaintScreen> {
  final _subjectCtrl = TextEditingController();
  final _messageCtrl = TextEditingController();
  final List<Map<String, dynamic>> _complaints = [];

  void _submitComplaint() {
    if (_subjectCtrl.text.isEmpty || _messageCtrl.text.isEmpty) return;
    setState(() {
      _complaints.insert(0, {
        'subject': _subjectCtrl.text,
        'message': _messageCtrl.text,
        'date': DateTime.now(),
        'status': 'Diproses',
      });
    });
    _subjectCtrl.clear();
    _messageCtrl.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Pengaduan berhasil dikirim!'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        title: const Text('Pengaduan'),
        backgroundColor: AppColors.mainColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0A000000),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.mainColor10,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.support_agent, color: AppColors.mainColor),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Buat Pengaduan Baru',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.dark1,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Sampaikan keluhan Anda terkait layanan PDAM',
                              style: TextStyle(fontSize: 12, color: AppColors.dark3),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _subjectCtrl,
                    decoration: InputDecoration(
                      labelText: 'Judul Pengaduan',
                      hintText: 'Contoh: Air keruh, meteran bocor...',
                      filled: true,
                      fillColor: AppColors.grey100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: const Icon(Icons.title, color: AppColors.dark3),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _messageCtrl,
                    maxLines: 4,
                    decoration: InputDecoration(
                      labelText: 'Detail Keluhan',
                      hintText: 'Jelaskan detail keluhan Anda...',
                      filled: true,
                      fillColor: AppColors.grey100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: const Icon(Icons.description, color: AppColors.dark3),
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: _submitComplaint,
                      icon: const Icon(Icons.send, size: 18),
                      label: const Text('Kirim Pengaduan', style: TextStyle(fontWeight: FontWeight.w600)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.mainColor,
                        foregroundColor: AppColors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Riwayat Pengaduan',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.dark1),
            ),
            const SizedBox(height: 12),
            if (_complaints.isEmpty)
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.inbox_outlined, size: 56, color: AppColors.grey300),
                      const SizedBox(height: 12),
                      Text(
                        'Belum ada pengaduan',
                        style: TextStyle(color: AppColors.grey500, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Pengaduan Anda akan muncul di sini',
                        style: TextStyle(color: AppColors.grey400, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              )
            else
              ..._complaints.map((c) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x08000000),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            c['subject'],
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: c['status'] == 'Selesai'
                                ? AppColors.success10
                                : AppColors.warning10,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            c['status'],
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: c['status'] == 'Selesai' ? AppColors.success : const Color(0xFFFF9800),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      c['message'],
                      style: TextStyle(fontSize: 13, color: AppColors.grey600, height: 1.5),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${c['date'].day}/${c['date'].month}/${c['date'].year}',
                      style: TextStyle(fontSize: 11, color: AppColors.grey400),
                    ),
                  ],
                ),
              )).toList(),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _subjectCtrl.dispose();
    _messageCtrl.dispose();
    super.dispose();
  }
}