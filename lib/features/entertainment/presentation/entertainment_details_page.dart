import 'package:flutter/material.dart';

import '../../bookings/domain/booking_entry.dart';
import '../../bookings/domain/bookings_repository.dart';
import '../../bookings/presentation/booking_cubit.dart';
import '../../../di.dart';
import '../domain/entertainment_item.dart';

class EntertainmentDetailsPage extends StatelessWidget {
  const EntertainmentDetailsPage({super.key, required this.item});
  final EntertainmentItem item;

  String? _formatTime(DateTime? dt) {
    if (dt == null) return null;
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            ListView(
              padding: EdgeInsets.zero,
              children: [
                Stack(
                  children: [
                    SizedBox(
                      height: 230,
                      width: double.infinity,
                      child: Image.asset(item.imageAsset, fit: BoxFit.cover),
                    ),
                    Positioned(
                      top: 12,
                      left: 12,
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        child: IconButton(
                          icon: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: Colors.black,
                            size: 20,
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),
                    ),
                  ],
                ),
                Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        item.description,
                        style: theme.textTheme.bodyMedium!.copyWith(
                          color: Colors.black,
                          fontSize: 16,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _InfoBlock(item: item),
                      const SizedBox(height: 16),
                      Text(
                        'Entry & price',
                        style: theme.textTheme.titleLarge!.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(item.entryPrice, style: theme.textTheme.bodyMedium),
                      const SizedBox(height: 14),
                      Text(
                        'Extras',
                        style: theme.textTheme.titleLarge!.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      ...item.extras.map(
                        (e) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(e, style: theme.textTheme.bodyMedium),
                        ),
                      ),
                      const SizedBox(height: 40),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 0,
                          vertical: 0,
                        ),
                        color: Colors.white,
                        child: SafeArea(
                          top: false,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.green,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(32),
                              ),
                            ),
                            onPressed: () async {
                              final repo = getIt<BookingsRepository>();
                              final booking = BookingEntry(
                                id: 'ent_${item.id}_${DateTime.now().millisecondsSinceEpoch}',
                                title: item.title,
                                category: BookingCategory.activities,
                                status: BookingStatus.active,
                                assetPlaceholder: item.imageAsset,
                                contactName: null,
                                contactPhone: null,
                                date: item.eventDate
                                    ?.toIso8601String()
                                    .split('T')
                                    .first,
                                time: _formatTime(item.eventDate),
                                detailPrimary: item.when,
                                detailSecondary:
                                    'Duration: ${item.durationMinutes} min',
                                cta: BookingCta.qr,
                                hint: item.hint,
                                eventDate: item.eventDate,
                              );
                              await repo.addBooking(booking);
                              await getIt<BookingCubit>().loadAll();
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Added to My Bookings'),
                                  ),
                                );
                              }
                            },
                            child: Text(
                              'Add to my schedule',
                              style: theme.textTheme.titleLarge!.copyWith(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoBlock extends StatelessWidget {
  const _InfoBlock({required this.item});
  final EntertainmentItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _InfoTile(title: 'Location', value: item.location),

          _InfoTile(title: 'When', value: item.when),

          _InfoTile(
            title: 'Duration',
            value: '${item.durationMinutes} minutes',
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.title, required this.value});
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 100,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              color: Color.fromRGBO(83, 177, 87, 1),
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.bodyMedium!.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
