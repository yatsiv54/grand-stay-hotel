import 'package:bloc/bloc.dart';
import '../domain/booking_entry.dart';
import '../domain/bookings_repository.dart';

class BookingState {
  BookingState({
    required this.loading,
    required this.active,
    required this.history,
    required this.tab,
  });

  final bool loading;
  final List<BookingEntry> active;
  final List<BookingEntry> history;
  final BookingStatus tab;

  BookingState copyWith({
    bool? loading,
    List<BookingEntry>? active,
    List<BookingEntry>? history,
    BookingStatus? tab,
  }) {
    return BookingState(
      loading: loading ?? this.loading,
      active: active ?? this.active,
      history: history ?? this.history,
      tab: tab ?? this.tab,
    );
  }

  static BookingState initial() => BookingState(
    loading: true,
    active: const [],
    history: const [],
    tab: BookingStatus.active,
  );
}

class BookingCubit extends Cubit<BookingState> {
  BookingCubit(this._repo) : super(BookingState.initial());

  final BookingsRepository _repo;

  Future<void> loadAll() async {
    emit(state.copyWith(loading: true));
    final active = await _repo.fetchByStatus(BookingStatus.active);
    final history = await _repo.fetchByStatus(BookingStatus.history);
    emit(state.copyWith(loading: false, active: active, history: history));
  }

  Future<void> setTab(BookingStatus tab) async {
    emit(state.copyWith(tab: tab));
    if (state.active.isEmpty && tab == BookingStatus.active) {
      await loadAll();
    }
    if (state.history.isEmpty && tab == BookingStatus.history) {
      await loadAll();
    }
  }
}
