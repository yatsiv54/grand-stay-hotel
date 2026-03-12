import 'dart:convert';

enum BookingCategory { rooms, deals, activities, dining }

enum BookingStatus { active, history }

enum BookingCta { qr, arrow }

class BookingEntry {
  BookingEntry({
    required this.id,
    required this.title,
    required this.category,
    required this.status,
    required this.assetPlaceholder,
    this.contactName,
    this.contactPhone,
    this.roomNumber,
    this.preferences = const [],
    this.checkInDate,
    this.checkOutDate,
    this.date,
    this.time,
    this.adults,
    this.children,
    this.table,
    this.detailPrimary,
    this.detailSecondary,
    this.guests,
    this.cta = BookingCta.qr,
    this.eventDate,
    this.hint,
  });

  final String id;
  final String title;
  final BookingCategory category;
  final BookingStatus status;
  final String assetPlaceholder;
  final String? contactName;
  final String? contactPhone;
  final String? roomNumber;
  final List<String> preferences;
  final String? checkInDate;
  final String? checkOutDate;
  final String? date;
  final String? time;
  final int? adults;
  final int? children;
  final String? table;
  final String? detailPrimary;
  final String? detailSecondary;
  final String? guests;
  final BookingCta cta;
  final DateTime? eventDate;
  final String? hint;

  BookingEntry copyWith({
    String? id,
    String? title,
    BookingCategory? category,
    BookingStatus? status,
    String? assetPlaceholder,
    String? contactName,
    String? contactPhone,
    String? roomNumber,
    List<String>? preferences,
    String? checkInDate,
    String? checkOutDate,
    String? date,
    String? time,
    int? adults,
    int? children,
    String? table,
    String? detailPrimary,
    String? detailSecondary,
    String? guests,
    BookingCta? cta,
    DateTime? eventDate,
    String? hint,
  }) {
    return BookingEntry(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      status: status ?? this.status,
      assetPlaceholder: assetPlaceholder ?? this.assetPlaceholder,
      contactName: contactName ?? this.contactName,
      contactPhone: contactPhone ?? this.contactPhone,
      roomNumber: roomNumber ?? this.roomNumber,
      preferences: preferences ?? this.preferences,
      checkInDate: checkInDate ?? this.checkInDate,
      checkOutDate: checkOutDate ?? this.checkOutDate,
      date: date ?? this.date,
      time: time ?? this.time,
      adults: adults ?? this.adults,
      children: children ?? this.children,
      table: table ?? this.table,
      detailPrimary: detailPrimary ?? this.detailPrimary,
      detailSecondary: detailSecondary ?? this.detailSecondary,
      guests: guests ?? this.guests,
      cta: cta ?? this.cta,
      eventDate: eventDate ?? this.eventDate,
      hint: hint ?? this.hint,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'category': category.name,
      'status': status.name,
      'assetPlaceholder': assetPlaceholder,
      'contactName': contactName,
      'contactPhone': contactPhone,
      'roomNumber': roomNumber,
      'preferences': preferences,
      'checkInDate': checkInDate,
      'checkOutDate': checkOutDate,
      'date': date,
      'time': time,
      'adults': adults,
      'children': children,
      'table': table,
      'detailPrimary': detailPrimary,
      'detailSecondary': detailSecondary,
      'guests': guests,
      'cta': cta.name,
      'eventDate': eventDate?.toIso8601String(),
      'hint': hint,
    };
  }

  factory BookingEntry.fromMap(Map<String, dynamic> map) {
    return BookingEntry(
      id: map['id'] as String,
      title: map['title'] as String,
      category: BookingCategory.values.firstWhere(
        (e) => e.name == map['category'],
        orElse: () => BookingCategory.rooms,
      ),
      status: BookingStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => BookingStatus.active,
      ),
      assetPlaceholder: map['assetPlaceholder'] as String,
      contactName: map['contactName'] as String?,
      contactPhone: map['contactPhone'] as String?,
      roomNumber: map['roomNumber'] as String?,
      preferences: _parseList(map['preferences']),
      checkInDate: map['checkInDate'] as String?,
      checkOutDate: map['checkOutDate'] as String?,
      date: map['date'] as String?,
      time: map['time'] as String?,
      adults: (map['adults'] as num?)?.toInt(),
      children: (map['children'] as num?)?.toInt(),
      table: map['table'] as String?,
      detailPrimary: map['detailPrimary'] as String?,
      detailSecondary: map['detailSecondary'] as String?,
      guests: map['guests'] as String?,
      cta: BookingCta.values.firstWhere(
        (e) => e.name == map['cta'],
        orElse: () => BookingCta.qr,
      ),
      eventDate: map['eventDate'] != null
          ? DateTime.tryParse(map['eventDate'] as String)
          : null,
      hint: map['hint'] as String?,
    );
  }
}

List<String> _parseList(dynamic value) {
  if (value == null) return const [];
  if (value is List) return List<String>.from(value);
  if (value is String) {
    try {
      return List<String>.from(jsonDecode(value) as List<dynamic>);
    } catch (_) {
      return value
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }
  }
  return const [];
}
