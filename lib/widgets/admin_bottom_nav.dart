import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../screens/admin_dashboard_screen.dart';
import '../screens/admin_bill_list_screen.dart';
import '../screens/admin_service_request_screen.dart';
import '../screens/profile_screen.dart';

class AdminBottomNav extends StatelessWidget {
  final int currentIndex;
  const AdminBottomNav({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildItem(Icons.dashboard_outlined, 'Dashboard', 0, context),
              _buildItem(Icons.receipt_long_outlined, 'Tagihan', 1, context),
              _buildItem(Icons.build_circle_outlined, 'Pengajuan', 2, context),
              _buildItem(Icons.person_outline, 'Profil', 3, context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItem(
      IconData icon, String label, int index, BuildContext context) {
    final bool isActive = currentIndex == index;
    return GestureDetector(
      onTap: () {
        if (isActive) return;
        Widget screen;
        switch (index) {
          case 0:
            screen = const AdminDashboardScreen();
            break;
          case 1:
            screen = const AdminBillListScreen();
            break;
          case 2:
            screen = const AdminServiceRequestScreen();
            break;
          case 3:
            screen = const ProfileScreen();
            break;
          default:
            screen = const AdminDashboardScreen();
        }
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => screen),
          (route) => false,
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isActive ? AppColors.mainColor : AppColors.grey400,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              color: isActive ? AppColors.mainColor : AppColors.grey400,
            ),
          ),
        ],
      ),
    );
  }
}