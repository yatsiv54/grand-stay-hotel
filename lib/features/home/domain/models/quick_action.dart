import 'package:flutter/material.dart';

class QuickAction {
  QuickAction({
    required this.id,
    required this.title,
    required this.icon,
    required this.primaryColor,
    required this.secondaryColor,
  });

  final String id;
  final String title;
  final String icon;
  final Color primaryColor;
  final Color secondaryColor;

  factory QuickAction.fromMap(Map<String, dynamic> map) {
    return QuickAction(
      id: map['id'] as String,
      title: map['title'] as String,
      icon: _iconFrom(map['icon'] as String? ?? 'info'),
      primaryColor: _colorFrom(map['primary'] as String? ?? '#D72F32'),
      secondaryColor: _colorFrom(map['secondary'] as String? ?? '#B30F14'),
    );
  }
}

String _iconFrom(String value) {
  switch (value) {
    case 'rooms':
      return 'assets/images/home/rooms.png';
    case 'entertainment':
      return 'assets/images/home/entertaiment.png';
    case 'dining':
      return 'assets/images/home/dining.png';
    case 'offers':
      return 'assets/images/home/offers.png';
    default:
      return '';
  }
}

Color _colorFrom(String hex) {
  final sanitized = hex.replaceFirst('#', '');
  return Color(int.parse('FF$sanitized', radix: 16));
}
