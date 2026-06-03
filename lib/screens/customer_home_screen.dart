import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../constants/colors.dart';
import '../utils/helpers.dart';
import '../providers/app_provider.dart';
import '../services/bill_api.dart';
import '../services/api_service.dart';
import '../widgets/shimmer_card.dart';
import 'bill_list_screen.dart';
import 'payment_screen.dart';
import 'customer_bill_detail_screen.dart';
class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen>
    with SingleTickerProviderStateMixin {
  final BillApi _billApi = BillApi();
  final ApiService _api = ApiService();

  List<dynamic> myBills = [];
  dynamic profileData;
  bool isLoading = true;
  String? errorMessage;

  late AnimationController _animController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    _loadData();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    try {
      final bills = await _billApi.getMyBills(quantity: 100);
      final response = await _api.get('/customers/me');

      if (mounted) {
        setState(() {
          myBills = bills;
          profileData = response?['data'];
          isLoading = false;
        });
        _animController.forward(from: 0);
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

  // --- Logic perhitungan status tagihan ---
  List<dynamic> get _unpaidBills {
    return myBills.where((b) => b['paid'] != true).toList();
  }

  List<dynamic> get _overdueBills {
    final now = DateTime.now();
    return _unpaidBills.where((b) {
      final year = ((b['year'] ?? now.year) as num).toInt();
      final month = ((b['month'] ?? now.month) as num).toInt();
      return now.year > year || (now.year == year && now.month > month);
    }).toList();
  }

  List<dynamic> get _dueSoonBills {
    final now = DateTime.now();
    return _unpaidBills.where((b) {
      final year = ((b['year'] ?? now.year) as num).toInt();
      final month = ((b['month'] ?? now.month) as num).toInt();
      return (now.year == year && now.month == month) ||
          (now.year == year && now.month + 1 == month);
    }).toList();
  }

  List<dynamic> get _paidBills {
    return myBills.where((b) => b['paid'] == true).toList();
  }

  int get _totalUnpaidAmount {
    return _unpaidBills.fold<int>(
        0, (sum, b) => sum + ((b['price'] ?? 0) as num).toInt());
  }

  // --- Data untuk grafik 6 bulan terakhir ---
  List<_ChartData> get _chartData {
    final now = DateTime.now();
    final List<_ChartData> data = [];
    for (int i = 5; i >= 0; i--) {
      final d = DateTime(now.year, now.month - i, 1);
      final month = d.month;
      final year = d.year;
      final monthBills = myBills.where((b) {
        return ((b['month'] ?? 0) as num).toInt() == month &&
            ((b['year'] ?? 0) as num).toInt() == year;
      }).toList();

      int lunas = 0;
      int denda = 0;
      int belum = 0;

      for (final b in monthBills) {
        final price = ((b['price'] ?? 0) as num).toInt();
        final isPaid = b['paid'] == true;
        final isOverdue = !isPaid &&
            (now.year > year || (now.year == year && now.month > month));

        if (isPaid) {
          lunas += price;
        } else if (isOverdue) {
          denda += price;
        } else {
          belum += price;
        }
      }

      data.add(_ChartData(
        month: month,
        year: year,
        label: _monthShort(month),
        lunas: lunas,
        denda: denda,
        belum: belum,
      ));
    }
    return data;
  }
  
  get b => null;

  String _monthShort(int m) {
    const names = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
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

  String _monthLong(int m) {
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
    final unpaidCount = _unpaidBills.length;
    final overdueCount = _overdueBills.length;
    final dueSoonCount = _dueSoonBills.length;
    final paidCount = _paidBills.length;
    final chartData = _chartData;

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: RefreshIndicator(
        onRefresh: _loadData,
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
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
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
                                  ),
                                  child: const Icon(
                                    Icons.person,
                                    color: AppColors.white,
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Dashboard Saya',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: AppColors.white70,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      profileData?['name']?.toString() ??
                                          user?.name ??
                                          'Customer',
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
                        // --- CARD RINGKASAN TAGIHAN ---
                        if (isLoading)
                          const ShimmerCard(
                              height: 120, margin: EdgeInsets.zero)
                        else if (unpaidCount > 0)
                          _buildWarningCard(
                            unpaidCount: unpaidCount,
                            totalAmount: _totalUnpaidAmount,
                            dueSoon: dueSoonCount,
                            overdue: overdueCount,
                          )
                        else
                          _buildPaidOffCard(),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // --- BODY CONTENT ---
            SliverToBoxAdapter(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),

                      // --- GRAFIK TAGIHAN ---
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Grafik Tagihan',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A237E),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      CustomerBillDetailScreen(bill: b),
                                ),
                              ).then((_) => _loadData());
                            },
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
                      const SizedBox(height: 4),
                      Text(
                        'Riwayat Tagihan 6 Bulan',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.grey600,
                        ),
                      ),
                      const SizedBox(height: 12),

                      if (isLoading)
                        const ShimmerCard(height: 200)
                      else
                        _buildChartCard(chartData),

                      const SizedBox(height: 20),

                      // --- STATISTIK RINGKASAN ---
                      Row(
                        children: [
                          Expanded(
                            child: _statSummaryCard(
                              value: '$paidCount',
                              label: 'Lunas',
                              color: AppColors.mainColor,
                              bgColor: const Color(0xFFE3F2FD),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _statSummaryCard(
                              value: '${_overdueBills.length}',
                              label: 'Terlambat',
                              color: AppColors.error,
                              bgColor: const Color(0xFFFFEBEE),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _statSummaryCard(
                              value: '${_unpaidBills.length}',
                              label: 'Belum Bayar',
                              color: const Color(0xFFFF9800),
                              bgColor: const Color(0xFFFFF3E0),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // --- TAGIHAN TERBARU ---
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Tagihan Terbaru',
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
                                builder: (_) => const BillListScreen(),
                              ),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  'Detail',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.mainColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.arrow_forward_ios,
                                  size: 14,
                                  color: AppColors.mainColor,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      if (isLoading)
                        const Column(
                          children: [
                            ShimmerCard(height: 100),
                            SizedBox(height: 10),
                            ShimmerCard(height: 100),
                          ],
                        )
                      else if (myBills.isEmpty)
                        _buildEmptyBills()
                      else
                        ...myBills.take(3).map((b) => _buildBillItem(b)),

                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET: CARD WARNING ---
  Widget _buildWarningCard({
    required int unpaidCount,
    required int totalAmount,
    required int dueSoon,
    required int overdue,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE53935),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0x40E53935),
            blurRadius: 12,
            offset: const Offset(0, 6),
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
                decoration: const BoxDecoration(
                  color: Color(0x33FFFFFF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  color: AppColors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$unpaidCount Tagihan',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.white,
                      ),
                    ),
                    Text(
                      'Belum di bayar Total ${formatRupiah(totalAmount)}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xCCFFFFFF),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: Color(0x33FFFFFF), height: 1),
          const SizedBox(height: 12),
          Row(
            children: [
              if (dueSoon > 0)
                Expanded(
                  child: Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        color: Color(0xFFFFF59D),
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '$dueSoon akan jatuh tempo',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFFFFF59D),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              if (overdue > 0)
                Expanded(
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Color(0xFFFFCDD2),
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '$overdue Terlambat',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFFFFCDD2),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaidOffCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.success,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Color(0x33FFFFFF),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle,
              color: AppColors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Semua Tagihan Lunas',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                  ),
                ),
                Text(
                  'Terima kasih telah membayar tepat waktu',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xCCFFFFFF),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET: BAR CHART ---
  Widget _buildChartCard(List<_ChartData> data) {
    final maxY = data.fold<int>(0, (max, d) {
      final total = d.lunas + d.denda + d.belum;
      return total > max ? total : max;
    });
    final interval = maxY > 0 ? (maxY / 5).ceilToDouble() : 10000.0;

    return Container(
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
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _chartLegend('Lunas', AppColors.mainColor),
              const SizedBox(width: 16),
              _chartLegend('Denda', AppColors.error),
              const SizedBox(width: 16),
              _chartLegend('Belum', AppColors.grey400),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 180,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxY > 0 ? maxY * 1.2 : 100000,
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < data.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              data[index].label,
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.grey600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }
                        return const SizedBox();
                      },
                      reservedSize: 30,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      interval: interval > 0 ? interval : 10000,
                      getTitlesWidget: (value, meta) {
                        if (value == 0) return const SizedBox();
                        return Text(
                          '${(value / 1000).toStringAsFixed(0)}rb',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.grey500,
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: interval > 0 ? interval : 10000.0,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: const Color(0xFFE0E0E0),
                      strokeWidth: 1,
                    );
                  },
                ),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(data.length, (index) {
                  final d = data[index];
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: (d.lunas + d.denda + d.belum).toDouble(),
                        width: 22,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(6),
                          topRight: Radius.circular(6),
                        ),
                        rodStackItems: [
                          BarChartRodStackItem(
                            0,
                            d.lunas.toDouble(),
                            AppColors.mainColor,
                          ),
                          BarChartRodStackItem(
                            d.lunas.toDouble(),
                            (d.lunas + d.denda).toDouble(),
                            AppColors.error,
                          ),
                          BarChartRodStackItem(
                            (d.lunas + d.denda).toDouble(),
                            (d.lunas + d.denda + d.belum).toDouble(),
                            AppColors.grey400,
                          ),
                        ],
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chartLegend(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.grey600,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // --- WIDGET: STAT SUMMARY ---
  Widget _statSummaryCard({
    required String value,
    required String label,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color.withOpacity(0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET: TAGIHAN ITEM ---
  Widget _buildBillItem(dynamic bill) {
    final month = ((bill['month'] ?? 1) as num).toInt();
    final year = ((bill['year'] ?? 2026) as num).toInt();
    final price = ((bill['price'] ?? 0) as num).toInt();
    final isPaid = bill['paid'] == true;
    final now = DateTime.now();
    final isOverdue =
        !isPaid && (now.year > year || (now.year == year && now.month > month));
    final measurement = bill['measurement_number']?.toString() ?? '-';

    Color statusColor;
    Color statusBg;
    String statusText;
    IconData statusIcon;

    if (isPaid) {
      statusColor = AppColors.success;
      statusBg = const Color(0xFFE8F5E9);
      statusText = 'Lunas';
      statusIcon = Icons.check_circle;
    } else if (isOverdue) {
      statusColor = AppColors.error;
      statusBg = const Color(0xFFFFEBEE);
      statusText = 'Terlambat';
      statusIcon = Icons.warning;
    } else {
      statusColor = const Color(0xFFFF9800);
      statusBg = const Color(0xFFFFF3E0);
      statusText = 'Belum Lunas';
      statusIcon = Icons.access_time;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tagihan ${_monthLong(month)} $year',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A237E),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'BILL-$year-${month.toString().padLeft(2, '0')}-$measurement',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.grey500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(statusIcon, color: statusColor, size: 20),
              const SizedBox(width: 8),
              Text(
                formatRupiah(price),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: statusColor,
                ),
              ),
            ],
          ),
          if (!isPaid) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Jatuh Tempo 30 ${_monthLong(month)} $year',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.grey600,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PaymentScreen(bill: bill),
                      ),
                    ).then((_) => _loadData());
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.mainColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.payment,
                          color: AppColors.white,
                          size: 16,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Bayar',
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyBills() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.receipt_long_outlined,
                size: 56, color: AppColors.grey300),
            const SizedBox(height: 12),
            Text(
              'Belum ada tagihan',
              style: TextStyle(
                color: AppColors.grey500,
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Helper Class untuk Chart ---
class _ChartData {
  final int month;
  final int year;
  final String label;
  final int lunas;
  final int denda;
  final int belum;

  _ChartData({
    required this.month,
    required this.year,
    required this.label,
    required this.lunas,
    required this.denda,
    required this.belum,
  });
}
