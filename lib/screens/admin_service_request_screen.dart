import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants/colors.dart';
import '../models/service_request.dart';
import '../services/service_request_service.dart';
import '../widgets/shimmer_card.dart';

class AdminServiceRequestScreen extends StatefulWidget {
  const AdminServiceRequestScreen({super.key});

  @override
  State<AdminServiceRequestScreen> createState() =>
      _AdminServiceRequestScreenState();
}

class _AdminServiceRequestScreenState
    extends State<AdminServiceRequestScreen> {
  final ServiceRequestService _service = ServiceRequestService();
  List<ServiceRequest> requests = [];
  List<ServiceRequest> filtered = [];
  bool isLoading = true;
  String? errorMessage;
  String _filter = 'Semua';
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchCtrl.addListener(_onSearch);
  }

  @override
  void dispose() {
    _searchCtrl.removeListener(_onSearch);
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    try {
      final data = await _service.getAll();
      setState(() {
        requests = data;
        _applyFilter();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  void _onSearch() => _applyFilter();

  void _applyFilter() {
    List<ServiceRequest> result = requests;
    if (_filter == 'Baru') {
      result = result.where((r) => r.status == 'Baru').toList();
    } else if (_filter == 'Proses') {
      result = result.where((r) => r.status == 'Diproses').toList();
    }
    final query = _searchCtrl.text.toLowerCase();
    if (query.isNotEmpty) {
      result = result.where((r) {
        return r.customerName.toLowerCase().contains(query) ||
            r.customerNumber.toLowerCase().contains(query) ||
            r.serviceName.toLowerCase().contains(query);
      }).toList();
    }
    setState(() => filtered = result);
  }

  Future<void> _updateStatus(ServiceRequest req, String newStatus) async {
    try {
      await _service.updateStatus(req.id, newStatus);
      _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Status diubah menjadi $newStatus'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Color _statusColor(String s) {
    if (s == 'Baru') return const Color(0xFFFF9800);
    if (s == 'Diproses') return const Color(0xFF9C27B0);
    return AppColors.success;
  }

  Color _statusBg(String s) {
    if (s == 'Baru') return const Color(0xFFFFF3E0);
    if (s == 'Diproses') return const Color(0xFFF3E5F5);
    return const Color(0xFFE8F5E9);
  }

  IconData _serviceIcon(String type) {
    switch (type) {
      case 'installation':
        return Icons.water_drop_outlined;
      case 'repair':
        return Icons.plumbing_outlined;
      case 'disconnection':
        return Icons.power_off_outlined;
      default:
        return Icons.build_circle_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final baruCount = requests.where((r) => r.status == 'Baru').length;
    final prosesCount = requests.where((r) => r.status == 'Diproses').length;

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: RefreshIndicator(
        onRefresh: _loadData,
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
                        const Row(
                          children: [
                            Icon(Icons.build_circle,
                                color: AppColors.white, size: 28),
                            SizedBox(width: 12),
                            Text(
                              'Pengajuan Layanan',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: AppColors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 16),
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
                                    hintText: 'Cari Layanan....',
                                    hintStyle: TextStyle(
                                        color: AppColors.grey500),
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
                    _filterChip(
                        'Semua', requests.length, _filter == 'Semua'),
                    const SizedBox(width: 10),
                    _filterChip('Baru', baruCount, _filter == 'Baru'),
                    const SizedBox(width: 10),
                    _filterChip(
                        'Proses', prosesCount, _filter == 'Proses'),
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
                      child: ShimmerCard(height: 140),
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
                              onPressed: _loadData,
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
                            Icon(Icons.inbox_outlined,
                                size: 64, color: AppColors.grey300),
                            const SizedBox(height: 12),
                            Text(
                              'Tidak ada pengajuan',
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
                  return _buildRequestItem(filtered[index]);
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
          _applyFilter();
        },
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

  Widget _buildRequestItem(ServiceRequest req) {
    final Color stColor = _statusColor(req.status);
    final Color stBg = _statusBg(req.status);

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFE3F2FD),
                    image: DecorationImage(
                      image: AssetImage('assets/images/avatar_default.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        req.customerName,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.dark1,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        req.customerNumber,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.mainColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: stBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    req.status,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: stColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE3F2FD),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _serviceIcon(req.serviceType),
                    size: 20,
                    color: AppColors.mainColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    req.serviceName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.dark1,
                    ),
                  ),
                ),
                Text(
                  'Rp ${NumberFormat('#,###', 'id_ID').format(req.price)}',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('d MMMM HH:mm', 'id_ID')
                      .format(req.createdAt),
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.grey500,
                  ),
                ),
                if (req.status == 'Baru')
                  GestureDetector(
                    onTap: () => _updateStatus(req, 'Diproses'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.mainColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'Proses',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.white,
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
}