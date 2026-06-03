import 'package:flutter/material.dart';
import '../constants/colors.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final List<Map<String, dynamic>> _notifications = [
    {
      'title': 'Tagihan Baru',
      'message': 'Tagihan bulan Juni 2026 telah tersedia.',
      'time': '2 jam lalu',
      'isRead': false,
      'icon': Icons.receipt_long,
      'color': const Color(0xFF2196F3),
      'bgColor': const Color(0xFFE3F2FD),
    },
    {
      'title': 'Pembayaran Berhasil',
      'message': 'Pembayaran tagihan Mei 2026 telah diverifikasi.',
      'time': '1 hari lalu',
      'isRead': true,
      'icon': Icons.check_circle,
      'color': const Color(0xFF4CAF50),
      'bgColor': const Color(0xFFE8F5E9),
    },
    {
      'title': 'Pengaduan Diproses',
      'message': 'Pengaduan Anda tentang air keruh sedang diproses.',
      'time': '3 hari lalu',
      'isRead': true,
      'icon': Icons.support_agent,
      'color': const Color(0xFFFF9800),
      'bgColor': const Color(0xFFFFF3E0),
    },
  ];

  void _deleteAll() {
    setState(() => _notifications.clear());
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Semua notifikasi dihapus'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        title: const Text('Notifikasi'),
        backgroundColor: AppColors.mainColor,
        actions: [
          TextButton(
            onPressed: _deleteAll,
            child: const Text(
              'Hapus Semua',
              style: TextStyle(color: AppColors.white, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
      body: _notifications.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off_outlined, size: 64, color: AppColors.grey300),
                  const SizedBox(height: 16),
                  Text(
                    'Tidak ada notifikasi',
                    style: TextStyle(color: AppColors.grey500, fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _notifications.length,
              itemBuilder: (context, index) {
                final n = _notifications[index];
                return Container(
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
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: n['bgColor'] as Color,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(n['icon'] as IconData, color: n['color'] as Color),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    n['title'] as String,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                if (!(n['isRead'] as bool))
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: AppColors.error,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              n['message'] as String,
                              style: TextStyle(fontSize: 13, color: AppColors.grey600, height: 1.4),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              n['time'] as String,
                              style: TextStyle(fontSize: 11, color: AppColors.grey400),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}