import 'package:flutter/material.dart';

import '../data/favorites_store.dart';
import '../data/quote_repository.dart';
import '../i18n/language_controller.dart';
import 'details_screen.dart';
import 'dream_background.dart';
import 'muse_theme.dart';

/// Minimal author search across the whole collection.
///
/// Tapping an author opens their biography room (first quote). Deck
/// position is preserved — search never reshuffles.
class SearchScreen extends StatefulWidget {
  const SearchScreen({
    super.key,
    required this.deck,
    required this.favorites,
    required this.lang,
  });

  final QuoteDeck deck;
  final FavoritesStore favorites;
  final LanguageController lang;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.lang,
      builder: (context, _) {
        final s = widget.lang.strings;
        final code = widget.lang.locale.code;
        final q = _query.trim().toLowerCase();
        final authors = widget.deck.authors
            .where((a) => q.isEmpty || a.toLowerCase().contains(q))
            .toList(growable: false);
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
                              label: s.back,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(24),
                                onTap: () =>
                                    Navigator.of(context).pop(),
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
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        s.rooms,
                                        style: MuseType.meta,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              s.searchTitle.toUpperCase(),
                              style: const TextStyle(
                                fontFamilyFallback:
                                    MuseType.sansFallback,
                                fontSize: 11,
                                letterSpacing: 4,
                                color: MuseColors.faint,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Semantics(
                          label: s.searchLabel,
                          textField: true,
                          child: TextField(
                            controller: _controller,
                            autofocus: true,
                            onChanged: (v) =>
                                setState(() => _query = v),
                            style: MuseType.body.copyWith(fontSize: 17),
                            cursorColor: MuseColors.gold,
                            decoration: InputDecoration(
                              hintText: s.searchHint,
                              hintStyle: MuseType.smallBody.copyWith(
                                color: MuseColors.faint,
                              ),
                              prefixIcon: const Icon(
                                Icons.search_rounded,
                                size: 19,
                                color: MuseColors.faint,
                              ),
                              filled: true,
                              fillColor: Colors.white.withValues(
                                alpha: 0.03,
                              ),
                              contentPadding:
                                  const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 14,
                                  ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4),
                                borderSide: const BorderSide(
                                  color: MuseColors.hairline,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4),
                                borderSide: BorderSide(
                                  color: MuseColors.gold.withValues(
                                    alpha: 0.55,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: authors.isEmpty
                              ? Center(
                                  child: Text(
                                    s.noAuthors,
                                    style: MuseType.smallBody,
                                  ),
                                )
                              : ListView.separated(
                                  itemCount: authors.length,
                                  separatorBuilder: (_, _) =>
                                      const Divider(
                                        color: MuseColors.hairline,
                                        height: 1,
                                      ),
                                  itemBuilder: (context, i) {
                                    final name = authors[i];
                                    final first = widget.deck
                                        .firstByAuthor(name);
                                    if (first == null) {
                                      return const SizedBox
                                          .shrink();
                                    }
                                    final n = widget.deck
                                        .quotesByAuthor(name)
                                        .length;
                                    final role = first
                                        .roleFor(code);
                                    return Semantics(
                                      button: true,
                                      label: s.openQuoteBy(name),
                                      child: InkWell(
                                        onTap: () {
                                          Navigator.of(context)
                                              .push(
                                            PageRouteBuilder<
                                                void>(
                                              transitionDuration:
                                                  const Duration(
                                                    milliseconds:
                                                        350,
                                                  ),
                                              pageBuilder: (
                                                _,
                                                _,
                                                _,
                                              ) =>
                                                  DetailsScreen(
                                                quote: first,
                                                deck: widget.deck,
                                                favorites:
                                                    widget.favorites,
                                                lang: widget.lang,
                                              ),
                                              transitionsBuilder: (
                                                _,
                                                anim,
                                                _,
                                                child,
                                              ) =>
                                                  FadeTransition(
                                                opacity: anim,
                                                child: child,
                                              ),
                                            ),
                                          );
                                        },
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.symmetric(
                                            vertical: 14,
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment
                                                    .start,
                                            children: [
                                              Text(
                                                name,
                                                style: MuseType.body
                                                    .copyWith(
                                                  fontSize: 16,
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 4,
                                              ),
                                              Text(
                                                [
                                                  if (role
                                                      .isNotEmpty)
                                                    role,
                                                  s.quotesCount(
                                                    n,
                                                  ),
                                                ].join('  ·  ').toUpperCase(),
                                                style:
                                                    MuseType.meta.copyWith(
                                                  fontSize: 10,
                                                  color:
                                                      MuseColors.faint,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
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
      },
    );
  }
}
