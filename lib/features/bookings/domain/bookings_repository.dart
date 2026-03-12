import 'booking_entry.dart';

abstract class BookingsRepository {
  Future<List<BookingEntry>> fetchByStatus(BookingStatus status);
  Future<void> addBooking(BookingEntry booking);
}
