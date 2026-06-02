import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/colors.dart';
import '../providers/app_provider.dart';
import '../services/bill_api.dart';
import '../services/customer_api.dart';
import '../services/payment_api.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_card.dart';
import '../widgets/status_badge.dart';

class BillListScreen extends StatefulWidget {
  const BillListScreen({super.key});

  @override
  State<BillListScreen> createState() => _BillListScreenState();
}

class _BillListScreenState extends State<BillListScreen> {
  final BillApi _billApi = BillApi();
  final CustomerApi _customerApi = CustomerApi();
  final PaymentApi _paymentApi = PaymentApi();

  List<dynamic> bills = [];
  List<dynamic> customers = [];
  List<dynamic> payments = [];
  bool isLoading = true;
  String filter = 'Semua';

  final _usageCtrl = TextEditingController();
  final _meterCtrl = TextEditingController();
  int? selectedCustomerId;
  int selectedMonth = DateTime.now().month;
  int selectedYear = DateTime.now().year;
  int? _editingBillId;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);
    try {
      final isAdmin = context.read<AppProvider>().isAdmin;
      List<dynamic> b;
      List<dynamic> p = [];

      if (isAdmin) {
        b = await _billApi.getBills();
        p = await _paymentApi.getPayments();
      } else {
        b = await _billApi.getMyBills();
      }

      final c = await _customerApi.getCustomers();
      if (mounted) {
        setState(() {
          bills = b;
          customers = c;
          payments = p;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  Future<void> _createOrUpdateBill() async {
    if (selectedCustomerId == null || _usageCtrl.text.isEmpty) return;
    final data = {
      'customer_id': selectedCustomerId,
      'month': selectedMonth,
      'year': selectedYear,
      'measurement_number': _meterCtrl.text,
      'usage_value': int.parse(_usageCtrl.text),
    };
    try {
      if (_editingBillId != null) {
        await _billApi.updateBill(_editingBillId!, data);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tagihan berhasil diupdate!'), backgroundColor: AppColors.success),
          );
        }
      } else {
        await _billApi.createBill(data);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tagihan berhasil dibuat!'), backgroundColor: AppColors.success),
          );
        }
      }
      _usageCtrl.clear(); _meterCtrl.clear();
      setState(() {
        _editingBillId = null;
        selectedCustomerId = null;
      });
      _loadData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  void _startEditBill(dynamic bill) {
    setState(() {
      _editingBillId = (bill['id'] as num).toInt();
      selectedCustomerId = (bill['customer_id'] as num).toInt();
      selectedMonth = (bill['month'] ?? DateTime.now().month) is int 
          ? bill['month'] 
          : int.tryParse(bill['month'].toString()) ?? DateTime.now().month;
      selectedYear = (bill['year'] ?? DateTime.now().year) is int 
          ? bill['year'] 
          : int.tryParse(bill['year'].toString()) ?? DateTime.now().year;
      _meterCtrl.text = bill['measurement_number']?.toString() ?? '';
      _usageCtrl.text = bill['usage_value']?.toString() ?? '';
    });
  }

  void _cancelEdit() {
    setState(() {
      _editingBillId = null;
      selectedCustomerId = null;
      selectedMonth = DateTime.now().month;
      selectedYear = DateTime.now().year;
    });
    _usageCtrl.clear(); _meterCtrl.clear();
  }

  Future<void> _deleteBill(int id) async {
    try {
      await _billApi.deleteBill(id);
      _loadData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  Future<void> _verifyPayment(int paymentId) async {
    try {
      await _paymentApi.verifyPayment(paymentId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pembayaran diverifikasi!'), backgroundColor: AppColors.success),
        );
      }
      _loadData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  Future<void> _rejectPayment(int paymentId) async {
    try {
      await _paymentApi.rejectPayment(paymentId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pembayaran ditolak!'), backgroundColor: AppColors.warning),
        );
      }
      _loadData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = context.watch<AppProvider>().isAdmin;

    final filtered = filter == 'Semua' ? bills : bills.where((b) {
      if (filter == 'Lunas') return b['paid'] == true;
      if (filter == 'Belum') return b['paid'] == false;
      return true;
    }).toList();

    final pendingPayments = payments.where((p) => p['verified'] == false).toList();

    if (isAdmin) {
      return DefaultTabController(
        length: 2,
        child: Scaffold(
          backgroundColor: AppColors.bgLight,
          appBar: AppBar(
            title: const Text('Kelola Tagihan'),
            backgroundColor: AppColors.mainColor,
            bottom: const TabBar(
              tabs: [
                Tab(text: 'Tagihan'),
                Tab(text: 'Verifikasi'),
              ],
              labelColor: AppColors.white,
              unselectedLabelColor: Colors.white70,
              indicatorColor: AppColors.white,
            ),
          ),
          body: TabBarView(
            children: [
              _buildBillTab(filtered, isAdmin),
              _buildVerificationTab(pendingPayments),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        title: const Text('Tagihan Saya'),
        backgroundColor: AppColors.mainColor,
      ),
      body: _buildBillTab(filtered, isAdmin),
    );
  }

  Widget _buildBillTab(List<dynamic> filtered, bool isAdmin) {
    return Column(
      children: [
        if (isAdmin)
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.mainColor,
            child: Column(
              children: [
                DropdownButtonFormField<int>(
                  value: selectedCustomerId,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                  hint: const Text('Pilih Pelanggan'),
                  items: customers.map<DropdownMenuItem<int>>((c) => DropdownMenuItem(
                    value: (c['id'] as num).toInt(),
                    child: Text(c['name']?.toString() ?? '-'),
                  )).toList(),
                  onChanged: (v) => setState(() => selectedCustomerId = v),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _meterCtrl,
                        decoration: InputDecoration(
                          hintText: 'No Meter',
                          filled: true,
                          fillColor: AppColors.white,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        controller: _usageCtrl,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: 'Pemakaian (m³)',
                          filled: true,
                          fillColor: AppColors.white,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        text: _editingBillId != null ? 'Update Tagihan' : 'Buat Tagihan',
                        height: 44,
                        onPressed: _createOrUpdateBill,
                      ),
                    ),
                    if (_editingBillId != null) ...[
                      const SizedBox(width: 8),
                      Expanded(
                        child: CustomButton(
                          text: 'Batal',
                          height: 44,
                          color: AppColors.dark3,
                          onPressed: _cancelEdit,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: ['Semua', 'Lunas', 'Belum'].map((f) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(f),
                selected: filter == f,
                onSelected: (_) => setState(() => filter = f),
                selectedColor: AppColors.mainColor,
                labelStyle: TextStyle(color: filter == f ? AppColors.white : AppColors.dark1),
              ),
            )).toList(),
          ),
        ),
        Expanded(
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : filtered.isEmpty
                  ? const Center(child: Text('Tidak ada tagihan'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final b = filtered[index];
                        final customer = b['customer'] as Map<String, dynamic>?;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: CustomCard(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(customer?['name']?.toString() ?? (isAdmin ? '-' : 'Tagihan'), style: const TextStyle(fontWeight: FontWeight.bold)),
                                      Text('Bulan: ${b['month']}/${b['year']}'),
                                      Text('Pemakaian: ${b['usage_value']} m³'),
                                      Text('Rp ${b['price']}', style: const TextStyle(color: AppColors.mainColor, fontWeight: FontWeight.w600)),
                                    ],
                                  ),
                                ),
                                StatusBadge(status: b['paid'] == true ? 'Lunas' : 'Belum Bayar'),
                                if (isAdmin) ...[
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: AppColors.mainColor),
                                    onPressed: () => _startEditBill(b),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: AppColors.error),
                                    onPressed: () => _deleteBill((b['id'] as num).toInt()),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildVerificationTab(List<dynamic> pendingPayments) {
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : pendingPayments.isEmpty
            ? const Center(child: Text('Tidak ada pembayaran pending'))
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: pendingPayments.length,
                itemBuilder: (context, index) {
                  final p = pendingPayments[index];
                  final bill = p['bill'] as Map<String, dynamic>?;
                  final customer = bill?['customer'] as Map<String, dynamic>?;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: CustomCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(customer?['name']?.toString() ?? 'Customer', style: const TextStyle(fontWeight: FontWeight.bold)),
                                    Text('Bill ID: ${p['bill_id']}', style: TextStyle(fontSize: 12, color: AppColors.dark3)),
                                    Text('Total: Rp ${p['total_amount'] ?? bill?['price'] ?? '-'}', style: const TextStyle(color: AppColors.mainColor, fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              ),
                              const StatusBadge(status: 'Menunggu Verifikasi'),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () => _verifyPayment((p['id'] as num).toInt()),
                                  icon: const Icon(Icons.check, size: 18),
                                  label: const Text('Verifikasi'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.success,
                                    foregroundColor: AppColors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () => _rejectPayment((p['id'] as num).toInt()),
                                  icon: const Icon(Icons.close, size: 18),
                                  label: const Text('Tolak'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.error,
                                    foregroundColor: AppColors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
  }
}