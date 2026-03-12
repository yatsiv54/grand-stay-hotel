import 'package:flutter/material.dart';

import '../domain/map_models.dart';

const _elevatorId = 'elevator';

const floorPlans = <FloorPlan>[
  FloorPlan(
    level: -1,
    title: 'Floor -1',
    elevatorId: 'f-1_elevator',
    nodes: [
      MapNode(
        img: 'assets/images/icons/spa.png',
        id: 'f-1_spa',
        label: 'Spa & Wellness',
        icon: Icons.spa_outlined,
        position: Offset(0.15, 0.2),
      ),
      MapNode(
        img: 'assets/images/icons/tech.png',
        id: 'f-1_tech',
        label: 'Technical rooms',
        icon: Icons.engineering_outlined,
        position: Offset(0.85, 0.2),
      ),
      MapNode(
        img: 'assets/images/icons/changing.png',
        id: 'f-1_changing',
        label: 'Changing rooms',
        icon: Icons.meeting_room_outlined,
        position: Offset(0.15, 0.8),
      ),
      MapNode(
        img: 'assets/images/icons/emergency.png',
        id: 'f-1_exit',
        label: 'Emergency exits',
        icon: Icons.emergency_share_rounded,
        position: Offset(0.85, 0.8),
      ),
      MapNode(
        img: 'assets/images/icons/elevator.png',
        id: 'f-1_elevator',
        label: 'Elevator',
        icon: Icons.elevator_outlined,
        position: Offset(0.5, 0.5),
      ),
    ],
    connections: [
      MapConnection(from: 'f-1_spa', to: 'f-1_elevator'),
      MapConnection(from: 'f-1_tech', to: 'f-1_elevator'),
      MapConnection(from: 'f-1_changing', to: 'f-1_elevator'),
      MapConnection(from: 'f-1_exit', to: 'f-1_elevator'),
    ],
  ),
  FloorPlan(
    level: 0,
    title: 'Floor 0',
    elevatorId: 'f0_elevator',
    nodes: [
      MapNode(
        img: 'assets/images/icons/lobby.png',
        id: 'f0_lobby',
        label: 'Lobby',
        icon: Icons.location_city_rounded,
        position: Offset(0.15, 0.2),
      ),
      MapNode(
        img: 'assets/images/icons/reception.png',
        id: 'f0_reception',
        label: 'Reception',
        icon: Icons.person_pin_circle_rounded,
        position: Offset(0.5, 0.2),
      ),
      MapNode(
        img: 'assets/images/icons/restraunt.png',
        id: 'f0_restaurants',
        label: 'Restaurants',
        icon: Icons.restaurant_menu_rounded,
        position: Offset(0.85, 0.2),
      ),
      MapNode(
        img: 'assets/images/icons/mic.png',
        id: 'f0_entertainment',
        label: 'Entertainment Zone',
        icon: Icons.theaters_rounded,
        position: Offset(0.15, 0.8),
      ),
      MapNode(
        img: 'assets/images/icons/emergency.png',
        id: 'f0_exit',
        label: 'Emergency exits',
        icon: Icons.emergency_share_rounded,
        position: Offset(0.85, 0.8),
      ),
      MapNode(
        img: 'assets/images/icons/elevator.png',
        id: 'f0_elevator',
        label: 'Elevator',
        icon: Icons.elevator_outlined,
        position: Offset(0.5, 0.5),
      ),
    ],
    connections: [
      MapConnection(from: 'f0_lobby', to: 'f0_elevator'),
      MapConnection(from: 'f0_reception', to: 'f0_elevator'),
      MapConnection(from: 'f0_restaurants', to: 'f0_elevator'),
      MapConnection(from: 'f0_lobby', to: 'f0_reception'),
      MapConnection(from: 'f0_reception', to: 'f0_restaurants'),
      MapConnection(from: 'f0_entertainment', to: 'f0_elevator'),
      MapConnection(from: 'f0_exit', to: 'f0_elevator'),
    ],
  ),
  FloorPlan(
    level: 1,
    title: 'Floor 1',
    elevatorId: 'f1_elevator',
    nodes: [
      MapNode(
        img: 'assets/images/icons/gym.png',
        id: 'f1_fitness',
        label: 'Fitness & Gym',
        icon: Icons.fitness_center_rounded,
        position: Offset(0.2, 0.25),
      ),
      MapNode(
        img: 'assets/images/icons/bed.png',
        id: 'f1_rooms',
        label: 'Some guest rooms',
        icon: Icons.bed_outlined,
        position: Offset(0.8, 0.25),
      ),
      MapNode(
        img: 'assets/images/icons/emergency.png',
        id: 'f1_exit',
        label: 'Emergency exits',
        icon: Icons.emergency_share_rounded,
        position: Offset(0.8, 0.8),
      ),
      MapNode(
        img: 'assets/images/icons/elevator.png',
        id: 'f1_elevator',
        label: 'Elevator',
        icon: Icons.elevator_outlined,
        position: Offset(0.5, 0.55),
      ),
    ],
    connections: [
      MapConnection(from: 'f1_fitness', to: 'f1_elevator'),
      MapConnection(from: 'f1_rooms', to: 'f1_elevator'),
      MapConnection(from: 'f1_fitness', to: 'f1_rooms'),
      MapConnection(from: 'f1_exit', to: 'f1_elevator'),
    ],
  ),
  FloorPlan(
    level: 2,
    title: 'Floor 2',
    elevatorId: 'f2_elevator',
    nodes: [
      MapNode(
        img: 'assets/images/icons/bed.png',
        id: 'f2_rooms',
        label: 'Guest Rooms zone',
        icon: Icons.king_bed_rounded,
        position: Offset(0.5, 0.24),
      ),
      MapNode(
        img: 'assets/images/icons/emergency.png',
        id: 'f2_exit',
        label: 'Emergency exits',
        icon: Icons.emergency_share_rounded,
        position: Offset(0.8, 0.8),
      ),
      MapNode(
        img: 'assets/images/icons/elevator.png',
        id: 'f2_elevator',
        label: 'Elevator',
        icon: Icons.elevator_outlined,
        position: Offset(0.5, 0.55),
      ),
    ],
    connections: [
      MapConnection(from: 'f2_rooms', to: 'f2_elevator'),
      MapConnection(from: 'f2_exit', to: 'f2_elevator'),
    ],
  ),
  FloorPlan(
    level: 3,
    title: 'Floor 3',
    elevatorId: 'f3_elevator',
    nodes: [
      MapNode(
        img: 'assets/images/icons/city.png',
        id: 'f3_view',
        label: 'Viewing deck',
        icon: Icons.travel_explore_rounded,
        position: Offset(0.2, 0.28),
      ),
      MapNode(
        img: 'assets/images/icons/bar.png',
        id: 'f3_bar',
        label: 'Rooftop Bar',
        icon: Icons.local_bar_rounded,
        position: Offset(0.8, 0.28),
      ),
      MapNode(
        img: 'assets/images/icons/emergency.png',
        id: 'f3_exit',
        label: 'Emergency exits',
        icon: Icons.emergency_share_rounded,
        position: Offset(0.8, 0.8),
      ),
      MapNode(
        img: 'assets/images/icons/elevator.png',
        id: 'f3_elevator',
        label: 'Elevator',
        icon: Icons.elevator_outlined,
        position: Offset(0.5, 0.55),
      ),
    ],
    connections: [
      MapConnection(from: 'f3_view', to: 'f3_elevator'),
      MapConnection(from: 'f3_bar', to: 'f3_elevator'),
      MapConnection(from: 'f3_view', to: 'f3_bar'),
      MapConnection(from: 'f3_exit', to: 'f3_elevator'),
    ],
  ),
];

List<MapLocation> get allLocations {
  return floorPlans
      .expand(
        (plan) => plan.nodes
            .where((n) => n.id != plan.elevatorId)
            .map(
              (n) => MapLocation(
                id: n.id,
                label: n.label,
                floor: plan.level,
                icon: n.icon,
              ),
            ),
      )
      .toList();
}

FloorPlan planForLevel(int level) =>
    floorPlans.firstWhere((f) => f.level == level, orElse: () => floorPlans[0]);

MapLocation? locationById(String? id) {
  if (id == null) return null;
  return allLocations.firstWhere(
    (e) => e.id == id,
    orElse: () => allLocations.first,
  );
}

List<MapLocation> locationsForFloor(int level) =>
    allLocations.where((e) => e.floor == level).toList();

String floorLabel(int level) => level >= 0 ? 'Floor $level' : 'Floor $level';
