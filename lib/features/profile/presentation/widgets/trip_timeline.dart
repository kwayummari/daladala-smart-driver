// lib/features/trip/presentation/widgets/trip_timeline.dart
import 'package:daladala_smart_driver/features/trip/domain/entities/trip.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';

class TripTimeline extends StatelessWidget {
  final Trip trip;

  const TripTimeline({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    final events = _buildTimelineEvents();

    return Column(
      children: [
        for (int i = 0; i < events.length; i++) ...[
          _buildTimelineItem(event: events[i], isLast: i == events.length - 1),
        ],
      ],
    );
  }

  List<TimelineEvent> _buildTimelineEvents() {
    final events = <TimelineEvent>[];

    // Trip Created
    events.add(
      TimelineEvent(
        title: 'Trip Created',
        time: trip.createdAt,
        icon: Icons.add_circle,
        color: AppTheme.primaryColor,
        description: 'Trip was scheduled',
      ),
    );

    // Trip Started
    if (trip.actualStartTime != null) {
      events.add(
        TimelineEvent(
          title: 'Trip Started',
          time: trip.actualStartTime!,
          icon: Icons.play_arrow,
          color: AppTheme.successColor,
          description: 'Driver started the trip',
        ),
      );
    }

    // Trip Completed
    if (trip.actualEndTime != null) {
      events.add(
        TimelineEvent(
          title: 'Trip Completed',
          time: trip.actualEndTime!,
          icon: Icons.check_circle,
          color: AppTheme.completedColor,
          description: 'Trip was completed successfully',
        ),
      );
    }

    return events;
  }

  Widget _buildTimelineItem({
    required TimelineEvent event,
    required bool isLast,
  }) {
    final timeFormatter = DateFormat('HH:mm');

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline indicator
        Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: event.color.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(color: event.color, width: 2),
              ),
              child: Icon(event.icon, size: 20, color: event.color),
            ),
            if (!isLast) ...[
              Container(
                width: 2,
                height: 40,
                color: event.color.withOpacity(0.3),
              ),
            ],
          ],
        ),

        const SizedBox(width: 16),

        // Event details
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  event.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  timeFormatter.format(event.time),
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textTertiaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class TimelineEvent {
  final String title;
  final DateTime time;
  final IconData icon;
  final Color color;
  final String description;

  TimelineEvent({
    required this.title,
    required this.time,
    required this.icon,
    required this.color,
    required this.description,
  });
}
