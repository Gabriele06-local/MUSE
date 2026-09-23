/// Immutable value object for a single museum entry.
///
/// English fields are the base content. Italian overrides are optional and
/// merged from a separate asset (`assets/quotes_it.json`), keeping quote
/// content separate from UI translations. Accessors fall back to English
/// whenever an Italian value is missing.
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
    this.textIt,
    this.roleIt,
    this.bioIt,
    this.sourceIt,
  });

  final String id;
  final String text;
  final String author;
  final QuoteCategory category;
  final String role;
  final String years;
  final String bio;
  final String source;

  /// Optional Italian overrides. Null/empty means "use English".
  final String? textIt;
  final String? roleIt;
  final String? bioIt;
  final String? sourceIt;

  /// Localized accessors. Pass `'it'` for Italian, anything else for English.
  String textFor(String languageCode) =>
      (languageCode == 'it' && (textIt?.isNotEmpty ?? false)) ? textIt! : text;

  String roleFor(String languageCode) =>
      (languageCode == 'it' && (roleIt?.isNotEmpty ?? false)) ? roleIt! : role;

  String bioFor(String languageCode) =>
      (languageCode == 'it' && (bioIt?.isNotEmpty ?? false)) ? bioIt! : bio;

  String sourceFor(String languageCode) =>
      (languageCode == 'it' && (sourceIt?.isNotEmpty ?? false))
      ? sourceIt!
      : source;

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

  /// Returns a copy with Italian overrides applied.
  Quote withItalian(Map<String, dynamic> it) {
    String? nonEmpty(String? v) =>
        (v != null && v.trim().isNotEmpty) ? v : null;
    return Quote(
      id: id,
      text: text,
      author: author,
      category: category,
      role: role,
      years: years,
      bio: bio,
      source: source,
      textIt: nonEmpty(it['text'] as String?),
      roleIt: nonEmpty(it['role'] as String?),
      bioIt: nonEmpty(it['bio'] as String?),
      sourceIt: nonEmpty(it['source'] as String?),
    );
  }
}

enum QuoteCategory {
  italianEntrepreneurs('italian_entrepreneurs'),
  internationalEntrepreneurs('international_entrepreneurs'),
  cinema('cinema'),
  culture('culture');

  const QuoteCategory(this.key);
  final String key;

  static QuoteCategory fromKey(String key) {
    for (final c in QuoteCategory.values) {
      if (c.key == key) return c;
    }
    return QuoteCategory.culture;
  }
}
