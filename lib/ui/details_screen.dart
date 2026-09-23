import 'package:flutter/material.dart';

import '../data/favorites_store.dart';
import '../data/quote_repository.dart';
import '../models/quote.dart';
import 'dream_background.dart';
import 'muse_theme.dart';

/// Quiet biography room for one author.
class DetailsScreen extends StatelessWidget {
  const DetailsScreen({
    super.key,
    required this.quote,
    required this.deck,
    required this.favorites,
  });

  final Quote quote;
  final QuoteDeck deck;
  final FavoritesStore favorites;

  @override
  Widget build(BuildContext context) {
    final related = deck.related(quote);
    return Scaffold(
      body: DreamBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final horizontal = (constraints.maxWidth * 0.08).clamp(
                20.0,
                40.0,
              );
              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 640),
                  child: CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: horizontal,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 8),
                              _DetailsTopBar(
                                quote: quote,
                                favorites: favorites,
                              ),
                              const SizedBox(height: 28),
                              Semantics(
                                header: true,
                                child: Text(
                                  quote.category.room.toUpperCase(),
                                  style: MuseType.meta.copyWith(
                                    color: MuseColors.gold.withValues(
                                      alpha: 0.9,
                                    ),
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                quote.author,
                                style: MuseType.quote(context).copyWith(
                                  fontSize: MuseType.quote(
                                    context,
                                  ).fontSize! * 1.05,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                [
                                  if (quote.role.isNotEmpty) quote.role,
                                  if (quote.years.isNotEmpty) quote.years,
                                ].join('  ·  '),
                                style: MuseType.meta,
                              ),
                              const SizedBox(height: 24),
                              Container(
                                padding: const EdgeInsets.all(22),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.03),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: MuseColors.hairline,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Text(
                                      '“${quote.text}”',
                                      style: MuseType.body.copyWith(
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                    if (quote.source.isNotEmpty) ...[
                                      const SizedBox(height: 12),
                                      Text(
                                        '— ${quote.source}',
                                        style: MuseType.meta.copyWith(
                                          fontSize: 11,
                                          color: MuseColors.faint,
                                          letterSpacing: 0.8,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              const SizedBox(height: 28),
                              const Text(
                                'LIFE',
                                style: TextStyle(
                                  fontFamilyFallback:
                                      MuseType.sansFallback,
                                  fontSize: 11,
                                  letterSpacing: 3,
                                  color: MuseColors.faint,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(quote.bio, style: MuseType.body),
                              if (related.isNotEmpty) ...[
                                const SizedBox(height: 32),
                                const Text(
                                  'NEARBY ROOMS',
                                  style: TextStyle(
                                    fontFamilyFallback:
                                        MuseType.sansFallback,
                                    fontSize: 11,
                                    letterSpacing: 3,
                                    color: MuseColors.faint,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                for (final r in related)
                                  _RelatedTile(
                                    quote: r,
                                    deck: deck,
                                    favorites: favorites,
                                  ),
                              ],
                              const SizedBox(height: 32),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _DetailsTopBar extends StatelessWidget {
  const _DetailsTopBar({required this.quote, required this.favorites});

  final Quote quote;
  final FavoritesStore favorites;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Semantics(
          button: true,
          label: 'Go back',
          child: InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: () => Navigator.of(context).pop(),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
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
        ListenableBuilder(
          listenable: favorites,
          builder: (context, _) {
            final fav = favorites.isFavorite(quote.id);
            return Semantics(
              button: true,
              label: fav ? 'Remove from saved' : 'Save this quote',
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () => favorites.toggle(quote.id),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Icon(
                    fav ? Icons.favorite : Icons.favorite_border,
                    size: 20,
                    color: fav ? MuseColors.gold : MuseColors.paper,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _RelatedTile extends StatelessWidget {
  const _RelatedTile({
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
      label: 'Read quote by ${quote.author}',
      child: InkWell(
        borderRadius: BorderRadius.circular(4),
        onTap: () {
          Navigator.of(context).pushReplacement(
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
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            border: Border.all(color: MuseColors.hairline),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '“${quote.text}”',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: MuseType.body.copyWith(fontSize: 14, height: 1.6),
              ),
              const SizedBox(height: 6),
              Text(
                '${quote.author} · ${quote.category.label}'.toUpperCase(),
                style: MuseType.meta.copyWith(
                  fontSize: 10,
                  color: MuseColors.faint,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
