import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'core/theme/app_theme.dart';
import 'features/home/presentation/widgets/bottom_nav_bar.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell>
    with SingleTickerProviderStateMixin {
  int _lastIndex = 0;
  late final AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 240),
    );
    _slideAnimation = Tween<Offset>(begin: Offset.zero, end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  void _animateDirection(int newIndex, int oldIndex) {
    final begin = Offset(newIndex >= oldIndex ? 0.1 : -0.1, 0);
    _slideAnimation = Tween<Offset>(begin: begin, end: Offset.zero).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );
    _slideController
      ..reset()
      ..forward();
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = widget.navigationShell.currentIndex;

    return SafeArea(
      child: Scaffold(
        appBar: _buildAppBarForIndex(currentIndex),
        body: SlideTransition(
          position: _slideAnimation,
          child: widget.navigationShell,
        ),
        bottomNavigationBar: HomeBottomNavBar(
          currentIndex: currentIndex,
          onTap: (value) {
            if (value == currentIndex) return;
            _animateDirection(value, currentIndex);
            setState(() => _lastIndex = currentIndex);
            widget.navigationShell.goBranch(
              value,
              initialLocation: value == currentIndex,
            );
          },
        ),
      ),
    );
  }

  PreferredSizeWidget? _buildAppBarForIndex(int index) {
    switch (index) {
      case 0:
        return AppBar(
          surfaceTintColor: Colors.white,
          toolbarHeight: 70,
          titleSpacing: 24,
          backgroundColor: Colors.white,
          shadowColor: Colors.black,
          elevation: 5,
          title: SizedBox(
            width: 170,
            child: Image.asset('assets/images/icons/logo.png'),
          ),
        );
      case 1:
        return AppBar(
          surfaceTintColor: Colors.white,
          toolbarHeight: 70,
          title: Text(
            'My Bookings',
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),

          shadowColor: Colors.black,
          elevation: 5,
          backgroundColor: Colors.white,
          foregroundColor: AppTheme.textPrimary,
        );
      case 3:
        return AppBar(
          surfaceTintColor: Colors.white,
          toolbarHeight: 70,
          title: Text(
            'Support',
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
          shadowColor: Colors.black,
          elevation: 5,
          backgroundColor: Colors.white,
          foregroundColor: AppTheme.textPrimary,
        );
      case 2:
        return null;
      default:
        return AppBar(
          surfaceTintColor: Colors.white,
          toolbarHeight: 70,
          shadowColor: Colors.black,
          elevation: 5,
          backgroundColor: Colors.white,
          foregroundColor: AppTheme.textPrimary,
          title: const SizedBox(),
        );
    }
  }
}

class _BrandHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: const [
            Icon(Icons.star_rate_rounded, color: AppTheme.primaryRed, size: 28),
            Positioned(
              left: 10,
              child: Icon(
                Icons.flight_takeoff_rounded,
                color: AppTheme.primaryRedDark,
                size: 18,
              ),
            ),
          ],
        ),
        const SizedBox(width: 8),
        Text(
          'GrandStay',
          style: theme.textTheme.headlineMedium?.copyWith(
            color: AppTheme.textPrimary,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }
}

class _ProfileChip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.person_outline, color: Colors.grey.shade700),
          const SizedBox(width: 6),
          Text('Guest', style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}
