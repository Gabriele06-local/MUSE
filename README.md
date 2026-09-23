# MUSE — a dreamy digital museum of quotes

Minimal, immersive Flutter app for discovering memorable quotes and short
biographies of remarkable people: Italian entrepreneurs first, plus
international builders, cinema and culture figures.

No backend. No login. No networking. Quotes live in `assets/quotes.json`,
favorites in `SharedPreferences`.

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
  models/quote.dart    Quote + QuoteCategory
  data/
    quote_repository.dart  local load + shuffle deck (no immediate repeats)
    favorites_store.dart   local favorites (ids only)
  ui/
    muse_theme.dart      cinematic dark theme, serif stack
    dream_background.dart gradients / breathing glow / grain (RepaintBoundary)
    home_screen.dart     one quote, tap/swipe, 480ms fade+slide
    details_screen.dart  author bio + nearby rooms
    favorites_screen.dart saved collection
assets/quotes.json     30 curated entries
```

## Design notes

- One quote at a time, generous spacing, serif typography (Georgia stack,
  zero font downloads so the app stays offline).
- Transitions: single `AnimatedSwitcher`, fade + 6% slide, `easeOutCubic`.
  Background glow animates opacity-only on a 7s loop, isolated in its own
  `RepaintBoundary`. Grain is a seeded static field.
- Deckreshuffles with Fisher–Yates and guarantees the first item of a new
  cycle differs from the last shown — no immediate repetition, no repeats
  within a cycle.
- Accessibility: warm-paper on near-black (~15:1), live-region quote,
  semantic buttons, `MediaQuery.textScaler` respected, 52px touch targets.
