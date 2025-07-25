// lib/features/trip/presentation/widgets/trip_control_panel.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/widgets/custom_button.dart';
import '../../../../core/services/socket_service.dart';
import '../../domain/entities/trip.dart';
import '../providers/trip_provider.dart';

class TripControlPanel extends StatelessWidget {
  final Trip trip;

  const TripControlPanel({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Emergency Button
            CustomButton(
              text: 'Emergency Alert',
              onPressed: () => _showEmergencyDialog(context),
              type: ButtonType.primary,
              backgroundColor: AppTheme.errorColor,
              icon: Icons.warning,
              height: 48,
            ),

            const SizedBox(height: 12),

            // Break Button
            CustomButton(
              text: 'Take Break',
              onPressed: () => _showBreakDialog(context),
              type: ButtonType.secondary,
              icon: Icons.pause,
              height: 48,
            ),

            const SizedBox(height: 12),

            // End Trip Button
            Consumer<TripProvider>(
              builder: (context, tripProvider, child) {
                return CustomButton(
                  text: 'End Trip',
                  onPressed:
                      tripProvider.isLoading
                          ? null
                          : () => _showEndTripDialog(context),
                  type: ButtonType.primary,
                  backgroundColor: AppTheme.warningColor,
                  icon: Icons.stop,
                  height: 48,
                  isLoading: tripProvider.isLoading,
                );
              },
            ),

            const SizedBox(height: 20),

            // Quick Stats
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    'Trip Summary',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimaryColor,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildQuickStat(
                        'Passengers',
                        '${trip.currentPassengers ?? 0}',
                        Icons.people,
                        AppTheme.primaryColor,
                      ),
                      _buildQuickStat(
                        'Capacity',
                        '${trip.vehicle?.capacity ?? 0}',
                        Icons.event_seat,
                        AppTheme.accentColor,
                      ),
                      _buildQuickStat(
                        'Earnings',
                        'TZS ${(trip.earnings ?? 0).toStringAsFixed(0)}',
                        Icons.monetization_on,
                        AppTheme.successColor,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStat(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: AppTheme.textSecondaryColor),
        ),
      ],
    );
  }

  void _showEmergencyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.warning, color: AppTheme.errorColor),
                const SizedBox(width: 8),
                const Text('Emergency Alert'),
              ],
            ),
            content: const Text(
              'This will send an emergency alert to our support team and notify authorities. Are you in immediate danger?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _sendEmergencyAlert(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.errorColor,
                ),
                child: const Text('Send Alert'),
              ),
            ],
          ),
    );
  }

  void _showBreakDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Take Break'),
            content: const Text(
              'This will temporarily pause your trip. Passengers will be notified that you are on a short break.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _takeBreak(context);
                },
                child: const Text('Take Break'),
              ),
            ],
          ),
    );
  }

  void _showEndTripDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('End Trip'),
            content: const Text(
              'Are you sure you want to end this trip? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _endTrip(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.errorColor,
                ),
                child: const Text('End Trip'),
              ),
            ],
          ),
    );
  }

  Future<void> _sendEmergencyAlert(BuildContext context) async {
    final socketService = Provider.of<SocketService>(context, listen: false);

    socketService.emitEmergencyAlert(
      type: 'driver_emergency',
      message: 'Driver emergency alert from trip ${trip.tripId}',
      tripId: trip.tripId,
    );

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Emergency alert sent! Help is on the way.'),
          backgroundColor: AppTheme.errorColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _takeBreak(BuildContext context) async {
    final socketService = Provider.of<SocketService>(context, listen: false);

    socketService.emitTripStatusUpdate(
      tripId: trip.tripId,
      status: 'break',
      additionalData: {'break_started': DateTime.now().toIso8601String()},
    );

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Break started. Passengers have been notified.'),
          backgroundColor: AppTheme.infoColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _endTrip(BuildContext context) async {
    final tripProvider = Provider.of<TripProvider>(context, listen: false);

    final success = await tripProvider.endTrip(trip.tripId);

    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Trip ended successfully!'),
          backgroundColor: AppTheme.successColor,
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Navigate back to dashboard
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(tripProvider.errorMessage ?? 'Failed to end trip'),
          backgroundColor: AppTheme.errorColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
