import 'dart:convert';

import 'package:flutter/services.dart';

import '../domain/room.dart';
import '../domain/rooms_repository.dart';

class RoomsLocalRepository implements RoomsRepository {
  const RoomsLocalRepository();

  @override
  Future<List<Room>> fetchRooms() async {
    final jsonStr = await rootBundle.loadString('assets/data/rooms_seed.json');
    final list = jsonDecode(jsonStr) as List<dynamic>;
    return list
        .map((e) => Room.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  @override
  Future<void> addRoom(Room room) async {
    throw UnimplementedError('JSON storage is read-only in this demo.');
  }
}
