import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../../features/rooms/domain/room.dart';

class AppDatabase {
  AppDatabase._();
  static final AppDatabase instance = AppDatabase._();

  Database? _db;

  Future<void> init() async {
    if (_db != null) return;
    final docsDir = await getApplicationDocumentsDirectory();
    final path = join(docsDir.path, 'grand_stay.db');
    _db = await openDatabase(
      path,
      version: 4,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE rooms (
            id TEXT PRIMARY KEY,
            name TEXT,
            description TEXT,
            price REAL,
            size TEXT,
            bed TEXT,
            photos TEXT,
            tags TEXT
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE rooms ADD COLUMN tags TEXT');
        }
        if (oldVersion < 3) {
          await _migratePhotosToPng(db);
        }
        if (oldVersion < 4) {
          await _migrateTagsToString(db);
        }
      },
    );
    await _migratePhotosToPng(_db!);
    await _migrateTagsToString(_db!);
    await _seedOrBackfillRoomsFromAssets();
  }

  Future<List<Room>> fetchRooms() async {
    final data = await _db!.query('rooms');
    return data.map(Room.fromMap).toList();
  }

  Future<void> insertRoom(Room room) async {
    await _db!.insert(
      'rooms',
      room.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> _seedOrBackfillRoomsFromAssets() async {
    final jsonStr = await rootBundle.loadString('assets/data/rooms_seed.json');
    final seedList = (jsonDecode(jsonStr) as List<dynamic>)
        .map((item) => Room.fromMap(Map<String, dynamic>.from(item as Map)))
        .toList();

    for (final room in seedList) {
      final existing = await _db!.query(
        'rooms',
        where: 'id = ?',
        whereArgs: [room.id],
        limit: 1,
      );
      if (existing.isEmpty) {
        await insertRoom(room);
      } else {
        final current = existing.first;
        final currentTag = current['tags']?.toString().trim();
        if (currentTag == null || currentTag.isEmpty) {
          await _db!.update(
            'rooms',
            {'tags': room.tag},
            where: 'id = ?',
            whereArgs: [room.id],
          );
        }
      }
    }
  }

  Future<void> _migratePhotosToPng(Database db) async {
    final rows = await db.query('rooms', columns: ['id', 'photos']);
    for (final row in rows) {
      final id = row['id'] as String;
      final photos = (jsonDecode(row['photos'] as String) as List)
          .map((e) => (e as String).replaceAll('.jpg', '.png'))
          .toList();
      await db.update(
        'rooms',
        {'photos': jsonEncode(photos)},
        where: 'id = ?',
        whereArgs: [id],
      );
    }
  }

  Future<void> _migrateTagsToString(Database db) async {
    final rows = await db.query('rooms', columns: ['id', 'tags']);
    for (final row in rows) {
      final id = row['id'] as String;
      final raw = row['tags'];
      if (raw == null) continue;
      String? tag;
      final str = raw.toString();
      if (str.trim().startsWith('[')) {
        final list = jsonDecode(str) as List<dynamic>;
        tag = list.isNotEmpty ? list.first.toString() : null;
      } else {
        tag = str;
      }
      await db.update('rooms', {'tags': tag}, where: 'id = ?', whereArgs: [id]);
    }
  }
}
