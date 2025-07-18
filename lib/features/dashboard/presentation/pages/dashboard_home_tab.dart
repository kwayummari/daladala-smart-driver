// lib/features/dashboard/presentation/widgets/dashboard_home_tab.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../trip/presentation/providers/trip_provider.dart';
import '../widgets/driver_status_card.dart';
import '../widgets/earnings_summary_card.dart';
import '../widgets/trip_summary_card.dart';
import '../widgets/quick_actions_grid.dart';
import '../widgets/recent_trips_list.dart';

class DashboardHomeTab extends StatefulWidget {
  const DashboardHomeTab({super.key});

  @override
  State<DashboardHomeTab> createState() => _DashboardHomeTabState();
}

class _DashboardHomeTabState extends State<DashboardHomeTab> {
  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    final tripProvider = Provider.of<TripProvider>(context, listen: false);
    await tripProvider.loadTodayTrips();
  }

  Future<void> _refreshData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final tripProvider = Provider.of<TripProvider>(context, listen: false);

    await Future.wait([
      authProvider.getProfile(),
      tripProvider.loadTodayTrips(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            final driver = authProvider.driver;
            return Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hello ${driver?.firstName ?? 'Driver'}!',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    'Ready to earn today?',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        actions: [
          IconButton(
            onPressed: () {
              // TODO: Navigate to notifications
            },
            icon: Stack(
              children: [
                const Icon(Icons.notifications_outlined),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppTheme.accentColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        color: AppTheme.primaryColor,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Driver Status Card
              const DriverStatusCard(),

              const SizedBox(height: 16),

              // Summary Cards Row
              Row(
                children: [
                  Expanded(child: EarningsSummaryCard()),
                  const SizedBox(width: 12),
                  Expanded(child: TripSummaryCard()),
                ],
              ),

              const SizedBox(height: 20),

              // Quick Actions
              Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimaryColor,
                ),
              ),

              const SizedBox(height: 12),

              const QuickActionsGrid(),

              const SizedBox(height: 20),

              // Recent Trips
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Today\'s Trips',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimaryColor,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // Navigate to trips page
                      DefaultTabController.of(context)?.animateTo(1);
                    },
                    child: Text(
                      'See All',
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              const RecentTripsList(),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
