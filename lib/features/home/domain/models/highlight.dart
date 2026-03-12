class Highlight {
  Highlight({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.ctaLabel,
    required this.assetGradient,
  });

  final String id;
  final String title;
  final String subtitle;
  final String ctaLabel;
  final List<int> assetGradient;

  factory Highlight.fromMap(Map<String, dynamic> map) {
    final gradient = map['gradient'] ?? map['assetGradient'];
    final parsedGradient = gradient != null
        ? List<int>.from(gradient as List<dynamic>)
        : <int>[0xFFD72F32, 0xFFB30F14];
    return Highlight(
      id: map['id'] as String,
      title: map['title'] as String,
      subtitle: map['subtitle'] as String? ?? '',
      ctaLabel: map['ctaLabel'] as String? ?? 'View',
      assetGradient: parsedGradient,
    );
  }
}
