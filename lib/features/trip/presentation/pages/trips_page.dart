// lib/features/trip/presentation/pages/trips_page.dart
import 'package:daladala_smart_driver/core/ui/widgets/loading_indicator.dart';
import 'package:daladala_smart_driver/features/trip/domain/entities/trip.dart';
import 'package:daladala_smart_driver/features/trip/presentation/pages/trip_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/widgets/custom_button.dart';
import '../providers/trip_provider.dart';
import '../widgets/trip_list_item.dart';
import '../widgets/active_trip_card.dart';
import '../widgets/trip_filter_chip.dart';
import '../widgets/trip_stats_banner.dart';

class TripsPage extends StatefulWidget {
  const TripsPage({super.key});

  @override
  State<TripsPage> createState() => _TripsPageState();
}

class _TripsPageState extends State<TripsPage>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  String _selectedFilter = 'today';
  bool _isRefreshing = false;

  final List<Map<String, dynamic>> _filterOptions = [
    {'key': 'today', 'label': 'Today', 'icon': Icons.today},
    {'key': 'active', 'label': 'Active', 'icon': Icons.directions_bus},
    {'key': 'completed', 'label': 'Completed', 'icon': Icons.check_circle},
    {'key': 'all', 'label': 'All Trips', 'icon': Icons.list},
  ];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _setupAnimation();
    _loadTrips();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _setupAnimation() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.forward();
  }

  Future<void> _loadTrips() async {
    final tripProvider = Provider.of<TripProvider>(context, listen: false);

    switch (_selectedFilter) {
      case 'today':
        await tripProvider.loadTodayTrips();
        break;
      case 'active':
        await tripProvider.loadDriverTrips(status: 'in_progress');
        break;
      case 'completed':
        await tripProvider.loadDriverTrips(status: 'completed');
        break;
      case 'all':
        await tripProvider.loadDriverTrips();
        break;
    }
  }

  Future<void> _refreshTrips() async {
    if (_isRefreshing) return;

    setState(() => _isRefreshing = true);

    try {
      await _loadTrips();
      _animationController.forward();
    } finally {
      setState(() => _isRefreshing = false);
    }
  }

  void _onFilterChanged(String filter) {
    if (_selectedFilter == filter) return;

    setState(() => _selectedFilter = filter);
    _animationController.reset();
    _loadTrips().then((_) => _animationController.forward());
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        body: Consumer<TripProvider>(
          builder: (context, tripProvider, child) {
            return CustomScrollView(
              slivers: [
                // Custom App Bar
                _buildAppBar(tripProvider),

                // Trip Stats Banner
                if (_selectedFilter == 'today' || _selectedFilter == 'all') ...[
                  SliverToBoxAdapter(
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: TripStatsBanner(provider: tripProvider),
                    ),
                  ),
                ],

                // Filter Chips
                SliverToBoxAdapter(child: _buildFilterChips()),

                // Active Trip Card (if any)
                if (tripProvider.hasActiveTrip) ...[
                  SliverToBoxAdapter(
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: ActiveTripCard(
                          trip: tripProvider.activeTrip!,
                          onTap:
                              () => _navigateToTripDetail(
                                tripProvider.activeTrip!,
                              ),
                        ),
                      ),
                    ),
                  ),
                ],

                // Trips List
                _buildTripsList(tripProvider),

                // Bottom Padding
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            );
          },
        ),

        // Floating Action Button
        floatingActionButton: Consumer<TripProvider>(
          builder: (context, tripProvider, child) {
            if (!tripProvider.hasActiveTrip) return const SizedBox.shrink();

            return FloatingActionButton.extended(
              onPressed:
                  () => _navigateToTripTracking(tripProvider.activeTrip!),
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.navigation),
              label: const Text('Track Trip'),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAppBar(TripProvider tripProvider) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: true,
      pinned: true,
      backgroundColor: AppTheme.primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          'My Trips',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: AppTheme.white,
          ),
        ),
        titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.primaryColor,
                AppTheme.primaryColor.withOpacity(0.8),
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Spacer(),
                  if (tripProvider.hasActiveTrip) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.successColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'ACTIVE TRIP',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          onPressed: _refreshTrips,
          icon:
              _isRefreshing
                  ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                  : const Icon(Icons.refresh),
        ),
        IconButton(
          onPressed: () => _showFilterDialog(context),
          icon: const Icon(Icons.filter_list),
        ),
      ],
    );
  }

  Widget _buildFilterChips() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children:
              _filterOptions.map((option) {
                final isSelected = _selectedFilter == option['key'];
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: TripFilterChip(
                    label: option['label'],
                    icon: option['icon'],
                    isSelected: isSelected,
                    onTap: () => _onFilterChanged(option['key']),
                  ),
                );
              }).toList(),
        ),
      ),
    );
  }

  Widget _buildTripsList(TripProvider tripProvider) {
    if (tripProvider.isLoading && tripProvider.trips.isEmpty) {
      return const SliverFillRemaining(
        child: LoadingIndicator(message: 'Loading trips...'),
      );
    }

    final trips = _getFilteredTrips(tripProvider);

    if (trips.isEmpty) {
      return SliverFillRemaining(child: _buildEmptyState());
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final trip = trips[index];
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: Offset(0, 0.1 * (index + 1)),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(
                parent: _animationController,
                curve: Interval(
                  (index * 0.1).clamp(0.0, 0.8),
                  (index * 0.1 + 0.2).clamp(0.2, 1.0),
                  curve: Curves.easeOutCubic,
                ),
              ),
            ),
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                16,
                index == 0 ? 8 : 4,
                16,
                index == trips.length - 1 ? 16 : 4,
              ),
              child: TripListItem(
                trip: trip,
                onTap: () => _navigateToTripDetail(trip),
                onTrackTap:
                    trip.isActive ? () => _navigateToTripTracking(trip) : null,
              ),
            ),
          ),
        );
      }, childCount: trips.length),
    );
  }

  List<Trip> _getFilteredTrips(TripProvider tripProvider) {
    switch (_selectedFilter) {
      case 'today':
        return tripProvider.todayTrips;
      case 'active':
        return tripProvider.trips
            .where((t) => t.status == 'in_progress')
            .toList();
      case 'completed':
        return tripProvider.trips
            .where((t) => t.status == 'completed')
            .toList();
      case 'all':
      default:
        return tripProvider.trips;
    }
  }

  Widget _buildEmptyState() {
    String title, message;
    IconData icon;
    Widget? action;

    switch (_selectedFilter) {
      case 'today':
        icon = Icons.today;
        title = 'No trips today';
        message = 'Go online to start accepting trip requests for today';
        action = CustomButton(
          text: 'Go Online',
          onPressed: () => _goOnline(),
          type: ButtonType.primary,
          icon: Icons.power_settings_new,
        );
        break;
      case 'active':
        icon = Icons.directions_bus;
        title = 'No active trips';
        message = 'Start a scheduled trip to see it here';
        action = CustomButton(
          text: 'View All Trips',
          onPressed: () => _onFilterChanged('all'),
          type: ButtonType.secondary,
          icon: Icons.list,
        );
        break;
      case 'completed':
        icon = Icons.check_circle_outline;
        title = 'No completed trips';
        message = 'Complete some trips to see your history here';
        break;
      case 'all':
      default:
        icon = Icons.history;
        title = 'No trips found';
        message = 'Your trip history will appear here once you start driving';
        action = CustomButton(
          text: 'Refresh',
          onPressed: _refreshTrips,
          type: ButtonType.secondary,
          icon: Icons.refresh,
        );
        break;
    }

    return DefaultTabController(
      length: 3,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 48, color: AppTheme.textTertiaryColor),
              ),

              const SizedBox(height: 24),

              Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimaryColor,
                ),
              ),

              const SizedBox(height: 12),

              Text(
                message,
                style: TextStyle(
                  fontSize: 16,
                  color: AppTheme.textSecondaryColor,
                ),
                textAlign: TextAlign.center,
              ),

              if (action != null) ...[const SizedBox(height: 20), action],
            ],
          ),
        ),
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Filter Trips',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimaryColor,
                  ),
                ),

                const SizedBox(height: 20),

                ..._filterOptions.map((option) {
                  final isSelected = _selectedFilter == option['key'];
                  return ListTile(
                    leading: Icon(
                      option['icon'],
                      color:
                          isSelected
                              ? AppTheme.primaryColor
                              : AppTheme.textSecondaryColor,
                    ),
                    title: Text(
                      option['label'],
                      style: TextStyle(
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                        color:
                            isSelected
                                ? AppTheme.primaryColor
                                : AppTheme.textPrimaryColor,
                      ),
                    ),
                    trailing:
                        isSelected
                            ? Icon(Icons.check, color: AppTheme.primaryColor)
                            : null,
                    onTap: () {
                      Navigator.pop(context);
                      _onFilterChanged(option['key']);
                    },
                  );
                }).toList(),

                const SizedBox(height: 20),
              ],
            ),
          ),
    );
  }

  void _navigateToTripDetail(Trip trip) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TripDetailPage(trip: trip)),
    );
  }

  void _navigateToTripTracking(Trip trip) {
    Navigator.pushNamed(context, '/trip-tracking', arguments: trip);
  }

  void _goOnline() {
    // Navigate to dashboard and trigger go online
    Navigator.popUntil(context, (route) => route.isFirst);
    // You can add a callback to trigger going online in the dashboard
  }
}
