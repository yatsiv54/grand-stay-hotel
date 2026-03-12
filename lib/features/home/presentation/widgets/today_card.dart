import 'package:flutter/material.dart';

import '../../domain/models/booking.dart';

class TodayCard extends StatelessWidget {
  const TodayCard({super.key, required this.booking});

  final Booking booking;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Color.fromRGBO(83, 177, 87, 1), blurRadius: 1),
        ],
        border: Border.all(color: Color.fromRGBO(83, 177, 87, 1), width: 0.4),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Next booking',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade600,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              booking.title,
              style: theme.textTheme.titleSmall?.copyWith(
                color: Colors.black,
                fontSize: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
