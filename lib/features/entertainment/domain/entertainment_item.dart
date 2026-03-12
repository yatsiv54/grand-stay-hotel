import 'package:flutter/material.dart';

enum EntertainmentCategory {
  liveShows,
  poolSpa,
  fitnessGym,
  outdoorAdventures,
  workshopsClasses,
}

EntertainmentCategory categoryFromString(String value) {
  switch (value) {
    case 'pool_spa':
      return EntertainmentCategory.poolSpa;
    case 'fitness_gym':
      return EntertainmentCategory.fitnessGym;
    case 'outdoor_adventures':
      return EntertainmentCategory.outdoorAdventures;
    case 'workshops_classes':
      return EntertainmentCategory.workshopsClasses;
    case 'live_shows':
    default:
      return EntertainmentCategory.liveShows;
  }
}

class EntertainmentItem {
  EntertainmentItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.location,
    required this.when,
    required this.durationMinutes,
    required this.entryPrice,
    required this.extras,
    required this.imageAsset,
    required this.category,
    this.tag,
    this.eventDate,
    this.hint,
  });

  final String id;
  final String title;
  final String subtitle;
  final String description;
  final String location;
  final String when;
  final int durationMinutes;
  final String entryPrice;
  final List<String> extras;
  final String imageAsset;
  final EntertainmentCategory category;
  final String? tag;
  final DateTime? eventDate;
  final String? hint;

  factory EntertainmentItem.fromMap(Map<String, dynamic> map) {
    return EntertainmentItem(
      id: map['id'] as String,
      title: map['title'] as String,
      subtitle: map['subtitle'] as String? ?? '',
      description: map['description'] as String? ?? '',
      location: map['location'] as String? ?? '',
      when: map['when'] as String? ?? '',
      durationMinutes: (map['durationMinutes'] as num?)?.toInt() ?? 0,
      entryPrice: map['entryPrice'] as String? ?? '',
      extras: map['extras'] != null
          ? List<String>.from(map['extras'] as List<dynamic>)
          : const [],
      imageAsset: map['image'] as String,
      category: categoryFromString(map['category'] as String? ?? 'live_shows'),
      tag: map['tag'] as String?,
      eventDate: map['eventDate'] != null
          ? DateTime.tryParse(map['eventDate'] as String)
          : null,
      hint: map['hint'] as String?,
    );
  }
}
