import 'dart:convert';

import 'package:flutter/services.dart';

import '../domain/dining_item.dart';

class DiningRepository {
  Future<List<DiningItem>> fetchItems() async {
    final jsonStr = await rootBundle.loadString('assets/data/dining.json');
    final list = jsonDecode(jsonStr) as List<dynamic>;
    return list
        .map((e) => DiningItem.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList();
  }
}
