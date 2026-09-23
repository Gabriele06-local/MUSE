# MUSE — a dreamy digital museum of quotes

Minimal, immersive Flutter app for discovering memorable quotes and short
biographies of remarkable people: Italian entrepreneurs first, plus
international builders, cinema and culture figures.

No backend. No login. No networking. Quotes live in `assets/quotes.json`
(+ `assets/quotes_it.json` for Italian content), favorites and language in
`SharedPreferences`.

## Run

```sh
flutter pub get
flutter run
```

## Structure

```
lib/
  main.dart            bootstrap
  app.dart             MuseApp + controller lifetime
  models/quote.dart    Quote + QuoteCategory (en base + optional it overrides)
  data/
    quote_repository.dart  local load + shuffle deck (no immediate repeats)
    favorites_store.dart   local favorites (ids only)
  i18n/
    muse_locale.dart       en/it enum
    muse_strings.dart      zero-dep UI strings, it falls back to en
    language_controller.dart persist + device detection (it → it, else en)
  ui/
    muse_theme.dart      cinematic dark theme, serif stack
    dream_background.dart gradients / breathing glow / grain (RepaintBoundary)
    discovery_config.dart tap-first ↔ swipe-first tuning (data layer untouched)
    discovery_stage.dart vertical viewport: swipe primary, tap secondary
    home_screen.dart     one quote per viewport, EN/IT toggle, room filters
    details_screen.dart  author bio + nearby rooms
    favorites_screen.dart saved collection
assets/quotes.json     2010 entries (en base)
assets/quotes_it.json  2010 Italian content overrides
tools/gen_batch*.py  dataset generation scripts (authors + EN/IT quotes)
```

## Dataset

- 2010 quotes, each in English and Italian: ~460 Italian Entrepreneurs,
  ~687 International Entrepreneurs, ~517 Cinema, ~346 Culture.
- The first 30 entries are hand-verified; the extended collection gathers
  widely-circulated sayings — `source` is marked `Attributed` wherever a
  primary source is uncertain.
- Loader merges both files at startup; Italian falls back to English per
  field when an override is missing.

## Design notes

- One quote at a time, generous spacing, serif typography (Georgia stack,
  zero font downloads so the app stays offline).
- One quote per viewport: vertical swipe wanders (primary), tap advances
  (secondary). No free-scrolling list — a single child cross-fades with
  direction-aware travel (550ms in / 300ms out, `easeOutCubic`).
  `DiscoveryConfig.calm` ↔ `tapFirst` swaps the feel in one line.
- Transitions: single `AnimatedSwitcher`, fade + 8% vertical slide + whisper
  of scale. Background glow animates opacity-only on a 7s loop, isolated in
  its own `RepaintBoundary`. Grain is a seeded static field.
- Deckreshuffles with Fisher–Yates and guarantees the first item of a new
  cycle differs from the last shown — no immediate repetition, no repeats
  within a cycle.
- Accessibility: warm-paper on near-black (~15:1), live-region quote,
  semantic buttons, `MediaQuery.textScaler` respected, 52px touch targets.
