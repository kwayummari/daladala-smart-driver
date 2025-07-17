// lib/features/profile/presentation/widgets/profile_info_card.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';

class ProfileInfoCard extends StatelessWidget {
  final dynamic driver; // Replace with proper Driver type

  const ProfileInfoCard({super.key, required this.driver});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.info, color: AppTheme.primaryColor, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Driver Information',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimaryColor,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              _buildInfoRow(
                icon: Icons.email,
                label: 'Email',
                value: driver.email,
              ),

              _buildInfoRow(
                icon: Icons.phone,
                label: 'Phone',
                value: driver.phone,
              ),

              _buildInfoRow(
                icon: Icons.credit_card,
                label: 'License Number',
                value: driver.licenseNumber,
              ),

              _buildInfoRow(
                icon: Icons.calendar_today,
                label: 'License Expiry',
                value: DateFormat('MMM dd, yyyy').format(driver.licenseExpiry),
              ),

              _buildInfoRow(
                icon: Icons.badge,
                label: 'ID Number',
                value: driver.idNumber,
              ),

              _buildInfoRow(
                icon: Icons.calendar_today,
                label: 'Member Since',
                value: DateFormat('MMM dd, yyyy').format(driver.createdAt),
                isLast: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    bool isLast = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
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
}
