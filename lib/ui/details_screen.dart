import 'package:flutter/material.dart';

import '../data/favorites_store.dart';
import '../data/quote_repository.dart';
import '../i18n/language_controller.dart';
import '../models/quote.dart';
import 'dream_background.dart';
import 'muse_theme.dart';

/// Quiet biography room for one author.
///
/// Takes a [Quote] snapshot (which carries both languages), so returning
/// always lands back on the same museum position and a language switch
/// re-renders without losing context.
class DetailsScreen extends StatelessWidget {
  const DetailsScreen({
    super.key,
    required this.quote,
    required this.deck,
    required this.favorites,
    required this.lang,
  });

  final Quote quote;
  final QuoteDeck deck;
  final FavoritesStore favorites;
  final LanguageController lang;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: lang,
      builder: (context, _) {
        final s = lang.strings;
        final code = lang.locale.code;
        final related = deck.related(quote);
        final text = quote.textFor(code);
        final role = quote.roleFor(code);
        final bio = quote.bioFor(code);
        final source = quote.sourceFor(code);
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
                                    lang: lang,
                                  ),
                                  const SizedBox(height: 28),
                                  Semantics(
                                    header: true,
                                    child: Text(
                                      s
                                          .roomName(quote.category)
                                          .toUpperCase(),
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
                                      fontSize:
                                          MuseType.quote(
                                            context,
                                          ).fontSize! *
                                          1.05,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    [
                                      if (role.isNotEmpty) role,
                                      if (quote.years.isNotEmpty)
                                        quote.years,
                                    ].join('  ·  '),
                                    style: MuseType.meta,
                                  ),
                                  const SizedBox(height: 24),
                                  Container(
                                    padding: const EdgeInsets.all(22),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(
                                        alpha: 0.03,
                                      ),
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
                                          '“$text”',
                                          style: MuseType.body.copyWith(
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                        if (source.isNotEmpty) ...[
                                          const SizedBox(height: 12),
                                          Text(
                                            '— $source',
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
                                  Text(
                                    s.life,
                                    style: const TextStyle(
                                      fontFamilyFallback:
                                          MuseType.sansFallback,
                                      fontSize: 11,
                                      letterSpacing: 3,
                                      color: MuseColors.faint,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(bio, style: MuseType.body),
                                  if (related.isNotEmpty) ...[
                                    const SizedBox(height: 32),
                                    Text(
                                      s.nearby,
                                      style: const TextStyle(
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
                                        lang: lang,
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
      },
    );
  }
}

class _DetailsTopBar extends StatelessWidget {
  const _DetailsTopBar({
    required this.quote,
    required this.favorites,
    required this.lang,
  });

  final Quote quote;
  final FavoritesStore favorites;
  final LanguageController lang;

  @override
  Widget build(BuildContext context) {
    final s = lang.strings;
    return Row(
      children: [
        Semantics(
          button: true,
          label: s.back,
          child: InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: () => Navigator.of(context).pop(),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 12,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.arrow_back_rounded,
                    size: 18,
                    color: MuseColors.muted,
                    semanticLabel: 'Back',
                  ),
                  const SizedBox(width: 8),
                  Text(s.rooms, style: MuseType.meta),
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
              label: fav ? s.unsave : s.save,
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
    required this.lang,
  });

  final Quote quote;
  final QuoteDeck deck;
  final FavoritesStore favorites;
  final LanguageController lang;

  @override
  Widget build(BuildContext context) {
    final s = lang.strings;
    final code = lang.locale.code;
    return Semantics(
      button: true,
      label: s.readQuoteBy(quote.author),
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
                lang: lang,
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
                '“${quote.textFor(code)}”',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: MuseType.body.copyWith(fontSize: 14, height: 1.6),
              ),
              const SizedBox(height: 6),
              Text(
                '${quote.author} · ${s.categoryLabel(quote.category)}'
                    .toUpperCase(),
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
