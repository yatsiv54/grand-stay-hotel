class DiningItem {
  DiningItem({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.openHours,
    required this.tags,
    required this.description,
    required this.atmosphere,
    required this.cuisine,
    required this.specialFeatures,
    required this.menuPreview,
    required this.image,
    this.hint,
  });

  final String id;
  final String name;
  final String subtitle;
  final String openHours;
  final List<String> tags;
  final String description;
  final String atmosphere;
  final String cuisine;
  final List<String> specialFeatures;
  final List<String> menuPreview;
  final String image;
  final String? hint;

  factory DiningItem.fromMap(Map<String, dynamic> map) {
    return DiningItem(
      id: map['id'] as String,
      name: map['name'] as String,
      subtitle: map['subtitle'] as String? ?? '',
      openHours: map['openHours'] as String? ?? '',
      tags: map['tags'] != null
          ? List<String>.from(map['tags'] as List<dynamic>)
          : const [],
      description: map['description'] as String? ?? '',
      atmosphere: map['atmosphere'] as String? ?? '',
      cuisine: map['cuisine'] as String? ?? '',
      specialFeatures: map['specialFeatures'] != null
          ? List<String>.from(map['specialFeatures'] as List<dynamic>)
          : const [],
      menuPreview: map['menuPreview'] != null
          ? List<String>.from(map['menuPreview'] as List<dynamic>)
          : const [],
      image: map['image'] as String,
      hint: map['hint'] as String?,
    );
  }
}
