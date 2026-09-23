/// Immutable value object for a single museum entry.
class Quote {
  const Quote({
    required this.id,
    required this.text,
    required this.author,
    required this.category,
    required this.role,
    required this.years,
    required this.bio,
    required this.source,
  });

  final String id;
  final String text;
  final String author;
  final QuoteCategory category;
  final String role;
  final String years;
  final String bio;
  final String source;

  factory Quote.fromJson(Map<String, dynamic> json) {
    return Quote(
      id: json['id'] as String,
      text: json['text'] as String,
      author: json['author'] as String,
      category: QuoteCategory.fromKey(json['category'] as String),
      role: (json['role'] as String?) ?? '',
      years: (json['years'] as String?) ?? '',
      bio: (json['bio'] as String?) ?? '',
      source: (json['source'] as String?) ?? '',
    );
  }
}

enum QuoteCategory {
  italianEntrepreneurs('italian_entrepreneurs', 'Italian Entrepreneurs'),
  internationalEntrepreneurs(
    'international_entrepreneurs',
    'International Entrepreneurs',
  ),
  cinema('cinema', 'Cinema'),
  culture('culture', 'Culture');

  const QuoteCategory(this.key, this.label);
  final String key;
  final String label;

  static QuoteCategory fromKey(String key) {
    for (final c in QuoteCategory.values) {
      if (c.key == key) return c;
    }
    return QuoteCategory.culture;
  }

  /// A short room name used in the dreamy museum metaphor.
  String get room {
    switch (this) {
      case QuoteCategory.italianEntrepreneurs:
        return 'Room I · Italian Vision';
      case QuoteCategory.internationalEntrepreneurs:
        return 'Room II · World Builders';
      case QuoteCategory.cinema:
        return 'Room III · Cinema';
      case QuoteCategory.culture:
        return 'Room IV · Culture';
    }
  }
}
