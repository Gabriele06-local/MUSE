import 'package:flutter/material.dart';

/// MUSE visual language: dark, cinematic, warm paper text, one gold accent.
abstract final class MuseColors {
  static const abyss = Color(0xFF07080D);
  static const room = Color(0xFF0D0F18);
  static const paper = Color(0xFFF2EDE4);
  static const muted = Color(0xFFB8B2C7);
  static const faint = Color(0xFF7E7794);
  static const gold = Color(0xFFD8B56B);
  static const violetGlow = Color(0xFF6D5BD0);
  static const tealGlow = Color(0xFF2DD4BF);
  static const hairline = Color(0x1FFFFFFF);
}

abstract final class MuseType {
  /// Refined serif stack without bundled fonts (zero extra deps, offline).
  /// Georgia/Palatino exist on iOS/macOS; Android falls back to serif.
  static const serifFallback = <String>[
    'Georgia',
    'Palatino Linotype',
    'Book Antiqua',
    'Palatino',
    'serif',
  ];

  static const sansFallback = <String>[
    'Inter',
    'Helvetica Neue',
    'Segoe UI',
    'Roboto',
    'sans-serif',
  ];

  static TextStyle quote(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    // Responsive clamp: 24–34sp, generous line height for museum calm.
    final size = (width * 0.065).clamp(24.0, 34.0);
    return TextStyle(
      fontFamily: 'Georgia',
      fontFamilyFallback: serifFallback,
      fontSize: size,
      height: 1.45,
      fontWeight: FontWeight.w400,
      color: MuseColors.paper,
      letterSpacing: 0.1,
    );
  }

  static const author = TextStyle(
    fontFamily: 'Georgia',
    fontFamilyFallback: serifFallback,
    fontSize: 17,
    height: 1.3,
    fontWeight: FontWeight.w600,
    color: MuseColors.paper,
    letterSpacing: 0.4,
  );

  static const meta = TextStyle(
    fontFamilyFallback: sansFallback,
    fontSize: 12,
    height: 1.5,
    fontWeight: FontWeight.w500,
    color: MuseColors.muted,
    letterSpacing: 1.6,
  );

  static const body = TextStyle(
    fontFamily: 'Georgia',
    fontFamilyFallback: serifFallback,
    fontSize: 16,
    height: 1.7,
    color: MuseColors.paper,
  );

  static const smallBody = TextStyle(
    fontFamilyFallback: sansFallback,
    fontSize: 14,
    height: 1.65,
    color: MuseColors.muted,
  );
}

ThemeData buildMuseTheme() {
  final scheme = const ColorScheme.dark(
    surface: MuseColors.abyss,
    primary: MuseColors.gold,
    onSurface: MuseColors.paper,
    secondary: MuseColors.muted,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: MuseColors.abyss,
    splashFactory: NoSplash.splashFactory,
    highlightColor: Colors.transparent,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      foregroundColor: MuseColors.paper,
    ),
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: MuseColors.gold,
      selectionColor: Color(0x44D8B56B),
    ),
  );
}
