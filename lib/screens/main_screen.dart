import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tirta_app/widgets/bottom_nav.dart';
import '../providers/app_provider.dart';
import 'admin_dashboard_screen.dart';
import 'customer_home_screen.dart';
import 'bill_list_screen.dart';
import 'profile_screen.dart';
import 'service_list_screen.dart';
import 'service_list_customer_screen.dart';
import 'welcome_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final isAdmin = context.watch<AppProvider>().isAdmin;

    final adminScreens = const [
      AdminDashboardScreen(),      // Home
      BillListScreen(),            // Tagihan
      ServiceListScreen(),         // Layanan (backend: /services)
      ProfileScreen(),             // Profil
    ];

    final customerScreens = const [
      CustomerHomeScreen(),        // Home
      BillListScreen(),            // Tagihan
      ServiceListCustomerScreen(), // Layanan (backend: /services)
      ProfileScreen(),             // Profil
    ];

    final screens = isAdmin ? adminScreens : customerScreens;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: BottomNav(
        currentIndex: _currentIndex,
        isAdmin: isAdmin,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}