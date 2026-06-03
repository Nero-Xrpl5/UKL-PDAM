import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tirta_app/screens/payment_verification_screen.dart';
import '../constants/colors.dart';
import '../utils/helpers.dart';
import '../providers/app_provider.dart';
import '../services/bill_api.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/shimmer_card.dart';
import 'main_screen.dart';
import '';

class BillListScreen extends StatefulWidget {
  const BillListScreen({super.key});

  @override
  State<BillListScreen> createState() => _BillListScreenState();
}

class _BillListScreenState extends State<BillListScreen> {
  final BillApi _billApi = BillApi();

  List<dynamic> bills = [];
  List<dynamic> filteredBills = [];
  bool isLoading = true;
  String? errorMessage;
  String _filter = 'Semua';
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadBills();
    _searchCtrl.addListener(_onSearch);
  }

  @override
  void dispose() {
    _searchCtrl.removeListener(_onSearch);
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadBills() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    try {
      final data = await _billApi.getBills(quantity: 100);
      setState(() {
        bills = data;
        _applyFilterAndSearch();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  void _onSearch() => _applyFilterAndSearch();

  void _applyFilterAndSearch() {
    List<dynamic> result = bills;
    if (_filter == 'Lunas') {
      result = result.where((b) => b['paid'] == true).toList();
    } else if (_filter == 'Belum') {
      result = result.where((b) => b['paid'] != true).toList();
    }
    final query = _searchCtrl.text.toLowerCase();
    if (query.isNotEmpty) {
      result = result.where((b) {
        final cName = (b['customer']?['name'] ?? '').toString().toLowerCase();
        final cNum =
            (b['customer']?['customer_number'] ?? '').toString().toLowerCase();
        final bNum = (b['measurement_number'] ?? '').toString().toLowerCase();
        return cName.contains(query) || cNum.contains(query) || bNum.contains(query);
      }).toList();
    }
    setState(() => filteredBills = result);
  }

  String _getStatus(dynamic bill) {
    if (bill['paid'] == true) return 'Lunas';
    final p = bill['payments'];
    if (p != null && p is Map && p['verified'] == false) {
      return 'Menunggu Verifikasi';
    }
    return 'Belum Bayar';
  }

  Color _statusColor(String s) {
    if (s == 'Lunas') return AppColors.success;
    if (s == 'Menunggu Verifikasi') return AppColors.mainColor;
    return AppColors.error;
  }

  Color _statusBg(String s) {
    if (s == 'Lunas') return const Color(0xFFE8F5E9);
    if (s == 'Menunggu Verifikasi') return const Color(0xFFE3F2FD);
    return const Color(0xFFFFEBEE);
  }

  Future<void> _deleteBill(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Hapus Tagihan?',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Data tagihan ini akan dihapus permanen.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await _billApi.deleteBill(id);
      _loadBills();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tagihan berhasil dihapus'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menghapus: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showCreateDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Buka form tambah tagihan')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lunasCount = bills.where((b) => b['paid'] == true).length;
    final belumCount = bills.where((b) => b['paid'] != true).length;

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      bottomNavigationBar: BottomNav(
        currentIndex: 2,
        onTap: (index) {
          if (index == 2) return;
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const MainScreen()),
            (route) => false,
          );
        }, isAdmin: Provider.of<AppProvider>(context).isAdmin,
      ),
      body: RefreshIndicator(
        onRefresh: _loadBills,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // HEADER
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
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.receipt_long,
                                    color: AppColors.white, size: 28),
                                SizedBox(width: 12),
                                Text(
                                  'Kelola Bill',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.white,
                                  ),
                                ),
                              ],
                            ),
                            GestureDetector(
                              onTap: _showCreateDialog,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: const Color(0x26FFFFFF),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                      color: const Color(0x4DFFFFFF)),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(Icons.add,
                                        color: AppColors.white, size: 18),
                                    SizedBox(width: 4),
                                    Text(
                                      'Buat',
                                      style: TextStyle(
                                        color: AppColors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // SEARCH
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.search,
                                  color: AppColors.dark3),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextField(
                                  controller: _searchCtrl,
                                  decoration: const InputDecoration(
                                    hintText: 'Cari nama / no. pelanggan..',
                                    hintStyle:
                                        TextStyle(color: AppColors.grey500),
                                    border: InputBorder.none,
                                    contentPadding:
                                        EdgeInsets.symmetric(vertical: 14),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // FILTER CHIPS
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                child: Row(
                  children: [
                    _filterChip('Semua', bills.length, _filter == 'Semua'),
                    const SizedBox(width: 10),
                    _filterChip('Lunas', lunasCount, _filter == 'Lunas'),
                    const SizedBox(width: 10),
                    _filterChip('Belum', belumCount, _filter == 'Belum'),
                  ],
                ),
              ),
            ),

            // LIST
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  if (isLoading) {
                    return const Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                      child: ShimmerCard(height: 100),
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
                  if (filteredBills.isEmpty && index == 0) {
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
                  if (index >= filteredBills.length) return null;
                  return _buildBillItem(filteredBills[index]);
                },
                childCount: isLoading
                    ? 5
                    : errorMessage != null
                        ? 1
                        : filteredBills.isEmpty
                            ? 1
                            : filteredBills.length,
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }

  Widget _filterChip(String label, int count, bool isActive) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => _filter = label);
          _applyFilterAndSearch();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? AppColors.mainColor : AppColors.white,
            borderRadius: BorderRadius.circular(25),
            border: isActive ? null : Border.all(color: AppColors.grey300),
          ),
          child: Center(
            child: Text(
              '$label($count)',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isActive ? AppColors.white : AppColors.grey600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBillItem(dynamic bill) {
    final customer = bill['customer'] as Map<String, dynamic>?;
    final String name = customer?['name']?.toString() ?? 'Unknown';
    final String billNum =
        'BIL-${(bill['year'] ?? 2026)}-${(bill['measurement_number'] ?? '0000').toString().padLeft(4, '0')}';
    final int price = ((bill['price'] ?? 0) as num).toInt();
    final int month = ((bill['month'] ?? 1) as num).toInt();
    final int year = ((bill['year'] ?? 2026) as num).toInt();
    final int usage = ((bill['usage_value'] ?? 0) as num).toInt();
    final String status = _getStatus(bill);
    final Color stColor = _statusColor(status);
    final Color stBg = _statusBg(status);
    final int id = (bill['id'] as num).toInt();

    final payments = bill['payments'];
    final bool pending = payments != null &&
        payments is Map &&
        payments['verified'] == false;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 6),
      child: GestureDetector(
        onTap: pending
            ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        PaymentVerificationScreen(bill: bill),
                  ),
                ).then((_) => _loadBills());
              }
            : null,
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
              // AVATAR
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFE3F2FD),
                ),
                child: Center(
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : '?',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.mainColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              // CONTENT
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.dark1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      billNum,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.mainColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          formatRupiah(price),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.dark1,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${_monthShort(month)} $year ${usage}m',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.grey500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // STATUS & ACTIONS
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: stBg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: stColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Edit tagihan')),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE3F2FD),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.edit_note,
                            size: 20,
                            color: AppColors.mainColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => _deleteBill(id),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFEBEE),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.delete_outline,
                            size: 20,
                            color: AppColors.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _monthShort(int m) {
    const names = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des'
    ];
    return names[m];
  }
}