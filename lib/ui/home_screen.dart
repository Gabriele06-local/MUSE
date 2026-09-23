import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/favorites_store.dart';
import '../data/quote_repository.dart';
import '../i18n/language_controller.dart';
import '../i18n/muse_locale.dart';
import '../models/quote.dart';
import 'details_screen.dart';
import 'discovery_config.dart';
import 'discovery_stage.dart';
import 'dream_background.dart';
import 'favorites_screen.dart';
import 'muse_theme.dart';

/// The museum view: one quote fills the viewport.
///
/// Vertical swipe wanders (primary), tap advances (secondary). The stage is
/// driven by [DiscoveryConfig] so the feel can change without touching the
/// data layer. Returning from details preserves [QuoteDeck.current].
class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.deck,
    required this.favorites,
    required this.lang,
  });

  final QuoteDeck deck;
  final FavoritesStore favorites;
  final LanguageController lang;

  /// Swap to [DiscoveryConfig.tapFirst] for a tap-led feel. Data layer
  /// untouched.
  static const discovery = DiscoveryConfig.calm;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DreamBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final horizontal = (constraints.maxWidth * 0.08).clamp(20.0, 40.0);
              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 640),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: horizontal),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 8),
                        _TopBar(
                          deck: deck,
                          favorites: favorites,
                          lang: lang,
                        ),
                        const SizedBox(height: 14),
                        _FilterRow(deck: deck, lang: lang),
                        Expanded(
                          child: _QuoteViewport(
                            deck: deck,
                            lang: lang,
                          ),
                        ),
                        _BottomBar(
                          deck: deck,
                          favorites: favorites,
                          lang: lang,
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
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

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.deck,
    required this.favorites,
    required this.lang,
  });

  final QuoteDeck deck;
  final FavoritesStore favorites;
  final LanguageController lang;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Semantics(
          header: true,
          child: const Text(
            'MUSE',
            style: TextStyle(
              fontFamilyFallback: MuseType.sansFallback,
              fontSize: 15,
              letterSpacing: 8,
              fontWeight: FontWeight.w600,
              color: MuseColors.paper,
            ),
          ),
        ),
        const Spacer(),
        ListenableBuilder(
          listenable: lang,
          builder: (context, _) {
            final s = lang.strings;
            final isIt = lang.locale == MuseLocale.it;
            return Semantics(
              button: true,
              label: s.languageSemantic(lang.locale.nativeName),
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  lang.toggle();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: MuseColors.hairline),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _LangChip(label: 'EN', selected: !isIt),
                      _LangChip(label: 'IT', selected: isIt),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(width: 8),
        ListenableBuilder(
          listenable: Listenable.merge([favorites, lang]),
          builder: (context, _) {
            final s = lang.strings;
            final count = favorites.count;
            return Semantics(
              button: true,
              label: s.openSaved(count),
              child: InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: () => _openFavorites(context),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.bookmark_border_rounded,
                        size: 18,
                        color: MuseColors.muted,
                      ),
                      if (count > 0) ...[
                        const SizedBox(width: 6),
                        Text(
                          '$count',
                          style: MuseType.meta.copyWith(
                            color: MuseColors.gold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  void _openFavorites(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 380),
        reverseTransitionDuration: const Duration(milliseconds: 280),
        pageBuilder: (_, _, _) => FavoritesScreen(
          deck: deck,
          favorites: favorites,
          lang: lang,
        ),
        transitionsBuilder: (_, anim, _, child) {
          final curved = CurvedAnimation(
            parent: anim,
            curve: Curves.easeOutCubic,
          );
          return FadeTransition(opacity: curved, child: child);
        },
      ),
    );
  }
}

class _LangChip extends StatelessWidget {
  const _LangChip({required this.label, required this.selected});

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: selected
            ? MuseColors.gold.withValues(alpha: 0.18)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        label,
        style: MuseType.meta.copyWith(
          fontSize: 11,
          letterSpacing: 1,
          color: selected ? MuseColors.paper : MuseColors.faint,
        ),
      ),
    );
  }
}

class _FilterRow extends StatelessWidget {
  const _FilterRow({required this.deck, required this.lang});

  final QuoteDeck deck;
  final LanguageController lang;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([deck, lang]),
      builder: (context, _) {
        final s = lang.strings;
        final current = deck.filter;
        final items = <QuoteCategory?>[null, ...QuoteCategory.values];
        String labelFor(QuoteCategory? c) =>
            c == null ? s.showAll : s.categoryLabel(c);
        return Semantics(
          label: s.filterRooms,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (var i = 0; i < items.length; i++) ...[
                  _FilterPill(
                    label: labelFor(items[i]),
                    semanticLabel: s.showLabel(labelFor(items[i])),
                    selected: current == items[i],
                    onTap: () => deck.setFilter(items[i]),
                  ),
                  if (i != items.length - 1) const SizedBox(width: 8),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _FilterPill extends StatelessWidget {
  const _FilterPill({
    required this.label,
    required this.semanticLabel,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String semanticLabel;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: semanticLabel,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            color: selected
                ? MuseColors.gold.withValues(alpha: 0.14)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected
                  ? MuseColors.gold.withValues(alpha: 0.55)
                  : MuseColors.hairline,
              width: 1,
            ),
          ),
          child: Text(
            label,
            style: MuseType.meta.copyWith(
              color: selected ? MuseColors.paper : MuseColors.muted,
              fontSize: 11,
            ),
          ),
        ),
      ),
    );
  }
}

/// Vertical discovery viewport. Delegates feel to [DiscoveryStage] so the
/// data layer ([QuoteDeck]) never cares whether tap or swipe leads.
class _QuoteViewport extends StatelessWidget {
  const _QuoteViewport({required this.deck, required this.lang});

  final QuoteDeck deck;
  final LanguageController lang;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([deck, lang]),
      builder: (context, _) {
        final s = lang.strings;
        final code = lang.locale.code;
        final quote = deck.current;
        if (!deck.loaded) {
          return Center(
            child: Text(
              s.loading,
              style: MuseType.smallBody,
              semanticsLabel: s.loadingSemantic,
            ),
          );
        }
        if (deck.error != null) {
          return Center(
            child: Text(s.loadError, style: MuseType.smallBody),
          );
        }
        if (quote == null) {
          return Center(
            child: Text(s.emptyRoom, style: MuseType.smallBody),
          );
        }
        final text = quote.textFor(code);
        return DiscoveryStage(
          config: HomeScreen.discovery,
          transitionKey: ValueKey('quote-${quote.id}-$code'),
          canGoPrevious: deck.canGoBack,
          onNext: deck.next,
          onPrevious: deck.previous,
          semanticLabel: s.quoteSemantic(quote.author, text),
          semanticHint: s.swipeHintSemantic,
          child: _QuoteComposition(quote: quote, lang: lang),
        );
      },
    );
  }
}

class _QuoteComposition extends StatelessWidget {
  const _QuoteComposition({required this.quote, required this.lang});

  final Quote quote;
  final LanguageController lang;

  @override
  Widget build(BuildContext context) {
    final s = lang.strings;
    final code = lang.locale.code;
    final text = quote.textFor(code);
    final role = quote.roleFor(code);
    final source = quote.sourceFor(code);
    final scaler = MediaQuery.textScalerOf(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            s.roomName(quote.category).toUpperCase(),
            textAlign: TextAlign.center,
            style: MuseType.meta.copyWith(
              color: MuseColors.gold.withValues(alpha: 0.9),
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 22),
          Flexible(
            child: SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              child: Text(
                '“$text”',
                textAlign: TextAlign.center,
                style: MuseType.quote(context),
                semanticsLabel: text,
              ),
            ),
          ),
          const SizedBox(height: 26),
          Container(
            width: 28,
            height: 1,
            color: MuseColors.gold.withValues(alpha: 0.6),
          ),
          const SizedBox(height: 18),
          Text(
            quote.author,
            textAlign: TextAlign.center,
            style: MuseType.author,
          ),
          const SizedBox(height: 6),
          Text(
            [
              if (role.isNotEmpty) role,
              if (quote.years.isNotEmpty) quote.years,
            ].join('  ·  '),
            textAlign: TextAlign.center,
            style: MuseType.meta.copyWith(fontSize: 11),
          ),
          if (source.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              source,
              textAlign: TextAlign.center,
              maxLines: scaler.scale(14) > 20 ? 3 : 2,
              overflow: TextOverflow.ellipsis,
              style: MuseType.meta.copyWith(
                color: MuseColors.faint,
                fontSize: 10.5,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.deck,
    required this.favorites,
    required this.lang,
  });

  final QuoteDeck deck;
  final FavoritesStore favorites;
  final LanguageController lang;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: lang,
      builder: (context, _) {
        final s = lang.strings;
        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ListenableBuilder(
                  listenable: Listenable.merge([deck, favorites]),
                  builder: (context, _) {
                    final q = deck.current;
                    final fav = q != null && favorites.isFavorite(q.id);
                    return _CircleAction(
                      semanticLabel: fav ? s.unsave : s.save,
                      icon: fav ? Icons.favorite : Icons.favorite_border,
                      active: fav,
                      onTap: q == null
                          ? null
                          : () {
                              HapticFeedback.selectionClick();
                              favorites.toggle(q.id);
                            },
                    );
                  },
                ),
                const SizedBox(width: 14),
                ListenableBuilder(
                  listenable: Listenable.merge([deck, lang]),
                  builder: (context, _) {
                    final q = deck.current;
                    return _CircleAction(
                      semanticLabel: s.readLife(q?.author ?? ''),
                      icon: Icons.auto_stories_outlined,
                      onTap: q == null
                          ? null
                          : () => _openDetails(context, q),
                    );
                  },
                ),
                const SizedBox(width: 14),
                _CircleAction(
                  semanticLabel: s.revealNext,
                  icon: Icons.keyboard_arrow_up_rounded,
                  primary: true,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    deck.next();
                  },
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              s.hint,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamilyFallback: MuseType.sansFallback,
                fontSize: 11,
                letterSpacing: 1.4,
                color: MuseColors.faint,
              ),
            ),
          ],
        );
      },
    );
  }

  void _openDetails(BuildContext context, Quote quote) {
    // Deck position is untouched: returning pops back to the same quote.
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 420),
        reverseTransitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (_, _, _) => DetailsScreen(
          quote: quote,
          deck: deck,
          favorites: favorites,
          lang: lang,
        ),
        transitionsBuilder: (_, anim, _, child) {
          final curved = CurvedAnimation(
            parent: anim,
            curve: Curves.easeOutCubic,
          );
          return FadeTransition(
            opacity: curved,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.04),
                end: Offset.zero,
              ).animate(curved),
              child: child,
            ),
          );
        },
      ),
    );
  }
}

class _CircleAction extends StatelessWidget {
  const _CircleAction({
    required this.icon,
    required this.semanticLabel,
    this.onTap,
    this.active = false,
    this.primary = false,
  });

  final IconData icon;
  final String semanticLabel;
  final VoidCallback? onTap;
  final bool active;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    final border = active || primary
        ? MuseColors.gold.withValues(alpha: 0.6)
        : MuseColors.hairline;
    final bg = primary
        ? MuseColors.gold.withValues(alpha: 0.16)
        : active
            ? MuseColors.gold.withValues(alpha: 0.12)
            : Colors.white.withValues(alpha: 0.03);
    return Semantics(
      button: true,
      enabled: onTap != null,
      label: semanticLabel,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Ink(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: bg,
              border: Border.all(color: border),
            ),
            child: Icon(
              icon,
              size: 21,
              color: active || primary ? MuseColors.gold : MuseColors.paper,
              semanticLabel: semanticLabel,
            ),
          ),
        ),
      ),
    );
  }
}
