import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../widgets/bottom_nav.dart';
import 'customer_home_screen.dart';
import 'admin_dashboard_screen.dart';
import 'bill_list_screen.dart';
import 'complaint_screen.dart';
import 'profile_screen.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        final isAdmin = provider.isAdmin;
        final screens = [
          isAdmin ? const AdminDashboardScreen() : const CustomerHomeScreen(),
          const BillListScreen(),
          const ComplaintScreen(),
          const ProfileScreen(),
        ];

        return Scaffold(
          body: IndexedStack(
            index: provider.bottomNavIndex,
            children: screens,
          ),
          bottomNavigationBar: BottomNavBar(
            currentIndex: provider.bottomNavIndex,
            onTap: provider.setBottomNavIndex,
            isAdmin: isAdmin,
          ),
        );
      },
    );
  }
}