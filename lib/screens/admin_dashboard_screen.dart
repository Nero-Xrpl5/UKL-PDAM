import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../services/customer_api.dart';
import '../services/service_api.dart';
import '../services/payment_api.dart';
import '../services/api_service.dart';
import '../constants/api.dart';
import 'customer_list_screen.dart';
import 'service_list_screen.dart';
import 'bill_list_screen.dart';
import 'notification_screen.dart';
import 'profile_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final CustomerApi _customerApi = CustomerApi();
  final ServiceApi _serviceApi = ServiceApi();
  final PaymentApi _paymentApi = PaymentApi();
  final ApiService _api = ApiService();

  int totalCustomers = 0;
  int totalServices = 0;
  int pendingPayments = 0;
  int totalBillsAmount = 0;
  List<dynamic> recentServices = [];
  bool isLoading = true;
  String adminName = 'Admin';

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    try {
      final customerResponse = await _api.get('${ApiConfig.customers}?page=1&quantity=1');
      final serviceResponse = await _api.get('${ApiConfig.services}?page=1&quantity=1');
      final servicesList = await _serviceApi.getServices(quantity: 5);
      final payments = await _paymentApi.getPayments(quantity: 100);
      final bills = await _api.get('${ApiConfig.bills}?page=1&quantity=100');

      int billsTotal = 0;
      if (bills != null && bills['data'] != null) {
        final List<dynamic> billsData = bills['data'];
        for (final b in billsData) {
          billsTotal += ((b['price'] ?? 0) as num).toInt();
        }
      }

      setState(() {
        totalCustomers = (customerResponse?['count'] as num?)?.toInt() ?? 0;
        totalServices = (serviceResponse?['count'] as num?)?.toInt() ?? 0;
        pendingPayments = payments.where((p) => p['verified'] == false).length;
        totalBillsAmount = billsTotal;
        recentServices = servicesList;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  String _formatCompactNumber(int num) {
    if (num >= 1000000) return '${(num / 1000000).toStringAsFixed(1)}Jt';
    if (num >= 1000) return '${(num / 1000).toStringAsFixed(1)}K';
    return num.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      body: RefreshIndicator(
        onRefresh: _loadDashboardData,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // Header Section
            SliverToBoxAdapter(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF4DA6FF),
                      Color(0xFF0077E6),
                      Color(0xFF005BB5),
                    ],
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top bar: profile + notification
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.25),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.4),
                                      width: 2,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.person,
                                    color: Colors.white,
                                    size: 26,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Selamat Pagi, Admin',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.white70,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      adminName,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const NotificationScreen(),
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.notifications_outlined,
                                  color: Colors.white,
                                  size: 22,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // Stats Row 1
                        Row(
                          children: [
                            Expanded(
                              child: _statCard(
                                icon: Icons.people_outline,
                                value: _formatCompactNumber(totalCustomers),
                                label: 'Total Pelanggan',
                                subLabel: '12% Bulan Ini',
                                iconBg: const Color(0xFFE3F2FD),
                                iconColor: const Color(0xFF2196F3),
                                trendUp: true,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _statCard(
                                icon: Icons.receipt_long,
                                value: 'Rp ${_formatCompactNumber(totalBillsAmount)}',
                                label: 'Tagihan Bulan Ini',
                                subLabel: '5.2% Bulan lalu',
                                iconBg: const Color(0xFFF3E5F5),
                                iconColor: const Color(0xFF9C27B0),
                                trendUp: false,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Stats Row 2
                        Row(
                          children: [
                            Expanded(
                              child: _statCard(
                                icon: Icons.build,
                                value: '$totalServices',
                                label: 'Total Layanan',
                                subLabel: 'Tersedia',
                                iconBg: const Color(0xFFE8F5E9),
                                iconColor: const Color(0xFF4CAF50),
                                trendUp: true,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _statCard(
                                icon: Icons.water_drop,
                                value: '94%',
                                label: 'Kualitas Air',
                                subLabel: 'Standar SNI',
                                iconBg: const Color(0xFFE0F7FA),
                                iconColor: const Color(0xFF00ACC1),
                                trendUp: true,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Menu Grid
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Menu Cepat',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A237E),
                      ),
                    ),
                    const SizedBox(height: 16),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 4,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.85,
                      children: [
                        _menuItem(
                          icon: Icons.people_outline,
                          label: 'Data\nPelanggan',
                          color: const Color(0xFF4CAF50),
                          bgColor: const Color(0xFFE8F5E9),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const CustomerListScreen(),
                            ),
                          ),
                        ),
                        _menuItem(
                          icon: Icons.receipt_long,
                          label: 'Tagihan',
                          color: const Color(0xFF2196F3),
                          bgColor: const Color(0xFFE3F2FD),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const BillListScreen(),
                            ),
                          ),
                        ),
                        _menuItem(
                          icon: Icons.build,
                          label: 'Layanan',
                          color: const Color(0xFFFF9800),
                          bgColor: const Color(0xFFFFF3E0),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ServiceListScreen(),
                            ),
                          ),
                        ),
                        _menuItem(
                          icon: Icons.assessment_outlined,
                          label: 'Laporan',
                          color: const Color(0xFF9C27B0),
                          bgColor: const Color(0xFFF3E5F5),
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Fitur laporan belum tersedia'),
                                backgroundColor: Color(0xFF757575),
                              ),
                            );
                          },
                        ),
                        _menuItem(
                          icon: Icons.handyman_outlined,
                          label: 'Pemeliharaan',
                          color: const Color(0xFFF44336),
                          bgColor: const Color(0xFFFFEBEE),
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Fitur pemeliharaan belum tersedia'),
                                backgroundColor: Color(0xFF757575),
                              ),
                            );
                          },
                        ),
                        _menuItem(
                          icon: Icons.location_on_outlined,
                          label: 'Zona\nWilayah',
                          color: const Color(0xFF00BCD4),
                          bgColor: const Color(0xFFE0F7FA),
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Fitur zona wilayah belum tersedia'),
                                backgroundColor: Color(0xFF757575),
                              ),
                            );
                          },
                        ),
                        _menuItem(
                          icon: Icons.settings_outlined,
                          label: 'Pengaturan',
                          color: const Color(0xFF607D8B),
                          bgColor: const Color(0xFFECEFF1),
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Fitur pengaturan belum tersedia'),
                                backgroundColor: Color(0xFF757575),
                              ),
                            );
                          },
                        ),
                        _menuItem(
                          icon: Icons.logout_outlined,
                          label: 'Keluar',
                          color: const Color(0xFFE53935),
                          bgColor: const Color(0xFFFFEBEE),
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ProfileScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Aktivitas Layanan (Services) - from backend /services
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Aktivitas Layanan',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A237E),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ServiceListScreen(),
                            ),
                          ),
                          child: Row(
                            children: [
                              Text(
                                'Lihat Semua',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: const Color(0xFF48A7FF),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const Icon(
                                Icons.chevron_right,
                                size: 16,
                                color: Color(0xFF48A7FF),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (isLoading)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: CircularProgressIndicator(
                            color: Color(0xFF48A7FF),
                          ),
                        ),
                      )
                    else if (recentServices.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.build_circle_outlined,
                                size: 48,
                                color: Colors.grey.shade300,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Belum ada layanan tersedia',
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Tambah layanan di menu Layanan',
                                style: TextStyle(
                                  color: Colors.grey.shade400,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ...recentServices.map((s) {
                        final String name = s['name']?.toString() ?? 'Layanan';
                        final int minUsage = ((s['min_usage'] ?? 0) as num).toInt();
                        final int maxUsage = ((s['max_usage'] ?? 0) as num).toInt();
                        final int price = ((s['price'] ?? 0) as num).toInt();
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFF3E0),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.build,
                                    color: Color(0xFFFF9800),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                          color: Color(0xFF1A237E),
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Pemakaian: $minUsage - $maxUsage m³',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE8F5E9),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    'Rp ${price.toString()}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF4CAF50),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(
              child: SizedBox(height: 24),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statCard({
    required IconData icon,
    required String value,
    required String label,
    required String subLabel,
    required Color iconBg,
    required Color iconColor,
    required bool trendUp,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              Row(
                children: [
                  Icon(
                    trendUp ? Icons.trending_up : Icons.trending_down,
                    size: 14,
                    color: trendUp ? const Color(0xFF4CAF50) : const Color(0xFFE53935),
                  ),
                  const SizedBox(width: 2),
                  Text(
                    subLabel.split(' ').first,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: trendUp ? const Color(0xFF4CAF50) : const Color(0xFFE53935),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A237E),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subLabel,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuItem({
    required IconData icon,
    required String label,
    required Color color,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1A237E),
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}