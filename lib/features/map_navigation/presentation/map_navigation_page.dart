import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../data/map_floor_data.dart';
import '../domain/map_models.dart';
import 'map_navigation_cubit.dart';
import 'widgets/floor_map_card.dart';

class MapNavigationPage extends StatelessWidget {
  const MapNavigationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MapNavigationCubit(),
      child: const _MapNavigationView(),
    );
  }
}

class _MapNavigationView extends StatelessWidget {
  const _MapNavigationView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 3,
        shadowColor: Colors.black,
        leading: backButton(context),
        title: const Text(
          'Map & Navigation',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: BlocBuilder<MapNavigationCubit, MapNavigationState>(
          builder: (context, state) {
            final cubit = context.read<MapNavigationCubit>();
            final from = locationById(state.fromId);
            final to = locationById(state.toId);
            final routes = state.showRoute
                ? _buildRoutes(state)
                : <_FloorRoute>[];
            final hasSelection = state.fromId != null && state.toId != null;

            final selectedPlan = planForLevel(state.floor);
            final selectedInRoutes = routes.any(
              (r) => r.plan.level == selectedPlan.level,
            );

            final cards = <_FloorRoute>[];

            if (!selectedInRoutes) {
              final selectedFrom =
                  from != null && from.floor == selectedPlan.level
                  ? from.id
                  : null;
              final selectedTo = to != null && to.floor == selectedPlan.level
                  ? to.id
                  : null;
              cards.add(
                _FloorRoute(
                  plan: selectedPlan,
                  startId: selectedFrom,
                  endId: selectedTo,
                  showStartMarker: true,
                  subtitle: null,
                  showRoute: false,
                ),
              );
            }
            cards.addAll(routes);
            return ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              children: [
                _FormCard(
                  state: state,
                  onFloorChanged: cubit.setFloor,
                  onFromChanged: cubit.setFrom,
                  onToChanged: cubit.setTo,
                  onToggleAccessibility: cubit.toggleAccessibility,
                  onShowRoute: cubit.showRoute,
                  hasSelection: hasSelection,
                ),
                if (routes.isNotEmpty) ...[
                  Text(
                    '~2 min walk',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade600,
                      fontStyle: FontStyle.italic,
                      fontSize: 18,
                    ),
                    textAlign: TextAlign.right,
                  ),
                  const SizedBox(height: 12),
                ],
                if (from != null &&
                    to != null &&
                    routes.isEmpty &&
                    state.showRoute)
                  Text('No route available', style: theme.textTheme.bodyMedium),
                ...cards.map(
                  (r) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          r.plan.title,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        FloorMapCard(
                          plan: r.plan,
                          startId: r.startId,
                          endId: r.endId,
                          showRoute: r.showRoute,
                          showStartMarker: r.showStartMarker,
                          subtitle: r.subtitle,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _FormCard extends StatelessWidget {
  const _FormCard({
    required this.state,
    required this.onFloorChanged,
    required this.onFromChanged,
    required this.onToChanged,
    required this.onToggleAccessibility,
    required this.onShowRoute,
    required this.hasSelection,
  });

  final MapNavigationState state;
  final ValueChanged<int> onFloorChanged;
  final ValueChanged<String> onFromChanged;
  final ValueChanged<String> onToChanged;
  final ValueChanged<bool> onToggleAccessibility;
  final VoidCallback onShowRoute;
  final bool hasSelection;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final floorItems = floorPlans.map((e) => e.level).toList();
    final fromOptions = locationsForFloor(state.floor);
    final toOptions = allLocations;

    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _DropdownField<int>(
            label: 'Floor',
            value: state.floor,
            items: floorItems,
            itemBuilder: (v) => floorLabel(v),
            onChanged: onFloorChanged,
          ),
          const SizedBox(height: 10),
          _DropdownField<String>(
            label: 'You are here',
            value: state.fromId,
            items: fromOptions.map((e) => e.id).toList(),
            itemBuilder: (id) =>
                fromOptions.firstWhere((l) => l.id == id).label,
            onChanged: onFromChanged,
          ),
          const SizedBox(height: 10),
          _DropdownField<String>(
            label: 'Destination',

            value: state.toId,
            items: toOptions.map((e) => e.id).toList(),
            itemBuilder: (id) => toOptions.firstWhere((l) => l.id == id).label,
            onChanged: onToChanged,
          ),
          const SizedBox(height: 12),
          if (hasSelection) ...[
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Accessibility mode',
                    style: theme.textTheme.bodyMedium!.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                      fontSize: 20,
                    ),
                  ),
                ),
                Switch(
                  value: state.accessible,
                  trackColor: WidgetStatePropertyAll(
                    Color.fromRGBO(83, 177, 87, 1),
                  ),
                  onChanged: onToggleAccessibility,
                ),
              ],
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromRGBO(83, 177, 87, 1),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                onPressed: onShowRoute,
                child: const Text(
                  'Show route',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 23),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DropdownField<T> extends StatelessWidget {
  const _DropdownField({
    required this.label,
    required this.value,
    required this.items,
    required this.itemBuilder,
    required this.onChanged,
  });

  final String label;
  final T? value;
  final List<T> items;
  final String Function(T) itemBuilder;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium!.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<T>(
          value: value,
          decoration: InputDecoration(
            hoverColor: Colors.amber,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          ),
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 30,
            color: Colors.black38,
          ),
          items: items
              .map(
                (e) =>
                    DropdownMenuItem<T>(value: e, child: Text(itemBuilder(e))),
              )
              .toList(),
          onChanged: (val) {
            if (val != null) onChanged(val);
          },
        ),
      ],
    );
  }
}

class _FloorRoute {
  _FloorRoute({
    required this.plan,
    required this.startId,
    required this.endId,
    this.showStartMarker = true,
    this.subtitle,
    this.showRoute = true,
  });

  final FloorPlan plan;
  final String? startId;
  final String? endId;
  final bool showStartMarker;
  final String? subtitle;
  final bool showRoute;
}

List<_FloorRoute> _buildRoutes(MapNavigationState state) {
  final from = locationById(state.fromId);
  final to = locationById(state.toId);
  if (from == null || to == null) return [];

  final startPlan = planForLevel(from.floor)!;
  final destPlan = planForLevel(to.floor)!;

  if (from.floor == to.floor) {
    return [
      _FloorRoute(
        plan: startPlan,
        startId: from.id,
        endId: to.id,
        showStartMarker: true,
        showRoute: true,
      ),
    ];
  }

  return [
    _FloorRoute(
      plan: startPlan,
      startId: from.id,
      endId: startPlan.elevatorId,
      showStartMarker: true,
      subtitle: 'Take the elevator to Floor ${to.floor}',
      showRoute: true,
    ),
    _FloorRoute(
      plan: destPlan,
      startId: destPlan.elevatorId,
      endId: to.id,
      showStartMarker: false,
      showRoute: true,
    ),
  ];
}

Widget backButton(BuildContext context) {
  return InkWell(
    onTap: () => context.pop(),
    child: Container(
      margin: EdgeInsets.all(10),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Color.fromRGBO(244, 244, 244, 1),
      ),
      width: 10,
      height: 10,
      child: Icon(Icons.chevron_left, size: 30, color: Colors.black54),
    ),
  );
}
