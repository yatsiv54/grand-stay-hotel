import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/booking_entry.dart';
import '../domain/bookings_repository.dart';

class PrefsBookingsRepository implements BookingsRepository {
  // bumped to v5 to drop legacy records without full booking details
  static const _storageKey = 'bookings_v5';

  @override
  Future<List<BookingEntry>> fetchByStatus(BookingStatus status) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    final baseList = raw == null ? await _loadSeed() : _deserialize(raw);

    final now = DateTime.now();
    List<BookingEntry> computed = baseList.map((entry) {
      final ev = entry.eventDate;
      final computedStatus = _computeStatus(ev, now, entry.status);
      return entry.copyWith(status: computedStatus);
    }).toList();

    computed = computed.where((e) => e.status == status).toList()
      ..sort((a, b) {
        final ad = a.eventDate ?? now;
        final bd = b.eventDate ?? now;
        return ad.compareTo(bd);
      });

    if (raw == null) {
      await _saveAll(baseList);
    }
    return computed;
  }

  @override
  Future<void> addBooking(BookingEntry booking) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    final list = raw == null ? await _loadSeed() : _deserialize(raw);
    list.insert(0, booking);
    await _saveAll(list);
  }

  Future<void> _saveAll(List<BookingEntry> list) async {
    final prefs = await SharedPreferences.getInstance();
    final serialized = jsonEncode(list.map((e) => e.toMap()).toList());
    await prefs.setString(_storageKey, serialized);
  }

  Future<List<BookingEntry>> _loadSeed() async {
    final data = await rootBundle.loadString('assets/data/bookings_seed.json');
    return (jsonDecode(data) as List<dynamic>)
        .map((e) => BookingEntry.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  List<BookingEntry> _deserialize(String raw) {
    final decoded = jsonDecode(raw) as List<dynamic>;
    final Map<String, BookingEntry> unique = {};
    for (final e in decoded) {
      final item = BookingEntry.fromMap(Map<String, dynamic>.from(e as Map));
      unique[item.id] = item;
    }
    return unique.values.toList();
  }

  BookingStatus _computeStatus(
    DateTime? eventDate,
    DateTime now,
    BookingStatus fallback,
  ) {
    if (eventDate == null) return fallback;
    final today = DateTime(now.year, now.month, now.day);
    final eventDay = DateTime(eventDate.year, eventDate.month, eventDate.day);
    if (eventDay.isBefore(today)) return BookingStatus.history;
    return BookingStatus.active;
  }
}
