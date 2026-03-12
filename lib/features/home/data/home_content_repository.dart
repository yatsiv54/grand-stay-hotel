import 'dart:convert';

import 'package:flutter/services.dart';

import '../domain/models/booking.dart';
import '../domain/models/highlight.dart';
import '../domain/models/home_content.dart';
import '../domain/models/quick_action.dart';

class HomeContentRepository {
  Future<HomeContent> load() async {
    final raw = await rootBundle.loadString('assets/data/home.json');
    final map = jsonDecode(raw) as Map<String, dynamic>;
    final highlights = (map['highlights'] as List<dynamic>)
        .map((e) => Highlight.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList();
    final actions = (map['quickActions'] as List<dynamic>)
        .map((e) => QuickAction.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList();
    final today =
        Booking.fromMap(Map<String, dynamic>.from(map['todayBooking'] as Map));
    return HomeContent(
      highlights: highlights,
      quickActions: actions,
      todayBooking: today,
    );
  }
}
