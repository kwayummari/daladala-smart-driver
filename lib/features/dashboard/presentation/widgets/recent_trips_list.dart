// lib/features/dashboard/presentation/widgets/recent_trips_list.dart
import 'package:daladala_smart_driver/core/ui/widgets/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../trip/presentation/providers/trip_provider.dart';
import '../../../trip/domain/entities/trip.dart';

class RecentTripsList extends StatelessWidget {
  const RecentTripsList({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TripProvider>(
      builder: (context, tripProvider, child) {
        if (tripProvider.isLoading) {
          return const SizedBox(
            height: 200,
            child: LoadingIndicator(message: 'Loading trips...'),
          );
        }

        final trips = tripProvider.todayTrips;

        if (trips.isEmpty) {
          return Container(
            height: 200,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.route_outlined,
                  size: 48,
                  color: AppTheme.textTertiaryColor,
                ),
                const SizedBox(height: 16),
                Text(
                  'No trips today',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Go online to start accepting trip requests',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textTertiaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: trips.length > 3 ? 3 : trips.length, // Show max 3 trips
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final trip = trips[index];
            return _TripListItem(trip: trip);
          },
        );
      },
    );
  }
}

class _TripListItem extends StatelessWidget {
  final Trip trip;

  const _TripListItem({required this.trip});

  @override
  Widget build(BuildContext context) {
    final timeFormatter = DateFormat('HH:mm');
    final statusColor = AppTheme.getTripStatusColor(trip.status);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  trip.status.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                timeFormatter.format(trip.startTime),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textSecondaryColor,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Icon(Icons.route, size: 20, color: AppTheme.primaryColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  trip.route?.routeName ?? 'Unknown Route',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimaryColor,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Row(
            children: [
              Icon(Icons.people, size: 16, color: AppTheme.textSecondaryColor),
              const SizedBox(width: 4),
              Text(
                '${trip.currentPassengers ?? 0}/${trip.vehicle?.capacity ?? 0} passengers',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondaryColor,
                ),
              ),
              const Spacer(),
              if (trip.earnings != null) ...[
                Icon(
                  Icons.monetization_on,
                  size: 16,
                  color: AppTheme.successColor,
                ),
                const SizedBox(width: 4),
                Text(
                  'TZS ${trip.earnings!.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.successColor,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
