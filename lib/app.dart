import 'package:flutter/material.dart';

import 'data/favorites_store.dart';
import 'data/quote_repository.dart';
import 'i18n/language_controller.dart';
import 'ui/home_screen.dart';
import 'ui/muse_theme.dart';

/// Root widget. Holds the long-lived controllers and injects them down.
/// No service locator, no extra packages — just constructor injection.
class MuseApp extends StatefulWidget {
  const MuseApp({super.key});

  @override
  State<MuseApp> createState() => _MuseAppState();
}

class _MuseAppState extends State<MuseApp> {
  late final QuoteDeck _deck;
  late final FavoritesStore _favorites;
  late final LanguageController _lang;

  @override
  void initState() {
    super.initState();
    _deck = QuoteDeck();
    _favorites = FavoritesStore();
    _lang = LanguageController();
    _deck.load();
    _favorites.load();
    _lang.load();
  }

  @override
  void dispose() {
    _deck.dispose();
    _favorites.dispose();
    _lang.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _lang,
      builder: (context, _) {
        return MaterialApp(
          title: 'MUSE',
          debugShowCheckedModeBanner: false,
          theme: buildMuseTheme(),
          // Rebuild the whole museum on language change so every string
          // and every quote re-resolves. Deck position is preserved
          // because the controllers outlive this build.
          home: HomeScreen(deck: _deck, favorites: _favorites, lang: _lang),
        );
      },
    );
  }
}
