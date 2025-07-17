// lib/features/profile/presentation/widgets/earnings_summary_card.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';

class EarningsSummaryCard extends StatelessWidget {
  final dynamic driver; // Replace with proper Driver type

  const EarningsSummaryCard({super.key, required this.driver});

  @override
  Widget build(BuildContext context) {

    // Mock data - replace with actual earnings data
    final todayEarnings = 25000.0;
    final weekEarnings = 120000.0;
    final monthEarnings = 450000.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.successColor.withOpacity(0.1),
                AppTheme.accentColor.withOpacity(0.1),
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.account_balance_wallet,
                    color: AppTheme.successColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Earnings Summary',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimaryColor,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: _buildEarningsItem(
                      title: 'Today',
                      amount: todayEarnings,
                      color: AppTheme.successColor,
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: AppTheme.textTertiaryColor,
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  Expanded(
                    child: _buildEarningsItem(
                      title: 'This Week',
                      amount: weekEarnings,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: AppTheme.textTertiaryColor,
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  Expanded(
                    child: _buildEarningsItem(
                      title: 'This Month',
                      amount: monthEarnings,
                      color: AppTheme.accentColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEarningsItem({
    required String title,
    required double amount,
    required Color color,
  }) {
    final formatter = NumberFormat('#,###');

    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: AppTheme.textSecondaryColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'TZS ${formatter.format(amount)}',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
