import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../constants/api.dart';
import '../utils/helpers.dart';
import '../services/payment_api.dart';
import '../services/api_service.dart';

class PaymentVerificationScreen extends StatefulWidget {
  final dynamic bill;
  const PaymentVerificationScreen({super.key, required this.bill});

  @override
  State<PaymentVerificationScreen> createState() =>
      _PaymentVerificationScreenState();
}

class _PaymentVerificationScreenState extends State<PaymentVerificationScreen> {
  final PaymentApi _paymentApi = PaymentApi();
  final ApiService _api = ApiService();
  bool _isProcessing = false;

  String get _billNumber {
    final y = ((widget.bill['year'] ?? 2026) as num).toInt();
    final m = (widget.bill['measurement_number'] ?? '0000')
        .toString()
        .padLeft(4, '0');
    return 'BILL-$y-$m';
  }

  String get _customerName {
    final c = widget.bill['customer'] as Map<String, dynamic>?;
    return c?['name']?.toString() ?? 'Unknown';
  }

  int get _price => ((widget.bill['price'] ?? 0) as num).toInt();
  int get _usage => ((widget.bill['usage_value'] ?? 0) as num).toInt();
  int get _month => ((widget.bill['month'] ?? 1) as num).toInt();
  int get _year => ((widget.bill['year'] ?? 2026) as num).toInt();

  String get _monthName {
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
    return names[_month];
  }

  dynamic get _payment {
    final p = widget.bill['payments'];
    if (p != null && p is Map) return p;
    return null;
  }

  String? get _proofFilename {
    final p = _payment;
    if (p == null) return null;
    return p['payment_proof']?.toString();
  }

  String get _paymentDate {
    final p = _payment;
    if (p == null) return '-';
    final d = p['payment_date']?.toString();
    if (d == null || d.isEmpty) return '-';
    try {
      final dt = DateTime.parse(d);
      return '${dt.day} ${_monthShort(dt.month)} ${dt.year} ${_fmtTime(dt)}';
    } catch (e) {
      return d;
    }
  }

  String _monthShort(int m) {
    const n = [
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
    return n[m];
  }

  String _fmtTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    return '$h:$min';
  }

  Future<void> _verify(bool approve) async {
    final pid = _payment?['id'];
    if (pid == null) {
      _showSnack('Data pembayaran tidak valid', isError: true);
      return;
    }
    setState(() => _isProcessing = true);
    try {
      if (approve) {
        await _paymentApi.verifyPayment((pid as num).toInt());
        _showSnack('Pembayaran berhasil diverifikasi!');
      } else {
        await _paymentApi.rejectPayment((pid as num).toInt());
        _showSnack('Pembayaran ditolak.');
      }
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) Navigator.pop(context, true);
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        _showSnack('Error: $e', isError: true);
      }
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final proofUrl = _proofFilename != null
        ? '${ApiConfig.baseUrl}/payment-proof/$_proofFilename'
        : null;

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: CustomScrollView(
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
                                color: AppColors.white,
                                size: 20,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Text(
                            'Verifikasi Pembayaran',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Pembayaran dari pelanggan sedang menunggu proses verifikasi. Silakan periksa bukti pembayaran untuk memastikan transaksi valid sebelum dikonfirmasi sebagai berhasil.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xCCFFFFFF),
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // CONTENT
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
              child: Column(
                children: [
                  // BUKTI TRANSFER
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.subtle),
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
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE3F2FD),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.image_outlined,
                            size: 32,
                            color: AppColors.mainColor,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Bukti Transfer',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.dark1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'BCA $_paymentDate',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.grey600,
                          ),
                        ),
                        if (proofUrl != null) ...[
                          const SizedBox(height: 16),
                          GestureDetector(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (_) => Dialog(
                                  backgroundColor: Colors.transparent,
                                  child: InteractiveViewer(
                                    child: Image.network(
                                      proofUrl,
                                      headers: {
                                        'app-key': ApiConfig.appKey,
                                        if (_api.token != null)
                                          'Authorization':
                                              'Bearer ${_api.token}',
                                      },
                                      loadingBuilder:
                                          (c, child, progress) {
                                        if (progress == null) {
                                          return child;
                                        }
                                        return const Center(
                                          child:
                                              CircularProgressIndicator(),
                                        );
                                      },
                                      errorBuilder: (c, e, s) =>
                                          const Center(
                                        child: Text(
                                          'Gagal memuat gambar',
                                          style: TextStyle(
                                              color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE3F2FD),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.visibility,
                                    size: 16,
                                    color: AppColors.mainColor,
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    'Lihat Bukti',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.mainColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // DETAIL TAGIHAN
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.subtle),
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
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE3F2FD),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.receipt_outlined,
                                color: AppColors.mainColor,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _billNumber,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.dark1,
                                    ),
                                  ),
                                  Text(
                                    '$_customerName  •  $_monthName $_year',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.grey600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        _detailRow('Pemakaian', '$_usage M'),
                        _detailRow('Total Tagihan', formatRupiah(_price)),
                        _detailRow('Metode Bayar', 'Transfer Bank BCA'),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Status',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.grey600,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE3F2FD),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                'Menunggu Verifikasi',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.mainColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // TOMBOL TOLAK & SETUJU
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 52,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.error,
                              side: const BorderSide(
                                  color: AppColors.error, width: 1.5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: _isProcessing
                                ? null
                                : () => _verify(false),
                            child: _isProcessing
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.error,
                                    ),
                                  )
                                : const Text(
                                    'Tolak',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: SizedBox(
                          height: 52,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.mainColor,
                              side: const BorderSide(
                                  color: AppColors.mainColor, width: 1.5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: _isProcessing
                                ? null
                                : () => _verify(true),
                            child: _isProcessing
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.mainColor,
                                    ),
                                  )
                                : const Text(
                                    'Setuju',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
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