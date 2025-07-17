// lib/features/trip/presentation/widgets/passenger_list_card.dart
import 'package:daladala_smart_driver/core/ui/widgets/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/trip.dart';
import '../providers/trip_provider.dart';

class PassengerListCard extends StatelessWidget {
  final Trip trip;

  const PassengerListCard({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    return Consumer<TripProvider>(
      builder: (context, tripProvider, child) {
        final passengers = tripProvider.currentPassengers;

        if (tripProvider.isLoading && passengers.isEmpty) {
          return const LoadingIndicator(message: 'Loading passengers...');
        }

        if (passengers.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 48,
                    color: AppTheme.textTertiaryColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No passengers yet',
                    style: TextStyle(
                      fontSize: 16,
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
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: passengers.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final passenger = passengers[index];
            return PassengerListItem(
              passenger: passenger,
              onBoardTap: () => _handleBoardPassenger(context, passenger),
              onDisembarkTap: () => _handleDisembarkPassenger(context, passenger),
            );
          },
        );
      },
    );
  }

  Future<void> _handleBoardPassenger(BuildContext context, TripPassenger passenger) async {
    final tripProvider = Provider.of<TripProvider>(context, listen: false);
    
    final success = await tripProvider.markPassengerBoarded(passenger.bookingId);
    
    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${passenger.passengerName} has boarded'),
          backgroundColor: AppTheme.successColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(tripProvider.errorMessage ?? 'Failed to board passenger'),
          backgroundColor: AppTheme.errorColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _handleDisembarkPassenger(BuildContext context, TripPassenger passenger) async {
    final tripProvider = Provider.of<TripProvider>(context, listen: false);
    
    final success = await tripProvider.markPassengerDisembarked(passenger.bookingId);
    
    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${passenger.passengerName} has disembarked'),
          backgroundColor: AppTheme.infoColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(tripProvider.errorMessage ?? 'Failed to disembark passenger'),
          backgroundColor: AppTheme.errorColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

class PassengerListItem extends StatelessWidget {
  final TripPassenger passenger;
  final VoidCallback? onBoardTap;
  final VoidCallback? onDisembarkTap;

  const PassengerListItem({
    super.key,
    required this.passenger,
    this.onBoardTap,
    this.onDisembarkTap,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(passenger.status);
    final formatter = NumberFormat('#,###');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: statusColor.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              // Status Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              
              const Spacer(),
              
              // Passenger Count
              if (passenger.passengerCount > 1) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${passenger.passengerCount} PAX',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.accentColor,
                    ),
                  ),
                ),
              ],
            ],
          ),

          const SizedBox(height: 12),

          // Passenger Info
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
            ],
          ),

          const SizedBox(height: 12),

          // Journey Info
          Row(
            children: [
              Icon(
                Icons.location_on,
                size: 16,
                color: AppTheme.textSecondaryColor,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  '${passenger.pickupStopName} → ${passenger.dropoffStopName}',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
              ),
            ],
          ),

          // Seat Numbers
          if (passenger.seatNumbers != null && passenger.seatNumbers!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.airline_seat_recline_normal,
                  size: 16,
                  color: AppTheme.textSecondaryColor,
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

          const SizedBox(height: 8),

          // Fare Amount
          Row(
            children: [
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
                  fontWeight: FontWeight.w600,
                  color: AppTheme.successColor,
                ),
              ),
              
              const Spacer(),
              
              // Action Buttons
              _buildActionButtons(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    if (passenger.canBoard) {
      return SizedBox(
        height: 32,
        child: ElevatedButton.icon(
          onPressed: onBoardTap,
          icon: const Icon(Icons.login, size: 16),
          label: const Text('Board', style: TextStyle(fontSize: 12)),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.successColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ),
      );
    } else if (passenger.canDisembark) {
      return SizedBox(
        height: 32,
        child: ElevatedButton.icon(
          onPressed: onDisembarkTap,
          icon: const Icon(Icons.logout, size: 16),
          label: const Text('Disembark', style: TextStyle(fontSize: 12)),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.infoColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: _getStatusColor(passenger.status).withOpacity(0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          _getStatusText(passenger.status),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: _getStatusColor(passenger.status),
          ),
        ),
      );
    }
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
        return AppTheme.textSecondaryColor;
      case 'cancelled':
        return AppTheme.errorColor;
      default:
        return AppTheme.textTertiaryColor;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
      case 'paid':
        return 'Ready to board';
      case 'boarded':
      case 'in_trip':
        return 'On board';
      case 'disembarked':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }
}
