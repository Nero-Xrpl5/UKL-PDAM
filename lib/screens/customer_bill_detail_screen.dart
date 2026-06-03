import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../utils/helpers.dart';
import 'payment_screen.dart';

class CustomerBillDetailScreen extends StatelessWidget {
  final dynamic bill;
  const CustomerBillDetailScreen({super.key, required this.bill});

  String get _monthName {
    final m = ((bill['month'] ?? 1) as num).toInt();
    const names = [
      '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return names[m];
  }

  @override
  Widget build(BuildContext context) {
    final month = ((bill['month'] ?? 1) as num).toInt();
    final year = ((bill['year'] ?? 2026) as num).toInt();
    final price = ((bill['price'] ?? 0) as num).toInt();
    final usage = ((bill['usage_value'] ?? 0) as num).toInt();
    final isPaid = bill['paid'] == true;
    final measurement = bill['measurement_number']?.toString() ?? '-';
    final service = bill['service'] as Map<String, dynamic>?;
    final admin = bill['admin'] as Map<String, dynamic>?;
    final payments = bill['payments'] as Map<String, dynamic>?;

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // Header
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
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: Color(0x26FFFFFF),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.arrow_back_ios_new,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Text(
                            'Detail Tagihan',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          children: [
                            Text(
                              '$_monthName $year',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.grey600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              formatRupiah(price),
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: AppColors.mainColor,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 6),
                              decoration: BoxDecoration(
                                color: isPaid
                                    ? const Color(0xFFE8F5E9)
                                    : const Color(0xFFFFEBEE),
                                borderRadius: BorderRadius.circular(20),
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
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Detail Info
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _detailCard([
                    _detailRow('No. Tagihan', 'BILL-$year-${month.toString().padLeft(2, '0')}-$measurement'),
                    _detailRow('Periode', '$_monthName $year'),
                    _detailRow('Pemakaian', '$usage m³'),
                    if (service != null)
                      _detailRow('Golongan', service['name']?.toString() ?? '-'),
                    if (admin != null)
                      _detailRow('Petugas', admin['name']?.toString() ?? '-'),
                  ]),
                  const SizedBox(height: 20),

                  if (payments != null) ...[
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Riwayat Pembayaran',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.dark1,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _detailCard([
                      _detailRow('Tanggal', payments['payment_date']?.toString() ?? '-'),
                      _detailRow('Status Verifikasi',
                          (payments['verified'] == true) ? 'Terverifikasi' : 'Menunggu'),
                      _detailRow('Total Bayar', formatRupiah(price)),
                    ]),
                  ],

                  const SizedBox(height: 32),

                  if (!isPaid)
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.mainColor,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PaymentScreen(bill: bill),
                            ),
                          );
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
          ),
        ],
      ),
    );
  }

  Widget _detailCard(List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
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
        children: children,
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
            style: const TextStyle(
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