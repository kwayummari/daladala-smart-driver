// lib/features/dashboard/presentation/widgets/driver_status_card.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/widgets/custom_button.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class DriverStatusCard extends StatelessWidget {
  const DriverStatusCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final driver = authProvider.driver;
        final isOnline = driver?.isOnline ?? false;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors:
                  isOnline
                      ? [AppTheme.primaryColor, AppTheme.primaryColor]
                      : [
                        AppTheme.textSecondaryColor,
                        AppTheme.textSecondaryColor.withOpacity(0.8),
                      ],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: (isOnline
                        ? AppTheme.successColor
                        : AppTheme.textSecondaryColor)
                    .withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      isOnline
                          ? Icons.radio_button_checked
                          : Icons.radio_button_off,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isOnline ? 'You\'re Online' : 'You\'re Offline',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          isOnline
                              ? 'Ready to accept passengers'
                              : 'Go online to start accepting trips',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              CustomButton(
                text: isOnline ? 'Go Offline' : 'Go Online',
                onPressed:
                    authProvider.isLoading
                        ? null
                        : () => _toggleDriverStatus(context),
                type: ButtonType.secondary,
                backgroundColor: Colors.white,
                textColor: isOnline ? AppTheme.white : AppTheme.white,
                borderColor: Colors.white,
                isFullWidth: true,
                height: 44,
                isLoading: authProvider.isLoading,
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _toggleDriverStatus(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final driver = authProvider.driver;

    if (driver == null) return;

    final newStatus = driver.isOnline ? 'offline' : 'online';

    final success = await authProvider.updateDriverStatus(newStatus);

    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            newStatus == 'online'
                ? 'You are now online and ready to accept trips!'
                : 'You are now offline',
          ),
          backgroundColor:
              newStatus == 'online'
                  ? AppTheme.successColor
                  : AppTheme.textSecondaryColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
