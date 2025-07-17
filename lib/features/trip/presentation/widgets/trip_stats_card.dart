// lib/features/trip/presentation/widgets/trip_stats_card.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/location_service.dart';
import '../../domain/entities/trip.dart';

class TripStatsCard extends StatelessWidget {
  final Trip trip;

  const TripStatsCard({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,###');

    return Consumer<LocationService>(
      builder: (context, locationService, child) {
        final speed = locationService.getSpeedKmh() ?? 0.0;
        final currentLocation = locationService.currentPosition;

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Speed and Distance Row
              Row(
                children: [
                  Expanded(
                    child: _buildStatItem(
                      icon: Icons.speed,
                      label: 'Speed',
                      value: '${speed.toStringAsFixed(0)} km/h',
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatItem(
                      icon: Icons.route,
                      label: 'Distance',
                      value:
                          '${trip.route?.distanceKm?.toStringAsFixed(1) ?? '0'} km',
                      color: AppTheme.infoColor,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Passengers and Earnings Row
              Row(
                children: [
                  Expanded(
                    child: _buildStatItem(
                      icon: Icons.people,
                      label: 'Passengers',
                      value:
                          '${trip.currentPassengers ?? 0}/${trip.vehicle?.capacity ?? 0}',
                      color: AppTheme.accentColor,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatItem(
                      icon: Icons.monetization_on,
                      label: 'Earnings',
                      value: 'TZS ${formatter.format(trip.earnings ?? 0)}',
                      color: AppTheme.successColor,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Location Info
              if (currentLocation != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 16,
                            color: AppTheme.textSecondaryColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Current Location',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.textSecondaryColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${currentLocation.latitude.toStringAsFixed(6)}, ${currentLocation.longitude.toStringAsFixed(6)}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, size: 24, color: color),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: AppTheme.textSecondaryColor),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
