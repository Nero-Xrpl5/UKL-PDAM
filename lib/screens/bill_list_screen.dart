import 'dart:core';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tirta_app/screens/bill_list_screen.dart';
import '../constants/colors.dart';
import '../utils/helpers.dart';
import '../providers/app_provider.dart';
import '../services/bill_api.dart';
import '../widgets/shimmer_card.dart';
import 'payment_screen.dart';

class BillListScreen extends StatefulWidget {
  const BillListScreen({super.key});

  @override
  State<BillListScreen> createState() => _BillListScreenState();
}

class _BillListScreenState extends State<BillListScreen> {
  final BillApi _billApi = BillApi();
  List<dynamic> myBills = [];
  bool isLoading = true;
  String? errorMessage;
  String _filter = 'Semua'; // Semua, Belum, Lunas

  @override
  void initState() {
    super.initState();
    _loadBills();
  }

  Future<void> _loadBills() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    try {
      final bills = await _billApi.getMyBills(quantity: 100);
      if (mounted) {
        setState(() {
          myBills = bills;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = e.toString();
          isLoading = false;
        });
      }
    }
  }

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 11) return 'Selamat Pagi';
    if (hour < 15) return 'Selamat Siang';
    if (hour < 18) return 'Selamat Sore';
    return 'Selamat Malam';
  }

  List<dynamic> get _filteredBills {
    if (_filter == 'Belum') {
      return myBills.where((b) => b['paid'] != true).toList();
    } else if (_filter == 'Lunas') {
      return myBills.where((b) => b['paid'] == true).toList();
    }
    return myBills;
  }

  dynamic get _currentMonthBill {
    final now = DateTime.now();
    final current = myBills.where((b) {
      final month = ((b['month'] ?? 0) as num).toInt();
      final year = ((b['year'] ?? 0) as num).toInt();
      return month == now.month && year == now.year;
    }).toList();
    return current.isNotEmpty ? current.first : null;
  }

  String _monthName(int m) {
    const names = [
      '',
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember'
    ];
    return names[m];
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AppProvider>().user;
    final currentBill = _currentMonthBill;
    final filtered = _filteredBills;

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: RefreshIndicator(
        onRefresh: _loadBills,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // --- HEADER GRADIENT ---
            SliverToBoxAdapter(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF4DA6FF), Color(0xFF0077E6)],
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: const Color(0x33FFFFFF),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: const Color(0x4DFFFFFF),
                                      width: 2,
                                    ),
                                    image: const DecorationImage(
                                      image: AssetImage(
                                          'assets/images/avatar_default.png'),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _greeting,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: AppColors.white70,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      user?.name ?? 'User',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: const BoxDecoration(
                                color: Color(0x26FFFFFF),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.notifications_outlined,
                                color: AppColors.white,
                                size: 22,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // --- KARTU TAGIHAN BULAN INI ---
                        if (isLoading)
                          const ShimmerCard(
                              height: 180, margin: EdgeInsets.zero)
                        else if (currentBill != null)
                          _buildCurrentBillCard(currentBill)
                        else
                          _buildNoBillCard(),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // --- FILTER CHIPS ---
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                child: Row(
                  children: [
                    _filterChip('Semua', _filter == 'Semua'),
                    const SizedBox(width: 10),
                    _filterChip('Belum', _filter == 'Belum'),
                    const SizedBox(width: 10),
                    _filterChip('Lunas', _filter == 'Lunas'),
                  ],
                ),
              ),
            ),

            // --- LIST TAGIHAN ---
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  if (isLoading) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 20, vertical: 6),
                      child: ShimmerCard(height: 120),
                    );
                  }
                  if (errorMessage != null && index == 0) {
                    return Padding(
                      padding: const EdgeInsets.all(20),
                      child: Center(
                        child: Column(
                          children: [
                            const Icon(Icons.error_outline,
                                color: AppColors.error, size: 48),
                            const SizedBox(height: 8),
                            Text(errorMessage!,
                                textAlign: TextAlign.center),
                            TextButton(
                              onPressed: _loadBills,
                              child: const Text('Coba Lagi'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  if (filtered.isEmpty && index == 0) {
                    return Padding(
                      padding: const EdgeInsets.all(40),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(Icons.receipt_long_outlined,
                                size: 64, color: AppColors.grey300),
                            const SizedBox(height: 12),
                            Text(
                              'Tidak ada tagihan',
                              style: TextStyle(
                                color: AppColors.grey500,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  if (index >= filtered.length) return null;
                  return _buildBillItem(filtered[index]);
                },
                childCount: isLoading
                    ? 3
                    : errorMessage != null
                        ? 1
                        : filtered.isEmpty
                            ? 1
                            : filtered.length,
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

  Widget _filterChip(String label, bool isActive) {
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _filter = label),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? AppColors.mainColor : AppColors.white,
            borderRadius: BorderRadius.circular(25),
            border: isActive
                ? null
                : Border.all(color: AppColors.grey300),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isActive ? AppColors.white : AppColors.grey600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentBillCard(dynamic bill) {
    final month = ((bill['month'] ?? 1) as num).toInt();
    final year = ((bill['year'] ?? 2026) as num).toInt();
    final price = ((bill['price'] ?? 0) as num).toInt();
    final isPaid = bill['paid'] == true;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF06C270),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0x4006C270),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tagihan Bulan Ini • ${_monthName(month)} $year',
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xCCFFFFFF),
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (isPaid)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0x33FFFFFF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.check_circle,
                          color: AppColors.white, size: 14),
                      SizedBox(width: 4),
                      Text(
                        'Lunas',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            formatRupiah(price),
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: AppColors.white,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Jatuh Tempo: 30 ${_monthName(month)} $year',
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xCCFFFFFF),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              if (!isPaid)
                Expanded(
                  child: _actionButton(
                    icon: Icons.payment,
                    label: 'Bayar Sekarang',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PaymentScreen(bill: bill),
                        ),
                      ).then((_) => _loadBills());
                    },
                  ),
                ),
              if (!isPaid) const SizedBox(width: 12),
              Expanded(
                child: _actionButton(
                  icon: Icons.visibility,
                  label: 'Lihat Tagihan',
                  isSecondary: true,
                  onTap: () => _showBillDetail(bill),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNoBillCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        children: [
          Icon(Icons.check_circle,
              color: AppColors.success, size: 32),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tidak Ada Tagihan Bulan Ini',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.dark1,
                  ),
                ),
                Text(
                  'Semua tagihan sudah terbayar atau belum ada tagihan baru',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.grey500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isSecondary = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSecondary
              ? const Color(0x33FFFFFF)
              : const Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSecondary
                  ? AppColors.white
                  : const Color(0xFF06C270),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSecondary
                    ? AppColors.white
                    : const Color(0xFF06C270),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBillItem(dynamic bill) {
    final month = ((bill['month'] ?? 1) as num).toInt();
    final year = ((bill['year'] ?? 2026) as num).toInt();
    final price = ((bill['price'] ?? 0) as num).toInt();
    final isPaid = bill['paid'] == true;
    final measurement =
        bill['measurement_number']?.toString() ?? '0000';

    final Color statusColor =
        isPaid ? AppColors.success : AppColors.error;
    final Color statusBg = isPaid
        ? const Color(0xFFE8F5E9)
        : const Color(0xFFFFEBEE);
    final String statusText =
        isPaid ? 'Lunas' : 'Belum Lunas';
    final IconData statusIcon =
        isPaid ? Icons.check : Icons.warning_amber;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 6),
      child: Container(
        padding: const EdgeInsets.all(16),
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
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- ICON STATUS ---
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: statusBg,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                statusIcon,
                color: statusColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            // --- CONTENT ---
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tagihan ${_monthName(month)} $year',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.dark1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'BILL-$year-${month.toString().padLeft(2, '0')}-$measurement',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.mainColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    formatRupiah(price),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isPaid
                          ? AppColors.mainColor
                          : AppColors.error,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Jatuh Tempo 30 ${_monthName(month)} $year',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.grey500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            // --- STATUS + DETAIL BUTTON ---
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () => _showBillDetail(bill),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.mainColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Detail',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showBillDetail(dynamic bill) {
    final month = ((bill['month'] ?? 1) as num).toInt();
    final year = ((bill['year'] ?? 2026) as num).toInt();
    final price = ((bill['price'] ?? 0) as num).toInt();
    final usage = ((bill['usage_value'] ?? 0) as num).toInt();
    final isPaid = bill['paid'] == true;
    final measurement =
        bill['measurement_number']?.toString() ?? '-';
    final service =
        bill['service'] as Map<String, dynamic>?;
    final payment =
        bill['payments'] as Map<String, dynamic>?;
    final admin =
        bill['admin'] as Map<String, dynamic>?;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: const EdgeInsets.only(top: 60),
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.grey300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Detail Tagihan',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.dark1,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isPaid
                              ? const Color(0xFFE8F5E9)
                              : const Color(0xFFFFEBEE),
                          borderRadius:
                              BorderRadius.circular(20),
                        ),
                        child: Text(
                          isPaid ? 'Lunas' : 'Belum Lunas',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isPaid
                                ? AppColors.success
                                : AppColors.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _detailRow(
                      'Periode', '${_monthName(month)} $year'),
                  _detailRow('No. Meter', measurement),
                  _detailRow('Pemakaian', '$usage m³'),
                  if (service != null)
                    _detailRow('Golongan',
                        service['name']?.toString() ?? '-'),
                  if (admin != null)
                    _detailRow('Petugas',
                        admin['name']?.toString() ?? 'Admin'),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Tagihan',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.dark1,
                        ),
                      ),
                      Text(
                        formatRupiah(price),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.mainColor,
                        ),
                      ),
                    ],
                  ),
                  if (payment != null && isPaid) ...[
                    const SizedBox(height: 12),
                    _detailRow(
                      'Tanggal Bayar',
                      payment['payment_date']
                              ?.toString() ??
                          '-',
                    ),
                    _detailRow(
                      'Status Verifikasi',
                      (payment['verified'] == true)
                          ? 'Terverifikasi'
                          : 'Menunggu Verifikasi',
                    ),
                  ],
                  const SizedBox(height: 24),
                  if (!isPaid)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.mainColor,
                          foregroundColor: AppColors.white,
                          padding: const EdgeInsets.symmetric(
                              vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  PaymentScreen(bill: bill),
                            ),
                          ).then((_) => _loadBills());
                        },
                        child: const Text(
                          'Bayar Sekarang',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.grey600,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.dark1,
            ),
          ),
        ],
      ),
    );
  }
}