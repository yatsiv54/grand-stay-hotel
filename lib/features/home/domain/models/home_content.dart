import 'booking.dart';
import 'highlight.dart';
import 'quick_action.dart';

class HomeContent {
  HomeContent({
    required this.highlights,
    required this.quickActions,
    required this.todayBooking,
  });

  final List<Highlight> highlights;
  final List<QuickAction> quickActions;
  final Booking todayBooking;
}
