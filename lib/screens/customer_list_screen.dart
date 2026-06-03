import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../models/customer.dart';
import '../services/customer_api.dart';
import 'customer_form_screen.dart';

class CustomerListScreen extends StatefulWidget {
  const CustomerListScreen({super.key});

  @override
  State<CustomerListScreen> createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends State<CustomerListScreen> {
  List<Customer> _allCustomers = [];
  List<Customer> _filtered = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _filterStatus = 'semua'; // 'semua' | 'aktif' | 'nonaktif'

  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final data = await CustomerApi.getCustomers();
      setState(() {
        _allCustomers = data;
        _applyFilter();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnack(e.toString(), isError: true);
    }
  }

  void _applyFilter() {
    List<Customer> result = _allCustomers;

    if (_filterStatus == 'aktif') {
      result = result.where((c) => c.isAktif).toList();
    } else if (_filterStatus == 'nonaktif') {
      result = result.where((c) => !c.isAktif).toList();
    }

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result
          .where((c) =>
              c.nama.toLowerCase().contains(q) ||
              c.noPelanggan.toLowerCase().contains(q))
          .toList();
    }

    setState(() => _filtered = result);
  }

  int get _countSemua => _allCustomers.length;
  int get _countAktif => _allCustomers.where((c) => c.isAktif).length;
  int get _countNonAktif => _allCustomers.where((c) => !c.isAktif).length;

  Future<void> _delete(Customer c) async {
    if (c.id == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Hapus Customer',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        content: Text(
            'Yakin ingin menghapus "${c.nama}"?\nTindakan ini tidak dapat dibatalkan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;
    try {
      await CustomerApi.deleteCustomer(c.id!);
      await _loadData();
      _showSnack('Customer "${c.nama}" berhasil dihapus');
    } catch (e) {
      _showSnack(e.toString(), isError: true);
    }
  }

  void _toAdd() async {
    final ok = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const CustomerFormScreen()),
    );
    if (ok == true) {
      await _loadData();
      _showSnack('Customer baru berhasil ditambahkan');
    }
  }

  void _toEdit(Customer c) async {
    final ok = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
          builder: (_) => CustomerFormScreen(customer: c)),
    );
    if (ok == true) {
      await _loadData();
      _showSnack('Data customer berhasil diperbarui');
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(children: [
          Icon(
            isError ? Icons.error_outline : Icons.check_circle_outline,
            color: Colors.white,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(msg, style: const TextStyle(fontSize: 13))),
        ]),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.mainColor))
                : RefreshIndicator(
                    onRefresh: _loadData,
                    color: AppColors.mainColor,
                    child: _filtered.isEmpty
                        ? _buildEmpty()
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                            itemCount: _filtered.length,
                            itemBuilder: (_, i) => _buildCard(_filtered[i]),
                          ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _toAdd,
        backgroundColor: AppColors.mainColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: const Icon(Icons.person_add_outlined, color: Colors.white),
        label: const Text('Tambah Customer',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF2659BF), AppColors.mainColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new,
                          color: Colors.white, size: 18),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Data Customer',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: (v) {
                    setState(() => _searchQuery = v);
                    _applyFilter();
                  },
                  decoration: InputDecoration(
                    hintText: 'Cari nama / no. pelanggan..',
                    hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
                    prefixIcon:
                        Icon(Icons.search, color: Colors.grey[400], size: 20),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchCtrl.clear();
                              setState(() => _searchQuery = '');
                              _applyFilter();
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 13),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _filterTab('Semua($_countSemua)', 'semua'),
                  const SizedBox(width: 8),
                  _filterTab('Aktif($_countAktif)', 'aktif'),
                  const SizedBox(width: 8),
                  _filterTab('Non-Aktif($_countNonAktif)', 'nonaktif'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _filterTab(String label, String value) {
    final selected = _filterStatus == value;
    return GestureDetector(
      onTap: () {
        setState(() => _filterStatus = value);
        _applyFilter();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected
              ? Colors.white
              : Colors.white.withOpacity(0.18),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? AppColors.mainColor : Colors.white,
            fontWeight: selected ? FontWeight.bold : FontWeight.w500,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildCard(Customer c) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.mainColor, Color(0xFF2659BF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                c.nama.isNotEmpty ? c.nama[0].toUpperCase() : '?',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    c.nama,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: AppColors.dark1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    c.noPelanggan,
                    style: const TextStyle(
                      color: AppColors.mainColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${c.alamat}  •  ${c.golongan}',
                    style: TextStyle(
                      color: AppColors.grey600,
                      fontSize: 11,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: c.isAktif
                        ? const Color(0xFFE8F5E9)
                        : AppColors.grey100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    c.isAktif ? 'Aktif' : 'Non-Aktif',
                    style: TextStyle(
                      color: c.isAktif
                          ? AppColors.success
                          : AppColors.grey600,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _iconBtn(
                      icon: Icons.edit_outlined,
                      color: AppColors.mainColor,
                      bg: AppColors.grey100,
                      onTap: () => _toEdit(c),
                    ),
                    const SizedBox(width: 6),
                    _iconBtn(
                      icon: Icons.delete_outline,
                      color: AppColors.error,
                      bg: const Color(0xFFFFEBEE),
                      onTap: () => _delete(c),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _iconBtn({
    required IconData icon,
    required Color color,
    required Color bg,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(9),
        ),
        child: Icon(icon, color: color, size: 17),
      ),
    );
  }

  Widget _buildEmpty() {
    return ListView(
      children: [
        const SizedBox(height: 80),
        Column(
          children: [
            Icon(Icons.people_outline, size: 72, color: Colors.grey[300]),
            const SizedBox(height: 12),
            Text(
              'Tidak ada customer',
              style: TextStyle(
                  color: AppColors.grey600,
                  fontSize: 15,
                  fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              'Coba ubah filter atau tambah customer baru',
              style: TextStyle(color: AppColors.grey400, fontSize: 12),
            ),
          ],
        ),
      ],
    );
  }
}