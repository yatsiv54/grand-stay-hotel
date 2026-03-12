import 'dart:convert';

import 'package:flutter/services.dart';

import '../domain/entertainment_item.dart';

class EntertainmentRepository {
  Future<List<EntertainmentItem>> fetchItems() async {
    final jsonStr = await rootBundle.loadString(
      'assets/data/entertainment.json',
    );
    final list = jsonDecode(jsonStr) as List<dynamic>;
    return list
        .map(
          (e) => EntertainmentItem.fromMap(Map<String, dynamic>.from(e as Map)),
        )
        .toList();
  }
}
