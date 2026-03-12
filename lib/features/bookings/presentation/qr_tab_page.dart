import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../di.dart';
import '../domain/booking_entry.dart';
import 'booking_cubit.dart';
import 'qr_page.dart';

class QrTabPage extends StatefulWidget {
  const QrTabPage({super.key});

  @override
  State<QrTabPage> createState() => _QrTabPageState();
}

class _QrTabPageState extends State<QrTabPage> {
  late final BookingCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = getIt<BookingCubit>()..loadAll();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BookingCubit, BookingState>(
      bloc: _cubit,
      builder: (context, state) {
        if (state.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.active.isEmpty) {
          return const Center(
            child: Text('No active bookings yet'),
          );
        }

        final next = state.active.first;
        final info = _toQrInfo(next);
        if (info == null) {
          return const Center(child: Text('QR data unavailable'));
        }
        return QrPage(info: info, embedded: true);
      },
    );
  }
}

QrInfo? _toQrInfo(BookingEntry entry) {
  final guestName = (entry.contactName != null &&
          entry.contactName!.trim().isNotEmpty)
      ? entry.contactName!.trim()
      : 'Guest';
  final phone = (entry.contactPhone != null &&
          entry.contactPhone!.trim().isNotEmpty)
      ? entry.contactPhone!.trim()
      : '-';

  switch (entry.category) {
    case BookingCategory.rooms:
      return RoomQrInfo(
        img: entry.assetPlaceholder,
        subtitle: entry.detailSecondary ?? entry.detailPrimary ?? '',
        name: guestName,
        phoneNumber: phone,
        placeName: entry.title,
        hint: entry.hint ?? _defaultHint(entry.category),
        roomNumber: entry.roomNumber?.trim().isNotEmpty == true
            ? entry.roomNumber!.trim()
            : '',
        quantity: _quantityFrom(entry.guests, entry.adults, entry.children),
        preferences: entry.preferences,
        checkInDate: entry.checkInDate ??
            entry.eventDate?.toIso8601String().split('T').first ??
            _extractDate(entry.detailPrimary) ??
            '-',
        checkOutDate: entry.checkOutDate ??
            _fallbackNextDay(entry) ??
            _extractDate(entry.detailSecondary) ??
            '-',
      );
    case BookingCategory.dining:
      return DiningQrInfo(
        img: entry.assetPlaceholder,
        subtitle: entry.detailSecondary ?? '',
        name: guestName,
        phoneNumber: phone,
        placeName: entry.title,
        hint: entry.hint ?? _defaultHint(entry.category),
        quantity: _quantityFrom(entry.guests, entry.adults, entry.children),
        table: entry.table?.trim().isNotEmpty == true
            ? entry.table!.trim()
            : '',
        date: entry.date ??
            entry.eventDate?.toIso8601String().split('T').first ??
            _extractDate(entry.detailPrimary) ??
            '-',
        time: entry.time ??
            _extractTime(entry.detailPrimary) ??
            _formatTime(entry.eventDate) ??
            '-',
      );
    case BookingCategory.deals:
    case BookingCategory.activities:
      final date = entry.date ??
          entry.eventDate?.toIso8601String().split('T').first ??
          _extractDate(entry.detailPrimary) ??
          '-';
      final time = entry.time ??
          _extractTime(entry.detailPrimary) ??
          _formatTime(entry.eventDate) ??
          '-';
      return OfferQrInfo(
        img: entry.assetPlaceholder,
        subtitle: entry.detailSecondary ?? entry.detailPrimary ?? '',
        name: guestName,
        phoneNumber: phone,
        placeName: entry.title,
        hint: entry.hint ?? _defaultHint(entry.category),
        date: date,
        time: time,
      );
  }
}

List<String> _quantityFrom(String? guests, int? adults, int? children) {
  final parts = <String>[];
  if (adults != null) parts.add('Adults: $adults');
  if (children != null) parts.add('Children: $children');
  if (parts.isNotEmpty) return parts;
  if (guests == null || guests.trim().isEmpty) return const [];
  return guests
      .split(RegExp(r'\s{2,}'))
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .toList();
}

String _defaultHint(BookingCategory category) {
  switch (category) {
    case BookingCategory.rooms:
      return 'Show this code at the reception during check-in';
    case BookingCategory.dining:
      return 'Scan this code at the entrance for quicker check-in';
    case BookingCategory.deals:
    case BookingCategory.activities:
      return 'Show this code at the entrance';
  }
}

String? _extractDate(String? text) {
  if (text == null) return null;
  final match = RegExp(r'\d{4}-\d{2}-\d{2}').firstMatch(text);
  return match?.group(0);
}

String? _extractTime(String? text) {
  if (text == null) return null;
  final match = RegExp(r'\d{1,2}:\d{2}').firstMatch(text);
  return match?.group(0);
}

String? _formatTime(DateTime? dt) {
  if (dt == null) return null;
  final h = dt.hour.toString().padLeft(2, '0');
  final m = dt.minute.toString().padLeft(2, '0');
  return '$h:$m';
}

String? _fallbackNextDay(BookingEntry entry) {
  if (entry.eventDate == null) return null;
  final next = entry.eventDate!.add(const Duration(days: 1));
  return next.toIso8601String().split('T').first;
}
