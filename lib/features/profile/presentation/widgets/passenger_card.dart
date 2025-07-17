// lib/features/trip/presentation/widgets/passenger_card.dart
import 'package:daladala_smart_driver/features/trip/domain/entities/trip.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';

class PassengerCard extends StatelessWidget {
  final TripPassenger passenger;
  final VoidCallback? onBoardTap;
  final VoidCallback? onDisembarkTap;

  const PassengerCard({
    super.key,
    required this.passenger,
    this.onBoardTap,
    this.onDisembarkTap,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(passenger.status);
    final formatter = NumberFormat('#,###');

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                  child: Text(
                    passenger.passengerName.isNotEmpty
                        ? passenger.passengerName[0].toUpperCase()
                        : 'P',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        passenger.passengerName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimaryColor,
                        ),
                      ),
                      if (passenger.passengerPhone.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          passenger.passengerPhone,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppTheme.textSecondaryColor,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    passenger.status.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Journey Info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 16,
                        color: AppTheme.primaryColor,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${passenger.pickupStopName} → ${passenger.dropoffStopName}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.textPrimaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),

                  if (passenger.seatNumbers != null &&
                      passenger.seatNumbers!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.airline_seat_recline_normal,
                          size: 16,
                          color: AppTheme.accentColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Seats: ${passenger.seatNumbers}',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppTheme.textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Footer
            Row(
              children: [
                Icon(
                  Icons.people,
                  size: 16,
                  color: AppTheme.textSecondaryColor,
                ),
                const SizedBox(width: 4),
                Text(
                  '${passenger.passengerCount} passenger${passenger.passengerCount != 1 ? 's' : ''}',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.textSecondaryColor,
                  ),
                ),

                const Spacer(),

                Icon(
                  Icons.monetization_on,
                  size: 16,
                  color: AppTheme.successColor,
                ),
                const SizedBox(width: 4),
                Text(
                  'TZS ${formatter.format(passenger.fareAmount)}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.successColor,
                  ),
                ),
              ],
            ),

            // Action Buttons
            if (passenger.canBoard || passenger.canDisembark) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  if (passenger.canBoard) ...[
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onBoardTap,
                        icon: const Icon(Icons.login, size: 16),
                        label: const Text('Board'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.successColor,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                  if (passenger.canDisembark) ...[
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onDisembarkTap,
                        icon: const Icon(Icons.logout, size: 16),
                        label: const Text('Disembark'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.infoColor,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
      case 'paid':
        return AppTheme.successColor;
      case 'boarded':
      case 'in_trip':
        return AppTheme.infoColor;
      case 'disembarked':
        return AppTheme.completedColor;
      case 'cancelled':
        return AppTheme.errorColor;
      default:
        return AppTheme.textSecondaryColor;
    }
  }
}
