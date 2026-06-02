import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/colors.dart';
import '../providers/app_provider.dart';
import '../services/payment_api.dart';
import '../widgets/custom_card.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final PaymentApi _paymentApi = PaymentApi();
  List<Map<String, dynamic>> notifications = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCachedNotifications();
  }

  Future<void> _loadCachedNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('notifications_cache');
    if (saved != null) {
      final List<dynamic> decoded = jsonDecode(saved);
      setState(() {
        notifications = decoded.map((e) => Map<String, dynamic>.from(e)).toList();
      });
    }
    // Sync from backend after cache
    if (mounted) {
      _fetchFromBackend();
    }
  }

  Future<void> _fetchFromBackend() async {
    final isAdmin = context.read<AppProvider>().isAdmin;
    try {
      final payments = isAdmin
          ? await _paymentApi.getPayments(quantity: 100)
          : await _paymentApi.getMyPayments(quantity: 100);

      final List<Map<String, dynamic>> newNotifications = [];

      for (final p in payments) {
        if (p['verified'] == true) {
          final bill = p['bill'] as Map<String, dynamic>?;
          final customer = bill?['customer'] as Map<String, dynamic>?;
          final month = bill?['month']?.toString() ?? '-';
          final year = bill?['year']?.toString() ?? '-';
          final customerName = customer?['name']?.toString() ?? 'Pelanggan';

          if (isAdmin) {
            newNotifications.add({
              'title': 'Pembayaran Diterima',
              'message': '$customerName sudah membayar tagihan bulan $month/$year',
              'time': _formatTime(p['createdAt']?.toString()),
              'isRead': false,
              'icon': 'payments',
              'colorHex': _colorToHex(AppColors.success),
              'type': 'payment_verified',
            });
          } else {
            newNotifications.add({
              'title': 'Pembayaran Diverifikasi',
              'message': 'Pembayaran tagihan bulan $month/$year telah diverifikasi admin',
              'time': _formatTime(p['createdAt']?.toString()),
              'isRead': false,
              'icon': 'verified',
              'colorHex': _colorToHex(AppColors.success),
              'type': 'payment_verified',
            });
          }
        }
      }

      // System welcome notification
      newNotifications.add({
        'title': 'Selamat Datang',
        'message': 'Aplikasi PDAM TirtaApp siap digunakan',
        'time': 'Sekarang',
        'isRead': true,
        'icon': 'water_drop',
        'colorHex': _colorToHex(AppColors.mainColor),
        'type': 'system',
      });

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('notifications_cache', jsonEncode(newNotifications));

      if (mounted) {
        setState(() {
          notifications = newNotifications;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  String _colorToHex(Color color) {
    return '0x${color.value.toRadixString(16).padLeft(8, '0')}';
  }

  Color _hexToColor(String hex) {
    return Color(int.parse(hex));
  }

  IconData _iconFromString(String name) {
    switch (name) {
      case 'payments': return Icons.payments;
      case 'verified': return Icons.verified;
      case 'water_drop': return Icons.water_drop;
      default: return Icons.notifications;
    }
  }

  String _formatTime(String? isoTime) {
    if (isoTime == null || isoTime.isEmpty) return 'Baru saja';
    try {
      final dt = DateTime.parse(isoTime);
      final now = DateTime.now();
      final diff = now.difference(dt);
      if (diff.inMinutes < 1) return 'Baru saja';
      if (diff.inHours < 1) return '${diff.inMinutes} menit lalu';
      if (diff.inDays < 1) return '${diff.inHours} jam lalu';
      if (diff.inDays < 7) return '${diff.inDays} hari lalu';
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return 'Baru saja';
    }
  }

  void _markAsRead(int index) {
    setState(() {
      notifications[index]['isRead'] = true;
    });
    _saveCache();
  }

  Future<void> _saveCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('notifications_cache', jsonEncode(notifications));
  }

  Future<void> _clearAll() async {
    setState(() => notifications.clear());
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('notifications_cache');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        title: const Text('Notifikasi'),
        backgroundColor: AppColors.mainColor,
        actions: [
          if (notifications.isNotEmpty)
            TextButton(
              onPressed: _clearAll,
              child: const Text('Hapus Semua', style: TextStyle(color: AppColors.white)),
            ),
        ],
      ),
      body: isLoading && notifications.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : notifications.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.notifications_off_outlined, size: 64, color: AppColors.dark3),
                      const SizedBox(height: 16),
                      Text('Belum ada notifikasi', style: TextStyle(color: AppColors.dark3, fontSize: 16)),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _fetchFromBackend,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      final n = notifications[index];
                      final isRead = n['isRead'] as bool;
                      final color = _hexToColor(n['colorHex'] as String);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: CustomCard(
                          color: isRead ? AppColors.light3 : AppColors.white,
                          onTap: () => _markAsRead(index),
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: color.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(_iconFromString(n['icon'] as String), color: color),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            n['title'] as String,
                                            style: TextStyle(
                                              fontWeight: isRead ? FontWeight.w600 : FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                        if (!isRead)
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
                                      style: TextStyle(fontSize: 13, color: AppColors.dark2, height: 1.4),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      n['time'] as String,
                                      style: TextStyle(fontSize: 11, color: AppColors.dark3),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}