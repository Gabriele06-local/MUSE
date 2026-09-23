import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/favorites_store.dart';
import '../data/quote_repository.dart';
import '../models/quote.dart';
import 'details_screen.dart';
import 'dream_background.dart';
import 'favorites_screen.dart';
import 'muse_theme.dart';

/// The single-room museum view: one quote, one gesture, pure calm.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.deck, required this.favorites});

  final QuoteDeck deck;
  final FavoritesStore favorites;

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
                        _TopBar(deck: deck, favorites: favorites),
                        const SizedBox(height: 14),
                        _FilterRow(deck: deck),
                        Expanded(
                          child: _QuoteStage(
                            deck: deck,
                            favorites: favorites,
                          ),
                        ),
                        _BottomBar(deck: deck, favorites: favorites),
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
  const _TopBar({required this.deck, required this.favorites});

  final QuoteDeck deck;
  final FavoritesStore favorites;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Semantics(
          header: true,
          child: Text(
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
          listenable: favorites,
          builder: (context, _) {
            final count = favorites.count;
            return Semantics(
              button: true,
              label: 'Open saved quotes, $count saved',
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
                        semanticLabel: 'Saved',
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
        pageBuilder: (_, _, _) =>
            FavoritesScreen(deck: deck, favorites: favorites),
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

class _FilterRow extends StatelessWidget {
  const _FilterRow({required this.deck});

  final QuoteDeck deck;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: deck,
      builder: (context, _) {
        final current = deck.filter;
        final items = <QuoteCategory?>[null, ...QuoteCategory.values];
        return Semantics(
          label: 'Filter by room',
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (var i = 0; i < items.length; i++) ...[
                  _FilterPill(
                    label: items[i] == null ? 'All' : items[i]!.label,
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
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: 'Show $label',
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

class _QuoteStage extends StatefulWidget {
  const _QuoteStage({required this.deck, required this.favorites});

  final QuoteDeck deck;
  final FavoritesStore favorites;

  @override
  State<_QuoteStage> createState() => _QuoteStageState();
}

class _QuoteStageState extends State<_QuoteStage> {
  double _dragX = 0;

  void _next() {
    HapticFeedback.lightImpact();
    widget.deck.next();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.deck,
      builder: (context, _) {
        final quote = widget.deck.current;
        if (!widget.deck.loaded) {
          return const Center(
            child: Text(
              'Opening the rooms…',
              style: MuseType.smallBody,
              semanticsLabel: 'Loading quotes',
            ),
          );
        }
        if (quote == null) {
          return const Center(
            child: Text(
              'This room is empty.',
              style: MuseType.smallBody,
            ),
          );
        }
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _next,
          onHorizontalDragUpdate: (d) =>
              setState(() => _dragX = d.primaryDelta ?? 0),
          onHorizontalDragEnd: (d) {
            final v = d.primaryVelocity ?? 0;
            if (v < -220 || _dragX < -40) {
              _next();
            } else if ((v > 220 || _dragX > 40) && widget.deck.canGoBack) {
              HapticFeedback.lightImpact();
              widget.deck.previous();
            }
            _dragX = 0;
          },
          child: Semantics(
            liveRegion: true,
            label: 'Quote by ${quote.author}. ${quote.text}',
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 480),
              reverseDuration: const Duration(milliseconds: 300),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeIn,
              layoutBuilder: (current, previous) =>
                  Stack(children: [...previous, if (current != null) current]),
              transitionBuilder: (child, animation) {
                final fade = FadeTransition(opacity: animation, child: child);
                final slide = SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.06),
                    end: Offset.zero,
                  ).animate(animation),
                  child: fade,
                );
                return slide;
              },
              child: RepaintBoundary(
                key: ValueKey('quote-${quote.id}'),
                child: _QuoteComposition(quote: quote),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _QuoteComposition extends StatelessWidget {
  const _QuoteComposition({required this.quote});

  final Quote quote;

  @override
  Widget build(BuildContext context) {
    final scaler = MediaQuery.textScalerOf(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            quote.category.room.toUpperCase(),
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
                '“${quote.text}”',
                textAlign: TextAlign.center,
                style: MuseType.quote(context),
                semanticsLabel: quote.text,
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
              if (quote.role.isNotEmpty) quote.role,
              if (quote.years.isNotEmpty) quote.years,
            ].join('  ·  '),
            textAlign: TextAlign.center,
            style: MuseType.meta.copyWith(fontSize: 11),
          ),
          // Keep source discoverable but quiet.
          if (quote.source.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              quote.source,
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
  const _BottomBar({required this.deck, required this.favorites});

  final QuoteDeck deck;
  final FavoritesStore favorites;

  @override
  Widget build(BuildContext context) {
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
                  semanticLabel: fav
                      ? 'Remove from saved'
                      : 'Save this quote',
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
              listenable: deck,
              builder: (context, _) {
                final q = deck.current;
                return _CircleAction(
                  semanticLabel: 'Read life of ${q?.author ?? "author"}',
                  icon: Icons.auto_stories_outlined,
                  onTap: q == null ? null : () => _openDetails(context, q),
                );
              },
            ),
            const SizedBox(width: 14),
            _CircleAction(
              semanticLabel: 'Reveal another quote',
              icon: Icons.arrow_forward_rounded,
              primary: true,
              onTap: () {
                HapticFeedback.lightImpact();
                deck.next();
              },
            ),
          ],
        ),
        const SizedBox(height: 14),
        const Text(
          'Tap anywhere · Swipe for another room',
          style: TextStyle(
            fontFamilyFallback: MuseType.sansFallback,
            fontSize: 11,
            letterSpacing: 1.4,
            color: MuseColors.faint,
          ),
        ),
      ],
    );
  }

  void _openDetails(BuildContext context, Quote quote) {
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 420),
        reverseTransitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (_, _, _) => DetailsScreen(
          quote: quote,
          deck: deck,
          favorites: favorites,
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
