import 'room.dart';

abstract class RoomsRepository {
  Future<List<Room>> fetchRooms();
  Future<void> addRoom(Room room);
}
