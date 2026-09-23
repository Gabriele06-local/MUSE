import 'package:flutter/material.dart';

/// Interaction tuning for the full-screen vertical discovery.
///
/// The data layer ([QuoteDeck]) is untouched by this config: the stage only
/// calls `onNext` / `onPrevious`. To switch the feel later, change one line
/// in `HomeScreen`:
///
/// ```dart
/// // Swipe-first, cinematic (default):
/// DiscoveryConfig.calm
/// // Tap-first, same architecture:
/// DiscoveryConfig.tapFirst
/// ```
class DiscoveryConfig {
  const DiscoveryConfig({
    required this.tapAdvances,
    required this.swipeEnabled,
    required this.inDuration,
    required this.outDuration,
    required this.inCurve,
    required this.outCurve,
    required this.slideDistance,
  });

  /// Tap advances (secondary). Vertical swipe is primary.
  final bool tapAdvances;

  /// Vertical swipe enabled. Keep true for the discovery metaphor.
  final bool swipeEnabled;

  /// Slow enough to feel intentional, fast enough to never feel sluggish.
  final Duration inDuration;
  final Duration outDuration;
  final Curve inCurve;
  final Curve outCurve;

  /// Vertical travel as a fraction of the viewport (0.08 = 8%).
  final double slideDistance;

  /// Default: swipe-first cinematic. Tap still works as a secondary gesture.
  static const calm = DiscoveryConfig(
    tapAdvances: true,
    swipeEnabled: true,
    inDuration: Duration(milliseconds: 550),
    outDuration: Duration(milliseconds: 300),
    inCurve: Curves.easeOutCubic,
    outCurve: Curves.easeIn,
    slideDistance: 0.08,
  );

  /// Tap-first variant. Same callbacks, same data layer — only the feel
  /// and hint change. Swipe stays on so users can still wander vertically.
  static const tapFirst = DiscoveryConfig(
    tapAdvances: true,
    swipeEnabled: true,
    inDuration: Duration(milliseconds: 420),
    outDuration: Duration(milliseconds: 260),
    inCurve: Curves.easeOutCubic,
    outCurve: Curves.easeIn,
    slideDistance: 0.06,
  );
}
