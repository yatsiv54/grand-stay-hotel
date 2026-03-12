class Booking {
  Booking({
    required this.id,
    required this.title,
    required this.timeLabel,
    required this.status,
  });

  final String id;
  final String title;
  final String timeLabel;
  final BookingStatus status;

  factory Booking.fromMap(Map<String, dynamic> map) {
    return Booking(
      id: map['id'] as String,
      title: map['title'] as String? ?? '',
      timeLabel: map['timeLabel'] as String? ?? '',
      status: _statusFrom(map['status'] as String? ?? 'upcoming'),
    );
  }
}

enum BookingStatus { upcoming, past, canceled }

BookingStatus _statusFrom(String value) {
  switch (value) {
    case 'past':
      return BookingStatus.past;
    case 'canceled':
      return BookingStatus.canceled;
    case 'upcoming':
    default:
      return BookingStatus.upcoming;
  }
}
