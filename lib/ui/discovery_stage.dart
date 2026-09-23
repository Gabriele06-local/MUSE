import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'discovery_config.dart';

/// Full-screen vertical discovery viewport.
///
/// One quote occupies the viewport. Vertical swipe reveals next/previous,
/// tap advances as a secondary interaction. No free-scrolling list: a single
/// child cross-fades with a cinematic vertical travel.
///
/// Deliberately decoupled from the data layer: it only needs a
/// [transitionKey], directional callbacks and a [child] builder. Swapping
/// between tap-first and swipe-first is a [DiscoveryConfig] change.
class DiscoveryStage extends StatefulWidget {
  const DiscoveryStage({
    super.key,
    required this.config,
    required this.transitionKey,
    required this.canGoPrevious,
    required this.onNext,
    required this.onPrevious,
    required this.semanticLabel,
    required this.semanticHint,
    required this.child,
  });

  final DiscoveryConfig config;
  final ValueKey<String> transitionKey;
  final bool canGoPrevious;
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final String semanticLabel;
  final String semanticHint;
  final Widget child;

  @override
  State<DiscoveryStage> createState() => _DiscoveryStageState();
}

class _DiscoveryStageState extends State<DiscoveryStage> {
  /// +1 entering from below (next), -1 from above (previous).
  int _direction = 1;
  double _dragDy = 0;

  void _goNext() {
    _direction = 1;
    HapticFeedback.lightImpact();
    widget.onNext();
  }

  void _goPrevious() {
    _direction = -1;
    HapticFeedback.lightImpact();
    widget.onPrevious();
  }

  @override
  Widget build(BuildContext context) {
    final config = widget.config;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: config.tapAdvances ? _goNext : null,
      onVerticalDragUpdate: config.swipeEnabled
          ? (d) => _dragDy = d.primaryDelta ?? 0
          : null,
      onVerticalDragEnd: config.swipeEnabled
          ? (d) {
              final v = d.primaryVelocity ?? 0;
              if (v < -220 || _dragDy < -40) {
                _goNext();
              } else if ((v > 220 || _dragDy > 40) &&
                  widget.canGoPrevious) {
                _goPrevious();
              }
              _dragDy = 0;
            }
          : null,
      child: Semantics(
        container: true,
        liveRegion: true,
        label: widget.semanticLabel,
        hint: widget.semanticHint,
        onIncrease: _goNext,
        onDecrease: widget.canGoPrevious ? _goPrevious : null,
        child: AnimatedSwitcher(
          duration: config.inDuration,
          reverseDuration: config.outDuration,
          switchInCurve: config.inCurve,
          switchOutCurve: config.outCurve,
          layoutBuilder: (current, previous) =>
              Stack(children: [...previous, if (current != null) current]),
          transitionBuilder: (child, animation) {
            // Direction-aware vertical travel + fade + whisper of scale.
            final begin = Offset(0, config.slideDistance * _direction);
            final slide = SlideTransition(
              position: Tween<Offset>(begin: begin, end: Offset.zero)
                  .animate(animation),
              child: FadeTransition(
                opacity: animation,
                child: ScaleTransition(
                  scale: Tween<double>(begin: 0.985, end: 1.0)
                      .animate(animation),
                  child: child,
                ),
              ),
            );
            return slide;
          },
          child: RepaintBoundary(
            key: widget.transitionKey,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
