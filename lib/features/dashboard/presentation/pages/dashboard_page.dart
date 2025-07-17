// lib/features/dashboard/presentation/pages/dashboard_page.dart
import 'package:daladala_smart_driver/features/dashboard/presentation/pages/dashboard_home_tab.dart';
import 'package:daladala_smart_driver/features/profile/presentation/pages/profile_page.dart';
import 'package:daladala_smart_driver/features/qr_scanner/presentation/pages/qr_scanner_page.dart';
import 'package:daladala_smart_driver/features/trip/presentation/pages/trips_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _currentIndex = 0;
  late PageController _pageController;

  final List<Widget> _pages = [
    const DashboardHomeTab(),
    const TripsPage(),
    const QRScannerPage(),
    const ProfilePage(),
  ];

  final List<BottomNavigationBarItem> _navItems = [
    BottomNavigationBarItem(
      icon: Icon(Icons.home_outlined),
      activeIcon: Icon(Icons.home),
      label: 'Home',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.route_outlined),
      activeIcon: Icon(Icons.route),
      label: 'Trips',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.qr_code_scanner_outlined),
      activeIcon: Icon(Icons.qr_code_scanner),
      label: 'Scan QR',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.person_outline),
      activeIcon: Icon(Icons.person),
      label: 'Profile',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Load driver profile and initial data
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.getProfile();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: _onTabTapped,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: AppTheme.primaryColor,
            unselectedItemColor: AppTheme.textSecondaryColor,
            selectedFontSize: 12,
            unselectedFontSize: 12,
            elevation: 0,
            backgroundColor: Colors.transparent,
            items: _navItems,
          ),
        ),
      ),
    );
  }
}
