import 'package:flutter/material.dart';

class MapNode {
  const MapNode({
    required this.id,
    required this.label,
    required this.icon,
    required this.position,
    required this.img,
  });

  final String id;
  final String label;
  final IconData icon;
  final Offset position; // normalized (0..1)
  final String img;
}

class MapConnection {
  const MapConnection({required this.from, required this.to});
  final String from;
  final String to;
}

class FloorPlan {
  const FloorPlan({
    required this.level,
    required this.title,
    required this.elevatorId,
    required this.nodes,
    required this.connections,
  });

  final int level;
  final String title;
  final String elevatorId;
  final List<MapNode> nodes;
  final List<MapConnection> connections;
}

class MapLocation {
  const MapLocation({
    required this.id,
    required this.label,
    required this.floor,
    required this.icon,
  });

  final String id;
  final String label;
  final int floor;
  final IconData icon;
}
