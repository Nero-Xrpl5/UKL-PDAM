import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/colors.dart';
import '../providers/app_provider.dart';
import '../models/complaint.dart';
import '../services/complaint_service.dart';
import '../services/service_api.dart';
import '../widgets/shimmer_card.dart';

class ComplaintScreen extends StatefulWidget {
  const ComplaintScreen({super.key});

  @override
  State<ComplaintScreen> createState() => _ComplaintScreenState();
}

class _ComplaintScreenState extends State<ComplaintScreen> {
  final ComplaintService _service = ComplaintService();
  final ServiceApi _serviceApi = ServiceApi();

  List<Complaint> complaints = [];
  List<dynamic> services = [];
  bool isLoading = true;
  bool isSearching = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadComplaints();
  }

  Future<void> _loadComplaints() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    try {
      final data = await _service.getAll();
      setState(() {
        complaints = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> _loadServices() async {
    setState(() => isSearching = true);
    try {
      final data = await _serviceApi.getServices();
      setState(() {
        services = data;
        isSearching = false;
      });
    } catch (e) {
      setState(() => isSearching = false);
    }
  }

  Future<void> _deleteComplaint(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Hapus Pengaduan?',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text('Data pengaduan ini akan dihapus permanen.'),
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
      await _service.delete(id);
      _loadComplaints();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pengaduan berhasil dihapus'),
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

  void _showForm({Complaint? complaint}) {
    final bool isEdit = complaint != null;
    final nameCtrl = TextEditingController(text: complaint?.serviceName ?? '');
    final descCtrl = TextEditingController(text: complaint?.description ?? '');
    final searchCtrl = TextEditingController();

    String category = complaint?.category ?? 'Pemeliharaan';
    bool isActive = complaint?.isActive ?? true;
    List<dynamic> searchResults = [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              margin: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 20,
              ),
              decoration: const BoxDecoration(
                color: AppColors.bgLight,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  // Drag handle
                  Container(
                    margin: const EdgeInsets.only(top: 12, bottom: 8),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.grey300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Expanded(
                    child: CustomScrollView(
                      slivers: [
                        // HEADER GRADIENT
                        SliverToBoxAdapter(
                          child: Container(
                            margin: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Color(0xFF4DA6FF), Color(0xFF0077E6)],
                              ),
                              borderRadius: BorderRadius.circular(24),
                            ),
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
                                    Text(
                                      isEdit
                                          ? 'Edit Pengaduan'
                                          : 'Tambah Pengaduan',
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.white,
                                      ),
                                    ),
                                  ],
                                ),
                                if (!isEdit) ...[
                                  const SizedBox(height: 16),
                                  // SEARCH BAR (hanya mode tambah)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 4),
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
                                            controller: searchCtrl,
                                            decoration: const InputDecoration(
                                              hintText: 'Cari Layanan....',
                                              hintStyle: TextStyle(
                                                  color: AppColors.grey500),
                                              border: InputBorder.none,
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                      vertical: 12),
                                            ),
                                            onChanged: (val) async {
                                              if (val.length >= 2) {
                                                setModalState(
                                                    () => isSearching = true);
                                                try {
                                                  final all = await _serviceApi
                                                      .getServices();
                                                  final filtered =
                                                      all.where((s) {
                                                    final name = s['name']
                                                            ?.toString()
                                                            .toLowerCase() ??
                                                        '';
                                                    return name.contains(
                                                        val.toLowerCase());
                                                  }).toList();
                                                  setModalState(() {
                                                    searchResults = filtered;
                                                    isSearching = false;
                                                  });
                                                } catch (e) {
                                                  setModalState(() =>
                                                      isSearching = false);
                                                }
                                              } else {
                                                setModalState(
                                                    () => searchResults = []);
                                              }
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // HASIL PENCARIAN
                                  if (searchResults.isNotEmpty)
                                    Container(
                                      margin: const EdgeInsets.only(top: 8),
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: AppColors.white,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Column(
                                        children: searchResults.map((s) {
                                          return ListTile(
                                            dense: true,
                                            title: Text(
                                              s['name']?.toString() ?? '',
                                              style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600),
                                            ),
                                            subtitle: Text(
                                              'Rp ${s['price'] ?? 0}',
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color: AppColors.grey500),
                                            ),
                                            onTap: () {
                                              nameCtrl.text =
                                                  s['name']?.toString() ?? '';
                                              setModalState(
                                                  () => searchResults = []);
                                            },
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                ],
                              ],
                            ),
                          ),
                        ),

                        // FORM FIELDS
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // NAMA LAYANAN
                                const Text(
                                  'Nama Layanan',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.dark1,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
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
                                  child: Row(
                                    children: [
                                      const Icon(Icons.business_outlined,
                                          color: AppColors.dark3, size: 22),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: TextField(
                                          controller: nameCtrl,
                                          decoration: const InputDecoration(
                                            hintText:
                                                'Deskripsikan Layanannya....',
                                            hintStyle: TextStyle(
                                                color: AppColors.grey500),
                                            border: InputBorder.none,
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    vertical: 14),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 20),

                                // DESKRIPSI
                                const Text(
                                  'Deskripsi Layanan',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.dark1,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
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
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Padding(
                                        padding: EdgeInsets.only(top: 14),
                                        child: Icon(Icons.format_list_bulleted,
                                            color: AppColors.dark3, size: 22),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: TextField(
                                          controller: descCtrl,
                                          maxLines: 4,
                                          decoration: const InputDecoration(
                                            hintText:
                                                'Jelaskan detail untuk layanan ini....',
                                            hintStyle: TextStyle(
                                                color: AppColors.grey500),
                                            border: InputBorder.none,
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    vertical: 14),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 20),

                                // KATEGORI
                                const Text(
                                  'Kategori',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.dark1,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 4),
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
                                  child: Row(
                                    children: [
                                      const Icon(Icons.tune,
                                          color: AppColors.dark3, size: 22),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: DropdownButtonHideUnderline(
                                          child: DropdownButton<String>(
                                            isExpanded: true,
                                            value: category,
                                            icon: const Icon(
                                                Icons.keyboard_arrow_down,
                                                color: AppColors.dark3),
                                            items: [
                                              'Pemeliharaan',
                                              'Gangguan',
                                              'Kehilangan Air',
                                              'Kualitas Air',
                                              'Lainnya',
                                            ].map((String val) {
                                              return DropdownMenuItem<String>(
                                                value: val,
                                                child: Text(
                                                  val,
                                                  style: const TextStyle(
                                                      fontSize: 14,
                                                      color: AppColors.dark1),
                                                ),
                                              );
                                            }).toList(),
                                            onChanged: (v) {
                                              if (v != null) {
                                                setModalState(
                                                    () => category = v);
                                              }
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 24),

                                // TOGGLE STATUS
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: isActive
                                        ? const Color(0xFFE8F5E9)
                                        : const Color(0xFFFFEBEE),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              isActive
                                                  ? 'Status Aktif'
                                                  : 'Status NonAktif',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: isActive
                                                    ? AppColors.success
                                                    : AppColors.error,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              'Layanan ditampilkan ke pelanggan',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: AppColors.grey600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Switch(
                                        value: isActive,
                                        onChanged: (v) {
                                          setModalState(() => isActive = v);
                                        },
                                        activeColor: AppColors.success,
                                        activeTrackColor:
                                            const Color(0xFFA5D6A7),
                                        inactiveThumbColor: AppColors.error,
                                        inactiveTrackColor:
                                            const Color(0xFFEF9A9A),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 32),

                                // TOMBOL SIMPAN
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
                                    onPressed: () async {
                                      if (nameCtrl.text.trim().isEmpty) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                                'Nama layanan wajib diisi'),
                                            backgroundColor: AppColors.warning,
                                          ),
                                        );
                                        return;
                                      }
                                      Navigator.pop(context);
                                      final Complaint comp = Complaint(
                                        id: complaint?.id ?? '',
                                        serviceName: nameCtrl.text.trim(),
                                        description: descCtrl.text.trim(),
                                        category: category,
                                        isActive: isActive,
                                        createdAt: complaint?.createdAt ??
                                            DateTime.now(),
                                      );
                                      try {
                                        if (isEdit) {
                                          await _service.update(comp);
                                        } else {
                                          await _service.create(comp);
                                        }
                                        _loadComplaints();
                                        if (mounted) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(isEdit
                                                  ? 'Pengaduan berhasil diupdate'
                                                  : 'Pengaduan berhasil ditambah'),
                                              backgroundColor:
                                                  AppColors.success,
                                            ),
                                          );
                                        }
                                      } catch (e) {
                                        if (mounted) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text('Error: $e'),
                                              backgroundColor: AppColors.error,
                                            ),
                                          );
                                        }
                                      }
                                    },
                                    child: const Text(
                                      'Simpan Layanan',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),

                                // TOMBOL BATAL
                                SizedBox(
                                  width: double.infinity,
                                  height: 52,
                                  child: OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AppColors.error,
                                      side: const BorderSide(
                                          color: AppColors.error),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                    ),
                                    onPressed: () => Navigator.pop(context),
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
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AppProvider>().user;

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showForm(),
        backgroundColor: AppColors.mainColor,
        icon: const Icon(Icons.add),
        label: const Text('Tambah'),
      ),
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
                                  Icons.support_agent,
                                  color: AppColors.white,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Pengaduan',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: AppColors.white70,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    user?.name ?? 'Customer',
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
                      // STAT CARD
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _statItem(complaints.length.toString(), 'Total',
                                AppColors.mainColor),
                            _statItem(
                                complaints
                                    .where((c) => c.isActive)
                                    .length
                                    .toString(),
                                'Aktif',
                                AppColors.success),
                            _statItem(
                                complaints
                                    .where((c) => !c.isActive)
                                    .length
                                    .toString(),
                                'NonAktif',
                                AppColors.error),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // LIST
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              child: isLoading
                  ? const Column(
                      children: [
                        ShimmerCard(height: 100),
                        SizedBox(height: 12),
                        ShimmerCard(height: 100),
                      ],
                    )
                  : errorMessage != null
                      ? Center(
                          child: Column(
                            children: [
                              const Icon(Icons.error_outline,
                                  color: AppColors.error, size: 48),
                              const SizedBox(height: 8),
                              Text(errorMessage!),
                              TextButton(
                                onPressed: _loadComplaints,
                                child: const Text('Coba Lagi'),
                              ),
                            ],
                          ),
                        )
                      : complaints.isEmpty
                          ? Center(
                              child: Column(
                                children: [
                                  const SizedBox(height: 40),
                                  Icon(Icons.inbox_outlined,
                                      size: 64, color: AppColors.grey300),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Belum ada pengaduan',
                                    style: TextStyle(
                                      color: AppColors.grey500,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Tap tombol + untuk menambah',
                                    style: TextStyle(
                                      color: AppColors.grey400,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : Column(
                              children: complaints.map((c) {
                                return _buildComplaintCard(c);
                              }).toList(),
                            ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statItem(String value, String label, Color color) {
    return Column(
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
            color: AppColors.grey600,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildComplaintCard(Complaint c) {
    final Color statusColor = c.isActive ? AppColors.success : AppColors.error;
    final Color statusBg =
        c.isActive ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE);
    final String statusText = c.isActive ? 'Aktif' : 'NonAktif';

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
                      c.serviceName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.dark1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      c.category,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.mainColor,
                        fontWeight: FontWeight.w600,
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
          const SizedBox(height: 8),
          Text(
            c.description,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.grey600,
              height: 1.4,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: () => _showForm(complaint: c),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE3F2FD),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.edit, size: 16, color: AppColors.mainColor),
                      SizedBox(width: 6),
                      Text(
                        'Edit',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.mainColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => _deleteComplaint(c.id),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEBEE),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.delete, size: 16, color: AppColors.error),
                      SizedBox(width: 6),
                      Text(
                        'Hapus',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.error,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
