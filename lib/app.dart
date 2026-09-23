import 'package:flutter/material.dart';

import 'data/favorites_store.dart';
import 'data/quote_repository.dart';
import 'ui/home_screen.dart';
import 'ui/muse_theme.dart';

/// Root widget. Holds the two long-lived controllers and injects them down.
/// No service locator, no extra packages — just constructor injection.
class MuseApp extends StatefulWidget {
  const MuseApp({super.key});

  @override
  State<MuseApp> createState() => _MuseAppState();
}

class _MuseAppState extends State<MuseApp> {
  late final QuoteDeck _deck;
  late final FavoritesStore _favorites;

  @override
  void initState() {
    super.initState();
    _deck = QuoteDeck();
    _favorites = FavoritesStore();
    _deck.load();
    _favorites.load();
  }

  @override
  void dispose() {
    _deck.dispose();
    _favorites.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MUSE',
      debugShowCheckedModeBanner: false,
      theme: buildMuseTheme(),
      home: HomeScreen(deck: _deck, favorites: _favorites),
    );
  }
}
