import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../di.dart';
import '../../bookings/data/prefs_bookings_repository.dart';
import '../../bookings/domain/booking_entry.dart' as domain_booking;
import '../../bookings/presentation/booking_cubit.dart';
import '../../entertainment/data/entertainment_repository.dart';
import '../../entertainment/domain/entertainment_item.dart';
import '../../offers/data/offers_repository.dart';
import '../../offers/domain/offer.dart';
import '../data/home_content_repository.dart';
import '../domain/models/home_content.dart';
import '../domain/models/booking.dart';
import 'widgets/highlight_carousel.dart';
import 'widgets/map_card.dart';
import 'widgets/quick_action_grid.dart';
import 'widgets/today_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static final _repo = HomeContentRepository();
  static final _bookingsRepo = PrefsBookingsRepository();
  static final _entRepo = EntertainmentRepository();
  static final _offersRepo = OffersRepository();

  late Future<_HomeData> _dataFuture;
  StreamSubscription<BookingState>? _bookingSub;

  @override
  void initState() {
    super.initState();
    _dataFuture = _load();
    _bookingSub = getIt<BookingCubit>().stream.listen((_) {
      if (!mounted) return;
      setState(() {
        _dataFuture = _load();
      });
    });
  }

  @override
  void dispose() {
    _bookingSub?.cancel();
    super.dispose();
  }

  static Future<_HomeData> _load() async {
    final content = await _repo.load();
    final active = await _bookingsRepo.fetchByStatus(
      domain_booking.BookingStatus.active,
    );
    final entertainments = await _entRepo.fetchItems();
    final offers = await _offersRepo.fetchOffers();

    final nextBooking = _computeNextBooking(
      active: active,
      entertainments: entertainments,
      fallback: content.todayBooking,
    );

    return _HomeData(
      content: content,
      nextBooking: nextBooking,
      offers: offers,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FutureBuilder<_HomeData>(
      future: _dataFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final data = snapshot.data!;
        return Scaffold(
          backgroundColor: AppTheme.surface,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  HighlightCarousel(
                    highlights: data.content.highlights,
                    onTap: (highlight) {
                      final matches = data.offers.where(
                        (o) => o.id == highlight.id,
                      );
                      if (matches.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Offer not found')),
                        );
                        return;
                      }
                      context.push('/offers/detail', extra: matches.first);
                    },
                  ),
                  const SizedBox(height: 40),
                  QuickActionGrid(
                    actions: data.content.quickActions,
                    onTap: (action) {
                      switch (action.id) {
                        case 'rooms':
                          context.push('/rooms');
                          break;
                        case 'entertainment':
                          context.push('/entertainment');
                          break;
                        case 'dining':
                          context.push('/dining');
                          break;
                        case 'offers':
                          context.push('/offers');
                          break;
                        default:
                          break;
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  const MapCard(),
                  const SizedBox(height: 40),
                  Text(
                    'Today at Fortuna',
                    style: theme.textTheme.titleLarge!.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TodayCard(booking: data.nextBooking),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _HomeData {
  _HomeData({
    required this.content,
    required this.nextBooking,
    required this.offers,
  });

  final HomeContent content;
  final Booking nextBooking;
  final List<Offer> offers;
}

Booking _mapEntryToBooking(domain_booking.BookingEntry entry, DateTime? at) {
  final status = entry.status == domain_booking.BookingStatus.active
      ? BookingStatus.upcoming
      : BookingStatus.past;
  final label = entry.time?.isNotEmpty == true
      ? entry.time!
      : (entry.date?.isNotEmpty == true ? entry.date! : 'Next booking');
  return Booking(
    id: entry.id,
    title: entry.title,
    timeLabel: label,
    status: status,
  );
}

Booking _mapEntertainmentToBooking(EntertainmentItem item, DateTime when) {
  return Booking(
    id: item.id,
    title: item.title,
    timeLabel: item.when.isNotEmpty ? item.when : 'Next event',
    status: BookingStatus.upcoming,
  );
}

Booking _computeNextBooking({
  required List<domain_booking.BookingEntry> active,
  required List<EntertainmentItem> entertainments,
  required Booking fallback,
}) {
  final now = DateTime.now();
  final bookingCandidates = <_BookingCandidate>[];
  final entertainmentCandidates = <_BookingCandidate>[];

  for (final b in active) {
    final dt = b.eventDate;
    if (dt == null) continue;
    if (dt.isBefore(now)) continue;
    bookingCandidates.add(
      _BookingCandidate(when: dt, booking: _mapEntryToBooking(b, dt)),
    );
  }

  for (final e in entertainments) {
    final dt = _nextEntertainmentDate(e, now);
    if (dt == null) continue;
    entertainmentCandidates.add(
      _BookingCandidate(when: dt, booking: _mapEntertainmentToBooking(e, dt)),
    );
  }

  if (bookingCandidates.isNotEmpty) {
    bookingCandidates.sort((a, b) => a.when.compareTo(b.when));
    return bookingCandidates.first.booking;
  }

  if (entertainmentCandidates.isNotEmpty) {
    entertainmentCandidates.sort((a, b) => a.when.compareTo(b.when));
    return entertainmentCandidates.first.booking;
  }

  return fallback;
}

DateTime? _nextEntertainmentDate(EntertainmentItem item, DateTime now) {
  DateTime? base = item.eventDate;
  if (base == null) return null;
  if (base.isAfter(now)) return base;

  final when = item.when.toLowerCase();
  if (when.contains('daily')) {
    while (base != null && base.isBefore(now)) {
      base = base.add(const Duration(days: 1));
    }
    return base;
  }

  int? targetWeekday;
  if (when.contains('monday')) targetWeekday = DateTime.monday;
  if (when.contains('tuesday')) targetWeekday = DateTime.tuesday;
  if (when.contains('wednesday')) targetWeekday = DateTime.wednesday;
  if (when.contains('thursday')) targetWeekday = DateTime.thursday;
  if (when.contains('friday')) targetWeekday = DateTime.friday;
  if (when.contains('saturday')) targetWeekday = DateTime.saturday;
  if (when.contains('sunday')) targetWeekday = DateTime.sunday;

  if (when.contains('every') && targetWeekday != null) {
    DateTime candidate = DateTime(
      now.year,
      now.month,
      now.day,
      base.hour,
      base.minute,
    );
    while (candidate.weekday != targetWeekday || candidate.isBefore(now)) {
      candidate = candidate.add(const Duration(days: 1));
    }
    return candidate;
  }

  return null;
}

class _BookingCandidate {
  _BookingCandidate({required this.when, required this.booking});
  final DateTime when;
  final Booking booking;
}
