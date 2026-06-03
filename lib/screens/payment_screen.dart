import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../constants/colors.dart';
import '../utils/helpers.dart';
import '../providers/app_provider.dart';
import '../services/payment_api.dart';
import '../widgets/bottom_nav.dart';
import 'main_screen.dart';

class PaymentScreen extends StatefulWidget {
  final dynamic bill;
  const PaymentScreen({super.key, required this.bill});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final PaymentApi _paymentApi = PaymentApi();
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _noteCtrl = TextEditingController();

  File? _selectedImage;
  String? _paymentMethod;
  DateTime _paymentDate = DateTime.now();
  bool _isLoading = false;

  final List<String> _paymentMethods = [
    'Transfer Bank BCA',
    'Transfer Bank BRI',
    'Transfer Bank Mandiri',
    'Transfer Bank BNI',
    'DANA',
    'OVO',
    'GoPay',
    'ShopeePay',
    'Lainnya',
  ];

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  // --- Logic Invoice ---
  int get _billPrice => ((widget.bill['price'] ?? 0) as num).toInt();
  int get _usage => ((widget.bill['usage_value'] ?? 0) as num).toInt();
  int get _year => ((widget.bill['year'] ?? 2026) as num).toInt();
  int get _month => ((widget.bill['month'] ?? 1) as num).toInt();

  String get _monthName {
    const names = [
      '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return names[_month];
  }

  String get _billNumber {
    final measurement = widget.bill['measurement_number']?.toString() ?? '0000';
    return 'BILL-$_year-${_month.toString().padLeft(2, '0')}-$measurement';
  }

  int get _penalty {
    // Denda 10% jika tagihan sudah lewat bulan berjalan
    final now = DateTime.now();
    final dueDate = DateTime(_year, _month + 1);
    if (now.isAfter(dueDate)) {
      return (_billPrice * 0.1).round();
    }
    return 0;
  }

  int get _total => _billPrice + _penalty;

  // --- Actions ---
  Future<void> _pickImage() async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );
      if (picked != null) {
        final file = File(picked.path);
        final size = await file.length();
        if (size > 5 * 1024 * 1024) {
          _showSnack('Ukuran file maksimal 5MB', isError: true);
          return;
        }
        setState(() => _selectedImage = file);
      }
    } catch (e) {
      _showSnack('Gagal memilih foto: $e', isError: true);
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _paymentDate,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.mainColor,
              onPrimary: AppColors.white,
              surface: AppColors.white,
              onSurface: AppColors.dark1,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _paymentDate = picked);
  }

  Future<void> _submitPayment() async {
    if (_paymentMethod == null) {
      _showSnack('Pilih metode pembayaran terlebih dahulu', isError: true);
      return;
    }
    if (_selectedImage == null) {
      _showSnack('Unggah foto bukti pembayaran terlebih dahulu', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final billId = (widget.bill['id'] as num).toInt();
      final response = await _paymentApi.createPayment(billId, _selectedImage!);

      if (mounted) {
        setState(() => _isLoading = false);
        if (response != null) {
          _showSnack('Pembayaran berhasil dikirim! Menunggu verifikasi admin.');
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) Navigator.of(context).pop(true);
          });
        } else {
          _showSnack('Gagal mengirim pembayaran', isError: true);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
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
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      bottomNavigationBar: BottomNav(
        currentIndex: 1,
        isAdmin: false,
        onTap: (index) {
          if (index == 1) return;
          // Kembali ke MainScreen agar BottomNav tetap sinkron
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const MainScreen()),
            (route) => false,
          );
        },
      ),
      body: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // --- HEADER GRADIENT + INVOICE ---
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
                      // AppBar manual
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
                            'Bayar Tagihan',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // --- INVOICE CARD ---
                      _buildInvoiceCard(),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // --- FORM PEMBAYARAN ---
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Metode Pembayaran
                  _sectionTitle('Metode Pembayaran'),
                  const SizedBox(height: 8),
                  _buildDropdown(),
                  const SizedBox(height: 20),

                  // Tanggal Bayar
                  _sectionTitle('Tanggal Bayar'),
                  const SizedBox(height: 8),
                  _buildDatePicker(),
                  const SizedBox(height: 20),

                  // Upload Foto
                  _sectionTitle('Bukti Pembayaran'),
                  const SizedBox(height: 8),
                  _buildUploadArea(),
                  const SizedBox(height: 20),

                  // Catatan
                  _sectionTitle('Catatan (Opsional)'),
                  const SizedBox(height: 8),
                  _buildNoteField(),
                  const SizedBox(height: 32),

                  // Tombol Bayar
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.mainColor,
                        foregroundColor: AppColors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: _isLoading ? null : _submitPayment,
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: AppColors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : const Text(
                              'Bayar',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Tombol Batal
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: _isLoading ? null : () => Navigator.pop(context),
                      child: const Text(
                        'Batal',
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

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppColors.dark1,
      ),
    );
  }

  // --- INVOICE WIDGET ---
  Widget _buildInvoiceCard() {
    return Container(
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
          // Header Invoice
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'RINGKASAN TAGIHAN',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppColors.dark2,
                  letterSpacing: 1.2,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE3F2FD),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'INVOICE',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.mainColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Data Rows
          _invoiceRow('No. Tagihan', _billNumber, isBold: true),
          _invoiceRow('Periode', '$_monthName $_year'),
          _invoiceRow('Pemakaian', '$_usage Meter³'),
          if (_penalty > 0) ...[
            const SizedBox(height: 2),
            _invoiceRow(
              'Denda (10%)',
              formatRupiah(_penalty),
              valueColor: AppColors.error,
              labelColor: AppColors.error,
            ),
          ],
          // Dotted Divider
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: DottedDivider(),
          ),
          // Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Bayar',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.dark1,
                ),
              ),
              Text(
                formatRupiah(_total),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.mainColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _invoiceRow(
    String label,
    String value, {
    bool isBold = false,
    Color? valueColor,
    Color? labelColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: labelColor ?? AppColors.grey600,
              fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: valueColor ?? AppColors.dark1,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // --- DROPDOWN METODE ---
  Widget _buildDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.subtle),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: _paymentMethod,
          hint: const Row(
            children: [
              Icon(Icons.account_balance_wallet_outlined,
                  color: AppColors.dark3, size: 20),
              SizedBox(width: 12),
              Text(
                'Pilih Bank/aplikasi payment',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.grey500,
                ),
              ),
            ],
          ),
          icon: const Icon(Icons.check_circle,
              color: AppColors.mainColor, size: 22),
          items: _paymentMethods.map((method) {
            return DropdownMenuItem<String>(
              value: method,
              child: Text(
                method,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.dark1,
                ),
              ),
            );
          }).toList(),
          onChanged: (v) => setState(() => _paymentMethod = v),
        ),
      ),
    );
  }

  // --- DATE PICKER ---
  Widget _buildDatePicker() {
    return GestureDetector(
      onTap: _selectDate,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.subtle),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_outlined,
                color: AppColors.dark3, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                DateFormat('dd MMMM yyyy', 'id_ID').format(_paymentDate),
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.dark1,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(Icons.check_circle,
                color: AppColors.mainColor, size: 22),
          ],
        ),
      ),
    );
  }

  // --- UPLOAD AREA ---
  Widget _buildUploadArea() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _selectedImage != null
                ? AppColors.mainColor
                : AppColors.subtle,
            width: _selectedImage != null ? 2 : 1,
          ),
        ),
        child: _selectedImage != null
            ? Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      _selectedImage!,
                      height: 160,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check_circle,
                          color: AppColors.success, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        'Foto berhasil diunggah',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.success,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tap untuk ganti foto',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.grey500,
                    ),
                  ),
                ],
              )
            : Column(
                children: [
                  const Icon(
                    Icons.upload_file,
                    size: 40,
                    color: AppColors.mainColor,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Tap untuk Unggah foto',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.mainColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'JPG, PNG maks 5MB',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.grey500,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  // --- NOTE FIELD ---
  Widget _buildNoteField() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _noteCtrl,
        maxLines: 3,
        decoration: InputDecoration(
          hintText: 'Tambahkan Catatan jika diperlukan...',
          hintStyle: TextStyle(
            fontSize: 14,
            color: AppColors.grey500,
          ),
          contentPadding: const EdgeInsets.all(16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: AppColors.white,
        ),
      ),
    );
  }
}

// --- DOTTED DIVIDER WIDGET ---
class DottedDivider extends StatelessWidget {
  const DottedDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        const dashWidth = 6.0;
        const dashSpace = 4.0;
        final dashCount = (width / (dashWidth + dashSpace)).floor();
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(dashCount, (_) {
            return Container(
              width: dashWidth,
              height: 1.2,
              color: AppColors.grey300,
            );
          }),
        );
      },
    );
  }
}