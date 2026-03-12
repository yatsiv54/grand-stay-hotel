import 'package:get_it/get_it.dart';

import 'features/bookings/data/prefs_bookings_repository.dart';
import 'features/bookings/domain/bookings_repository.dart';
import 'features/bookings/presentation/booking_cubit.dart';
import 'features/entertainment/data/entertainment_repository.dart';
import 'features/rooms/data/rooms_local_repository.dart';
import 'features/rooms/domain/rooms_repository.dart';
import 'features/dining/data/dining_repository.dart';
import 'features/offers/data/offers_repository.dart';

final GetIt getIt = GetIt.instance;

Future<void> registerDependencies() async {
  // Repositories
  getIt.registerLazySingleton<BookingsRepository>(
    () => PrefsBookingsRepository(),
  );
  getIt.registerLazySingleton<RoomsRepository>(
    () => const RoomsLocalRepository(),
  );
  getIt.registerLazySingleton<EntertainmentRepository>(
    () => EntertainmentRepository(),
  );
  getIt.registerLazySingleton<BookingCubit>(
    () => BookingCubit(getIt<BookingsRepository>()),
  );
  getIt.registerLazySingleton<DiningRepository>(() => DiningRepository());
  getIt.registerLazySingleton<OffersRepository>(() => OffersRepository());
}
