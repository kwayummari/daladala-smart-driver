// lib/features/trip/presentation/pages/trip_detail_page.dart
import 'package:daladala_smart_driver/core/ui/widgets/loading_indicator.dart';
import 'package:daladala_smart_driver/features/profile/presentation/widgets/passenger_card.dart';
import 'package:daladala_smart_driver/features/profile/presentation/widgets/trip_timeline.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/trip.dart';
import '../providers/trip_provider.dart';
import 'trip_tracking_page.dart';

class TripDetailPage extends StatefulWidget {
  final Trip trip;

  const TripDetailPage({super.key, required this.trip});

  @override
  State<TripDetailPage> createState() => _TripDetailPageState();
}

class _TripDetailPageState extends State<TripDetailPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _setupAnimations();
    _loadTripData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _animationController.forward();
  }

  Future<void> _loadTripData() async {
    if (widget.trip.isActive) {
      final tripProvider = Provider.of<TripProvider>(context, listen: false);
      // Load passengers for active trip
      // This would typically call a method to get trip passengers
    }
  }

  @override
  Widget build(BuildContext context) {
    final timeFormatter = DateFormat('MMM dd, yyyy • HH:mm');
    final statusColor = AppTheme.getTripStatusColor(widget.trip.status);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 250,
            floating: false,
            pinned: true,
            backgroundColor: statusColor,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.trip.route?.routeName ?? 'Trip Details',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [statusColor, statusColor.withOpacity(0.8)],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const SizedBox(height: 60), // Space for app bar
                        // Status Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
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
                              Text(
                                widget.trip.status.toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Trip Info
                        Row(
                          children: [
                            Icon(
                              Icons.schedule,
                              color: Colors.white.withOpacity(0.9),
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              timeFormatter.format(widget.trip.startTime),
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 4),

                        Row(
                          children: [
                            Icon(
                              Icons.directions_bus,
                              color: Colors.white.withOpacity(0.9),
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              widget.trip.vehicle?.plateNumber ??
                                  'Unknown Vehicle',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Tab Bar
          SliverPersistentHeader(
            pinned: true,
            delegate: _TabBarDelegate(
              TabBar(
                controller: _tabController,
                labelColor: AppTheme.primaryColor,
                unselectedLabelColor: AppTheme.textSecondaryColor,
                indicatorColor: AppTheme.primaryColor,
                tabs: const [
                  Tab(text: 'Overview'),
                  Tab(text: 'Passengers'),
                  Tab(text: 'Timeline'),
                ],
              ),
            ),
          ),

          // Tab Content
          SliverFillRemaining(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildOverviewTab(),
                    _buildPassengersTab(),
                    _buildTimelineTab(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),

      // Floating Action Button
      floatingActionButton:
          widget.trip.isActive
              ? FloatingActionButton.extended(
                onPressed: () => _navigateToTripTracking(),
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                icon: const Icon(Icons.navigation),
                label: const Text('Track Trip'),
              )
              : null,
    );
  }

  Widget _buildOverviewTab() {
    final formatter = NumberFormat('#,###');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Route Information
          _buildSectionCard(
            title: 'Route Information',
            icon: Icons.route,
            child: Column(
              children: [
                _buildInfoRow(
                  label: 'Route',
                  value: widget.trip.route?.routeName ?? 'Unknown',
                  icon: Icons.directions,
                ),
                _buildInfoRow(
                  label: 'From',
                  value: widget.trip.route?.startPoint ?? 'Unknown',
                  icon: Icons.location_on,
                ),
                _buildInfoRow(
                  label: 'To',
                  value: widget.trip.route?.endPoint ?? 'Unknown',
                  icon: Icons.location_on,
                ),
                if (widget.trip.route?.distanceKm != null)
                  _buildInfoRow(
                    label: 'Distance',
                    value:
                        '${widget.trip.route!.distanceKm!.toStringAsFixed(1)} km',
                    icon: Icons.straighten,
                  ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Vehicle Information
          _buildSectionCard(
            title: 'Vehicle Information',
            icon: Icons.directions_bus,
            child: Column(
              children: [
                _buildInfoRow(
                  label: 'Plate Number',
                  value: widget.trip.vehicle?.plateNumber ?? 'Unknown',
                  icon: Icons.confirmation_number,
                ),
                _buildInfoRow(
                  label: 'Vehicle Type',
                  value: widget.trip.vehicle?.vehicleType ?? 'Unknown',
                  icon: Icons.category,
                ),
                _buildInfoRow(
                  label: 'Model',
                  value: widget.trip.vehicle?.model ?? 'Unknown',
                  icon: Icons.info,
                ),
                _buildInfoRow(
                  label: 'Capacity',
                  value: '${widget.trip.vehicle?.capacity ?? 0} passengers',
                  icon: Icons.people,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Trip Statistics
          _buildSectionCard(
            title: 'Trip Statistics',
            icon: Icons.analytics,
            child: Column(
              children: [
                _buildInfoRow(
                  label: 'Current Passengers',
                  value: '${widget.trip.currentPassengers ?? 0}',
                  icon: Icons.people,
                ),
                _buildInfoRow(
                  label: 'Earnings',
                  value: 'TZS ${formatter.format(widget.trip.earnings ?? 0)}',
                  icon: Icons.monetization_on,
                ),
                if (widget.trip.actualStartTime != null)
                  _buildInfoRow(
                    label: 'Started At',
                    value: DateFormat(
                      'HH:mm',
                    ).format(widget.trip.actualStartTime!),
                    icon: Icons.play_arrow,
                  ),
                if (widget.trip.actualEndTime != null)
                  _buildInfoRow(
                    label: 'Ended At',
                    value: DateFormat(
                      'HH:mm',
                    ).format(widget.trip.actualEndTime!),
                    icon: Icons.stop,
                  ),
                if (widget.trip.actualStartTime != null &&
                    widget.trip.actualEndTime != null)
                  _buildInfoRow(
                    label: 'Duration',
                    value: _formatDuration(
                      widget.trip.actualEndTime!.difference(
                        widget.trip.actualStartTime!,
                      ),
                    ),
                    icon: Icons.timer,
                  ),
              ],
            ),
          ),

          const SizedBox(height: 100), // Space for FAB
        ],
      ),
    );
  }

  Widget _buildPassengersTab() {
    return Consumer<TripProvider>(
      builder: (context, tripProvider, child) {
        if (tripProvider.isLoading) {
          return const LoadingIndicator(message: 'Loading passengers...');
        }

        final passengers = tripProvider.currentPassengers;

        if (passengers.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.people_outline,
                  size: 64,
                  color: AppTheme.textTertiaryColor,
                ),
                const SizedBox(height: 16),
                Text(
                  'No passengers',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Passengers will appear here when they book',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textTertiaryColor,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: passengers.length,
          itemBuilder: (context, index) {
            final passenger = passengers[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: PassengerCard(
                passenger: passenger,
                onBoardTap: () => _boardPassenger(passenger),
                onDisembarkTap: () => _disembarkPassenger(passenger),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTimelineTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: TripTimeline(trip: widget.trip),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppTheme.primaryColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppTheme.textSecondaryColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondaryColor,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimaryColor,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  Future<void> _boardPassenger(TripPassenger passenger) async {
    final tripProvider = Provider.of<TripProvider>(context, listen: false);

    final success = await tripProvider.markPassengerBoarded(
      passenger.bookingId,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${passenger.passengerName} has boarded'),
          backgroundColor: AppTheme.successColor,
        ),
      );
    }
  }

  Future<void> _disembarkPassenger(TripPassenger passenger) async {
    final tripProvider = Provider.of<TripProvider>(context, listen: false);

    final success = await tripProvider.markPassengerDisembarked(
      passenger.bookingId,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${passenger.passengerName} has disembarked'),
          backgroundColor: AppTheme.infoColor,
        ),
      );
    }
  }

  void _navigateToTripTracking() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TripTrackingPage(trip: widget.trip),
      ),
    );
  }
}

// Custom TabBar Delegate
class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _TabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(color: Colors.white, child: tabBar);
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}
