import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'app_shell.dart';
import 'features/bookings/presentation/my_bookings_page.dart';
import 'features/home/presentation/home_page.dart';
import 'features/rooms/presentation/rooms_page.dart';
import 'features/rooms/presentation/reservation_page.dart';
import 'features/rooms/presentation/room_details_page.dart';
import 'features/entertainment/presentation/entertainment_page.dart';
import 'features/entertainment/presentation/entertainment_details_page.dart';
import 'features/dining/presentation/dining_page.dart';
import 'features/dining/presentation/dining_details_page.dart';
import 'features/dining/presentation/dining_reservation_page.dart';
import 'features/support/presentation/support_page.dart';
import 'features/rooms/domain/room.dart';
import 'features/dining/domain/dining_item.dart';
import 'features/entertainment/domain/entertainment_item.dart';
import 'features/offers/domain/offer.dart';
import 'features/offers/presentation/offers_page.dart';
import 'features/offers/presentation/offers_detail_page.dart';
import 'features/offers/presentation/offer_reservation_page.dart';
import 'features/bookings/presentation/qr_page.dart';
import 'features/map_navigation/presentation/map_navigation_page.dart';
import 'features/bookings/presentation/qr_tab_page.dart';
import 'features/splash/presentation/splash_page.dart';
import 'features/onboard/presentation/onboard_page.dart';

class AppRouter {
  AppRouter();

  final _rootNavigatorKey = GlobalKey<NavigatorState>();
  final _shellNavigatorKey = GlobalKey<NavigatorState>();

  late final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    routes: [
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/onboard',
        name: 'onboard',
        builder: (context, state) => const OnboardPage(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashPage(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            navigatorKey: _shellNavigatorKey,
            routes: [
              GoRoute(
                path: '/home',
                name: 'home',
                builder: (context, state) => const HomePage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/bookings',
                name: 'bookings',
                builder: (context, state) => const MyBookingsPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/qr',
                name: 'qr',
                builder: (context, state) => const QrTabPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/support',
                name: 'support',
                builder: (context, state) => const SupportPage(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/rooms',
        name: 'rooms',
        builder: (context, state) => const RoomsPage(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/room',
        name: 'room',
        builder: (context, state) {
          final room = state.extra as dynamic;
          if (room is Room) {
            return RoomDetailsPage(room: room);
          }
          return const Scaffold(body: Center(child: Text('Room not found')));
        },
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/reservation',
        name: 'reservation',
        builder: (context, state) {
          final room = state.extra as dynamic;
          if (room is Room) {
            return ReservationPage(room: room);
          }
          return const Scaffold(body: Center(child: Text('Room not found')));
        },
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/dining',
        name: 'dining',
        builder: (context, state) => const DiningPage(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/dining/detail',
        name: 'diningDetail',
        builder: (context, state) {
          final item = state.extra as dynamic;
          if (item is DiningItem) {
            return DiningDetailsPage(item: item);
          }
          return const Scaffold(body: Center(child: Text('Dining not found')));
        },
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/dining/reservation',
        name: 'diningReservation',
        builder: (context, state) {
          final item = state.extra as dynamic;
          if (item is DiningItem) {
            return DiningReservationPage(item: item);
          }
          return const Scaffold(body: Center(child: Text('Dining not found')));
        },
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/entertainment',
        name: 'entertainment',
        builder: (context, state) => const EntertainmentPage(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/entertainment/detail',
        name: 'entertainmentDetail',
        builder: (context, state) {
          final item = state.extra as dynamic;
          if (item is EntertainmentItem) {
            return EntertainmentDetailsPage(item: item);
          }
          return const Scaffold(body: Center(child: Text('Item not found')));
        },
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/offers',
        name: 'offers',
        builder: (context, state) => const OffersPage(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/offers/detail',
        name: 'offersDetail',
        builder: (context, state) {
          final offer = state.extra as dynamic;
          if (offer is Offer) {
            return OffersDetailPage(offer: offer);
          }
          return const Scaffold(body: Center(child: Text('Offer not found')));
        },
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/offers/reservation',
        name: 'offersReservation',
        builder: (context, state) {
          final offer = state.extra as dynamic;
          if (offer is Offer) {
            return OfferReservationPage(offer: offer);
          }
          return const Scaffold(body: Center(child: Text('Offer not found')));
        },
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/qr/show',
        name: 'qrShow',
        builder: (context, state) {
          final info = state.extra;
          if (info is QrInfo) {
            return QrPage(info: info);
          }
          return const Scaffold(body: Center(child: Text('QR info missing')));
        },
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/map',
        name: 'map',
        builder: (context, state) => const MapNavigationPage(),
      ),
    ],
  );
}

class _PlaceholderPage extends StatelessWidget {
  const _PlaceholderPage({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Center(child: Text(title, style: theme.textTheme.headlineSmall)),
    );
  }
}
