import 'dart:convert';

import 'package:flutter/services.dart';

import '../domain/offer.dart';

class OffersRepository {
  Future<List<Offer>> fetchOffers() async {
    final jsonStr = await rootBundle.loadString('assets/data/offers.json');
    final list = jsonDecode(jsonStr) as List<dynamic>;
    return list.map((e) => Offer.fromMap(Map<String, dynamic>.from(e as Map))).toList();
  }
}
