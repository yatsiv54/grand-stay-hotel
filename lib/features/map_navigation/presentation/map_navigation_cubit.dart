import 'package:bloc/bloc.dart';

import '../data/map_floor_data.dart';
import '../domain/map_models.dart';

class MapNavigationState {
  const MapNavigationState({
    required this.floor,
    required this.fromId,
    required this.toId,
    required this.accessible,
    required this.showRoute,
  });

  final int floor;
  final String? fromId;
  final String? toId;
  final bool accessible;
  final bool showRoute;

  MapNavigationState copyWith({
    int? floor,
    String? fromId,
    bool fromIdSet = false,
    String? toId,
    bool toIdSet = false,
    bool? accessible,
    bool? showRoute,
  }) {
    return MapNavigationState(
      floor: floor ?? this.floor,
      fromId: fromIdSet ? fromId : this.fromId,
      toId: toIdSet ? toId : this.toId,
      accessible: accessible ?? this.accessible,
      showRoute: showRoute ?? this.showRoute,
    );
  }

  static MapNavigationState initial() {
    final defaultFloor = floorPlans.first.level;
    return MapNavigationState(
      floor: defaultFloor,
      fromId: null,
      toId: null,
      accessible: true,
      showRoute: false,
    );
  }
}

class MapNavigationCubit extends Cubit<MapNavigationState> {
  MapNavigationCubit() : super(MapNavigationState.initial());

  void setFloor(int floor) {
    emit(
      state.copyWith(
        floor: floor,
        fromId: null,
        fromIdSet: true,
        toId: null,
        toIdSet: true,
        showRoute: false,
      ),
    );
  }

  void setFrom(String id) {
    emit(state.copyWith(fromId: id, fromIdSet: true, showRoute: false));
  }

  void setTo(String id) {
    emit(state.copyWith(toId: id, toIdSet: true, showRoute: false));
  }

  void toggleAccessibility(bool value) {
    emit(state.copyWith(accessible: value));
  }

  void showRoute() {
    emit(state.copyWith(showRoute: true));
  }
}
