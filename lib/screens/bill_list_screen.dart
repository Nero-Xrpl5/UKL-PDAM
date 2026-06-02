import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../services/bill_api.dart';
import '../services/customer_api.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_card.dart';
import '../widgets/status_badge.dart';

class BillListScreen extends StatefulWidget {
  const BillListScreen({Key? key}) : super(key: key);

  @override
  State<BillListScreen> createState() => _BillListScreenState();
}

class _BillListScreenState extends State<BillListScreen> {
  final BillApi _billApi = BillApi();
  final CustomerApi _customerApi = CustomerApi();
  List<dynamic> bills = [];
  List<dynamic> customers = [];
  bool isLoading = true;
  String filter = 'Semua';

  final _usageCtrl = TextEditingController();
  final _meterCtrl = TextEditingController();
  int? selectedCustomerId;
  int selectedMonth = DateTime.now().month;
  int selectedYear = DateTime.now().year;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);
    try {
      final b = await _billApi.getBills();
      final c = await _customerApi.getCustomers();
      setState(() {
        bills = b;
        customers = c;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  Future<void> _createBill() async {
    if (selectedCustomerId == null || _usageCtrl.text.isEmpty) return;
    try {
      await _billApi.createBill({
        'customer_id': selectedCustomerId,
        'month': selectedMonth,
        'year': selectedYear,
        'measurement_number': _meterCtrl.text,
        'usage_value': int.parse(_usageCtrl.text),
      });
      _usageCtrl.clear(); _meterCtrl.clear();
      _loadData();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
      );
    }
  }

  Future<void> _deleteBill(int id) async {
    try {
      await _billApi.deleteBill(id);
      _loadData();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = filter == 'Semua' ? bills : bills.where((b) {
      if (filter == 'Lunas') return b['paid'] == true;
      if (filter == 'Belum') return b['paid'] == false;
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(title: const Text('Kelola Tagihan'), backgroundColor: AppColors.mainColor),
      body: Column(
        children: [
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
                  items: customers.map((c) => DropdownMenuItem(
                    value: c['id'],
                    child: Text(c['name'] ?? '-'),
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
                CustomButton(text: 'Buat Tagihan', height: 44, onPressed: _createBill),
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
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final b = filtered[index];
                      final customer = b['customer'];
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
                                    Text(customer?['name'] ?? '-', style: const TextStyle(fontWeight: FontWeight.bold)),
                                    Text('Bulan: ${b['month']}/${b['year']}'),
                                    Text('Pemakaian: ${b['usage_value']} m³'),
                                    Text('Rp ${b['price']}', style: const TextStyle(color: AppColors.mainColor, fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              ),
                              StatusBadge(status: b['paid'] == true ? 'Lunas' : 'Belum Bayar'),
                              IconButton(
                                icon: const Icon(Icons.delete, color: AppColors.error),
                                onPressed: () => _deleteBill(b['id']),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}