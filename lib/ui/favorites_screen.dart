import 'package:flutter/material.dart';

import '../data/favorites_store.dart';
import '../data/quote_repository.dart';
import '../models/quote.dart';
import 'details_screen.dart';
import 'dream_background.dart';
import 'muse_theme.dart';

/// Minimal saved collection. No cards, just quiet rows.
class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({
    super.key,
    required this.deck,
    required this.favorites,
  });

  final QuoteDeck deck;
  final FavoritesStore favorites;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DreamBackground(
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Semantics(
                          button: true,
                          label: 'Go back',
                          child: InkWell(
                            borderRadius: BorderRadius.circular(24),
                            onTap: () => Navigator.of(context).pop(),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 12,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.arrow_back_rounded,
                                    size: 18,
                                    color: MuseColors.muted,
                                    semanticLabel: 'Back',
                                  ),
                                  SizedBox(width: 8),
                                  Text('Rooms', style: MuseType.meta),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const Spacer(),
                        const Text(
                          'SAVED',
                          style: TextStyle(
                            fontFamilyFallback: MuseType.sansFallback,
                            fontSize: 11,
                            letterSpacing: 4,
                            color: MuseColors.faint,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Semantics(
                      header: true,
                      child: Text(
                        'Your collection',
                        style: TextStyle(
                          fontFamily: 'Georgia',
                          fontFamilyFallback: MuseType.serifFallback,
                          fontSize: 30,
                          height: 1.2,
                          color: MuseColors.paper,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    ListenableBuilder(
                      listenable: favorites,
                      builder: (context, _) {
                        final n = favorites.count;
                        return Text(
                          n == 0
                              ? 'Nothing saved yet — tap the heart in any room.'
                              : '$n ${n == 1 ? "memory" : "memories"} kept',
                          style: MuseType.smallBody,
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: ListenableBuilder(
                        listenable: Listenable.merge([deck, favorites]),
                        builder: (context, _) {
                          final saved = deck.all
                              .where((q) => favorites.isFavorite(q.id))
                              .toList(growable: false);
                          if (saved.isEmpty) {
                            return const _EmptyCollection();
                          }
                          return ListView.separated(
                            itemCount: saved.length,
                            separatorBuilder: (_, _) =>
                                const Divider(
                                  color: MuseColors.hairline,
                                  height: 1,
                                ),
                            itemBuilder: (context, i) {
                              final q = saved[i];
                              return _SavedRow(
                                quote: q,
                                deck: deck,
                                favorites: favorites,
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyCollection extends StatelessWidget {
  const _EmptyCollection();

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.bookmark_border_rounded,
          size: 32,
          color: MuseColors.faint,
          semanticLabel: 'Empty collection',
        ),
        SizedBox(height: 16),
        Text(
          'The museum keeps\nwhat you love.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Georgia',
            fontFamilyFallback: MuseType.serifFallback,
            fontSize: 20,
            height: 1.5,
            color: MuseColors.muted,
          ),
        ),
      ],
    );
  }
}

class _SavedRow extends StatelessWidget {
  const _SavedRow({
    required this.quote,
    required this.deck,
    required this.favorites,
  });

  final Quote quote;
  final QuoteDeck deck;
  final FavoritesStore favorites;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Open quote by ${quote.author}',
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            PageRouteBuilder<void>(
              transitionDuration: const Duration(milliseconds: 350),
              pageBuilder: (_, _, _) => DetailsScreen(
                quote: quote,
                deck: deck,
                favorites: favorites,
              ),
              transitionsBuilder: (_, anim, _, child) =>
                  FadeTransition(opacity: anim, child: child),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '“${quote.text}”',
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: MuseType.body.copyWith(
                        fontSize: 15,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${quote.author} · ${quote.category.label}'
                          .toUpperCase(),
                      style: MuseType.meta.copyWith(
                        fontSize: 10,
                        color: MuseColors.faint,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Semantics(
                button: true,
                label: 'Remove ${quote.author} from saved',
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () => favorites.toggle(quote.id),
                  child: const Padding(
                    padding: EdgeInsets.all(10),
                    child: Icon(
                      Icons.favorite,
                      size: 17,
                      color: MuseColors.gold,
                      semanticLabel: 'Remove',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
