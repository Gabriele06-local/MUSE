import 'dart:math' as math;
import 'package:flutter/material.dart';

import 'muse_theme.dart';

/// Cinematic backdrop: layered gradients, one breathing glow, film grain.
///
/// Performance notes:
/// - Static layers are const / [RepaintBoundary] isolated and paint once.
/// - Only [BreathingGlow] animates, at 7s period, opacity-only (cheap).
/// - Grain is a fixed seeded dot field (~500 dots), painted once.
class DreamBackground extends StatelessWidget {
  const DreamBackground({super.key, this.child});

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF0B0C14), MuseColors.abyss, Color(0xFF05060A)],
              stops: [0.0, 0.55, 1.0],
            ),
          ),
        ),
        const RepaintBoundary(
          child: CustomPaint(painter: _GlowPainter(), size: Size.infinite),
        ),
        const RepaintBoundary(child: BreathingGlow()),
        const RepaintBoundary(
          child: CustomPaint(painter: _GrainPainter(), size: Size.infinite),
        ),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.center,
              radius: 1.1,
              colors: [Colors.transparent, Color(0x66000000)],
              stops: [0.55, 1.0],
            ),
          ),
        ),
        if (child != null) child!,
      ],
    );
  }
}

class _GlowPainter extends CustomPainter {
  const _GlowPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Violet aura, top.
    final violet = RadialGradient(
      colors: [MuseColors.violetGlow.withValues(alpha: 0.20), Colors.transparent],
    ).createShader(Rect.fromCircle(center: Offset(w * 0.5, -h * 0.08), radius: w * 0.9));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), Paint()..shader = violet);

    // Warm gold heart, center — very faint.
    final gold = RadialGradient(
      colors: [MuseColors.gold.withValues(alpha: 0.10), Colors.transparent],
    ).createShader(
      Rect.fromCircle(center: Offset(w * 0.5, h * 0.46), radius: w * 0.7),
    );
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), Paint()..shader = gold);

    // Teal floor glow.
    final teal = RadialGradient(
      colors: [MuseColors.tealGlow.withValues(alpha: 0.07), Colors.transparent],
    ).createShader(
      Rect.fromCircle(center: Offset(w * 0.5, h * 1.08), radius: w * 0.85),
    );
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), Paint()..shader = teal);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Single slow "breathing" halo behind the quote. Opacity-only animation.
class BreathingGlow extends StatefulWidget {
  const BreathingGlow({super.key});

  @override
  State<BreathingGlow> createState() => _BreathingGlowState();
}

class _BreathingGlowState extends State<BreathingGlow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 7),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        final t = (0.5 + 0.5 * math.sin(_ctrl.value * 2 * math.pi - math.pi / 2));
        final opacity = 0.35 + 0.30 * t; // 0.35 → 0.65
        return CustomPaint(
          painter: _BreathPainter(opacity: opacity),
          size: Size.infinite,
        );
      },
    );
  }
}

class _BreathPainter extends CustomPainter {
  const _BreathPainter({required this.opacity});
  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    final shader = RadialGradient(
      colors: [
        MuseColors.violetGlow.withValues(alpha: 0.12 * opacity + 0.04),
        Colors.transparent,
      ],
    ).createShader(
      Rect.fromCircle(
        center: Offset(size.width * 0.5, size.height * 0.42),
        radius: size.width * 0.62,
      ),
    );
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..shader = shader,
    );
  }

  @override
  bool shouldRepaint(covariant _BreathPainter oldDelegate) =>
      oldDelegate.opacity != opacity;
}

class _GrainPainter extends CustomPainter {
  const _GrainPainter();

  @override
  void paint(Canvas canvas, Size size) {
    // Deterministic grain so it paints identically every frame (once).
    final rng = math.Random(7);
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.028);
    final count = 450;
    for (var i = 0; i < count; i++) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height;
      final r = 0.4 + rng.nextDouble() * 0.9;
      canvas.drawCircle(Offset(x, y), r, paint);
    }
    // A few warm specks.
    final gold = Paint()..color = MuseColors.gold.withValues(alpha: 0.05);
    for (var i = 0; i < 40; i++) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height;
      canvas.drawCircle(Offset(x, y), 0.7, gold);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
