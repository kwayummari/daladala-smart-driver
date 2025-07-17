// lib/features/qr_scanner/presentation/widgets/qr_validation_result_card.dart
import 'package:daladala_smart_driver/features/qr_scanner/domain/entities/qr_validation_result.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../../core/theme/app_theme.dart';

class QRValidationResultCard extends StatelessWidget {
  final QRValidationResult? result;
  final String? error;

  const QRValidationResultCard({super.key, this.result, this.error});

  @override
  Widget build(BuildContext context) {
    final bool isSuccess = result?.isValid == true;
    final Color cardColor =
        isSuccess ? AppTheme.successColor : AppTheme.errorColor;
    final IconData icon = isSuccess ? Icons.check_circle : Icons.error;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Status Icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: cardColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 40, color: cardColor),
          ),

          const SizedBox(height: 20),

          // Status Message
          Text(
            isSuccess ? 'Valid Ticket' : 'Invalid Ticket',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: cardColor,
            ),
          ),

          const SizedBox(height: 12),

          // Error Message or Success Details
          if (!isSuccess) ...[
            Text(
              error ?? result?.message ?? 'Unknown error',
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.textSecondaryColor,
              ),
              textAlign: TextAlign.center,
            ),
          ] else if (result != null) ...[
            _buildSuccessDetails(result!),
          ],
        ],
      ),
    );
  }

  Widget _buildSuccessDetails(QRValidationResult result) {
    final formatter = NumberFormat('#,###');

    return Column(
      children: [
        // Passenger Name
        if (result.passengerName != null) ...[
          _buildDetailRow(
            icon: Icons.person,
            label: 'Passenger',
            value: result.passengerName!,
          ),
          const SizedBox(height: 12),
        ],

        // Passenger Count
        if (result.passengerCount != null) ...[
          _buildDetailRow(
            icon: Icons.people,
            label: 'Passengers',
            value: '${result.passengerCount}',
          ),
          const SizedBox(height: 12),
        ],

        // Seat Numbers
        if (result.seatNumbers != null && result.seatNumbers!.isNotEmpty) ...[
          _buildDetailRow(
            icon: Icons.airline_seat_recline_normal,
            label: 'Seats',
            value: result.seatNumbers!,
          ),
          const SizedBox(height: 12),
        ],

        // Route
        if (result.routeName != null) ...[
          _buildDetailRow(
            icon: Icons.route,
            label: 'Route',
            value: result.routeName!,
          ),
          const SizedBox(height: 12),
        ],

        // Journey
        if (result.pickupStop != null && result.dropoffStop != null) ...[
          _buildDetailRow(
            icon: Icons.location_on,
            label: 'Journey',
            value: '${result.pickupStop} → ${result.dropoffStop}',
          ),
          const SizedBox(height: 12),
        ],

        // Fare Amount
        if (result.fareAmount != null) ...[
          _buildDetailRow(
            icon: Icons.monetization_on,
            label: 'Fare',
            value: 'TZS ${formatter.format(result.fareAmount)}',
            valueColor: AppTheme.successColor,
          ),
          const SizedBox(height: 12),
        ],

        // Phone Number
        if (result.passengerPhone != null) ...[
          _buildDetailRow(
            icon: Icons.phone,
            label: 'Phone',
            value: result.passengerPhone!,
          ),
        ],
      ],
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppTheme.textSecondaryColor),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: valueColor ?? AppTheme.textPrimaryColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
