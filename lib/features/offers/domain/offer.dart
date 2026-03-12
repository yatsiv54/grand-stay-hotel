class Offer {
  Offer({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.validUntil,
    required this.validUntilDate,
    required this.validWeekdays,
    required this.tag,
    required this.image,
    required this.priceLabel,
    required this.description,
    required this.terms,
    this.hint,
  });

  final String id;
  final String title;
  final String subtitle;
  final String validUntil;
  final DateTime? validUntilDate;
  final List<int> validWeekdays; // 1 (Mon) .. 7 (Sun)
  final String tag;
  final String image;
  final String priceLabel;
  final String description;
  final List<String> terms;
  final String? hint;

  factory Offer.fromMap(Map<String, dynamic> map) {
    return Offer(
      id: map['id'] as String,
      title: map['title'] as String,
      subtitle: map['subtitle'] as String? ?? '',
      validUntil: map['validUntil'] as String? ?? '',
      validUntilDate: map['validUntilDate'] != null
          ? DateTime.tryParse(map['validUntilDate'] as String)
          : null,
      validWeekdays: _parseWeekdays(map['validWeekdays']),
      tag: map['tag'] as String? ?? '',
      image: map['image'] as String,
      priceLabel: map['priceLabel'] as String? ?? '',
      description: map['description'] as String? ?? '',
      terms: map['terms'] != null
          ? List<String>.from(map['terms'] as List<dynamic>)
          : const [],
      hint: map['hint'] as String?,
    );
  }
}

List<int> _parseWeekdays(dynamic value) {
  if (value == null) return const [];
  final list = List<String>.from(value as List<dynamic>);
  return list
      .map((e) => e.toLowerCase().trim())
      .map((day) {
        switch (day) {
          case 'mon':
          case 'monday':
            return DateTime.monday;
          case 'tue':
          case 'tuesday':
            return DateTime.tuesday;
          case 'wed':
          case 'wednesday':
            return DateTime.wednesday;
          case 'thu':
          case 'thursday':
            return DateTime.thursday;
          case 'fri':
          case 'friday':
            return DateTime.friday;
          case 'sat':
          case 'saturday':
            return DateTime.saturday;
          case 'sun':
          case 'sunday':
            return DateTime.sunday;
          default:
            return -1;
        }
      })
      .where((e) => e >= DateTime.monday && e <= DateTime.sunday)
      .toList();
}
