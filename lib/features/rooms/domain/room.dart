import 'dart:convert';

class Room {
  Room({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.type,
    required this.size,
    required this.sizeFull,
    required this.bed,
    required this.photos,
    this.hint,
    this.tag,
    this.capacity,
    this.features = const [],
    this.amenities = const [],
    this.extras = const [],
  });

  final String id;
  final String name;
  final String description;
  final double price;
  final String type;
  final String size;
  final String sizeFull;
  final String bed;
  final List<String> photos;
  final String? hint;
  final String? tag;
  final String? capacity;
  final List<String> features;
  final List<String> amenities;
  final List<String> extras;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'type': type,
      'size': size,
      'sizeFull': sizeFull,
      'bed': bed,
      'hint': hint,
      'photos': jsonEncode(photos),
      'tags': tag,
      'capacity': capacity,
      'features': features,
      'amenities': amenities,
      'extras': extras,
    };
  }

  static Room fromMap(Map<String, dynamic> map) {
    String? parsedTag;
    final rawTags = map.containsKey('tag') && map['tags'] == null
        ? map['tag']
        : map['tags'];
    if (rawTags != null) {
      final str = rawTags.toString();
      if (str.trim().startsWith('[')) {
        // legacy JSON array, take first
        final list = jsonDecode(str) as List<dynamic>;
        parsedTag = list.isNotEmpty ? list.first.toString() : null;
      } else {
        parsedTag = str;
      }
    }

    final photosRaw = map['photos'];
    final photosList = photosRaw is String
        ? (jsonDecode(photosRaw) as List<dynamic>)
        : (photosRaw as List<dynamic>);

    return Room(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String,
      price: (map['price'] as num).toDouble(),
      type: (map['type'] ?? 'room') as String,
      size: map['size'] as String,
      sizeFull: (map['sizeFull'] ?? map['size'] ?? '') as String,
      bed: map['bed'] as String,
      hint: map['hint'] as String?,
      photos: List<String>.from(photosList),
      tag: parsedTag?.isEmpty == true ? null : parsedTag,
      capacity: map['capacity'] as String?,
      features: _parseStringList(map['features']),
      amenities: _parseStringList(map['amenities']),
      extras: _parseStringList(map['extras']),
    );
  }
}

List<String> _parseStringList(dynamic value) {
  if (value == null) return const [];
  if (value is String) {
    return List<String>.from(jsonDecode(value) as List<dynamic>);
  }
  return List<String>.from(value as List<dynamic>);
}
