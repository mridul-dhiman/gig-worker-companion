import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../l10n/strings.dart';

/// Indigo "uniform" ink with a marigold accent.
@immutable
class SaathiColors extends ThemeExtension<SaathiColors> {
  const SaathiColors({
    required this.paper,
    required this.surface,
    required this.sunken,
    required this.ink,
    required this.muted,
    required this.line,
    required this.marigold,
    required this.marigoldInk,
    required this.onMarigold,
    required this.good,
    required this.goodBg,
    required this.bad,
    required this.badBg,
    required this.hold,
    required this.holdBg,
    required this.bar,
    required this.onBar,
  });

  final Color paper, surface, sunken, ink, muted, line;
  final Color marigold, marigoldInk, onMarigold;
  final Color good, goodBg, bad, badBg, hold, holdBg;
  final Color bar, onBar;

  static const light = SaathiColors(
    paper: Color(0xFFF3F4F9),
    surface: Color(0xFFFFFFFF),
    sunken: Color(0xFFE9EBF4),
    ink: Color(0xFF1A1E3D),
    muted: Color(0xFF5A6086),
    line: Color(0xFFD8DBEA),
    marigold: Color(0xFFEFA20E),
    marigoldInk: Color(0xFF9A5F00),
    onMarigold: Color(0xFF1A1E3D),
    good: Color(0xFF1D7F55),
    goodBg: Color(0xFFE1F3EA),
    bad: Color(0xFFB83227),
    badBg: Color(0xFFFBE6E3),
    hold: Color(0xFF5A6086),
    holdBg: Color(0xFFECEDF5),
    bar: Color(0xFF1A1E3D),
    onBar: Color(0xFFF3F4F9),
  );

  static const dark = SaathiColors(
    paper: Color(0xFF0F1229),
    surface: Color(0xFF171B38),
    sunken: Color(0xFF20254A),
    ink: Color(0xFFECEEF9),
    muted: Color(0xFF9CA2C6),
    line: Color(0xFF2B3060),
    marigold: Color(0xFFF5B532),
    marigoldInk: Color(0xFFF5B532),
    onMarigold: Color(0xFF14172F),
    good: Color(0xFF57C997),
    goodBg: Color(0xFF173A33),
    bad: Color(0xFFF2786C),
    badBg: Color(0xFF3D1E2A),
    hold: Color(0xFFA7ADD0),
    holdBg: Color(0xFF242952),
    bar: Color(0xFF090B1E),
    onBar: Color(0xFFECEEF9),
  );

  @override
  SaathiColors copyWith() => this;

  @override
  SaathiColors lerp(ThemeExtension<SaathiColors>? other, double t) => t < .5 ? this : (other as SaathiColors? ?? this);
}

extension SaathiContext on BuildContext {
  SaathiColors get sc => Theme.of(this).extension<SaathiColors>()!;
}

/// Font roles. Punjabi switches to Gurmukhi-capable families.
class AppFonts {
  /// Turned off in tests, where fonts cannot be fetched.
  static bool useGoogleFonts = true;

  static TextStyle display(AppLang l, {double size = 22, FontWeight weight = FontWeight.w700, Color? color}) {
    final base = TextStyle(fontSize: size, fontWeight: weight, color: color, height: 1.15);
    if (!useGoogleFonts) return base;
    return l == AppLang.pa ? GoogleFonts.balooPaaji2(textStyle: base) : GoogleFonts.baloo2(textStyle: base);
  }

  static TextStyle body(AppLang l, {double size = 16, FontWeight weight = FontWeight.w400, Color? color, double height = 1.45}) {
    final base = TextStyle(fontSize: size, fontWeight: weight, color: color, height: height);
    if (!useGoogleFonts) return base;
    return l == AppLang.pa ? GoogleFonts.muktaMahee(textStyle: base) : GoogleFonts.mukta(textStyle: base);
  }

  static TextStyle mono({double size = 13, Color? color, FontWeight weight = FontWeight.w400}) {
    final base = TextStyle(fontSize: size, color: color, fontWeight: weight, height: 1.5);
    if (!useGoogleFonts) return base.copyWith(fontFamily: 'monospace');
    return GoogleFonts.ibmPlexMono(textStyle: base);
  }
}

ThemeData buildTheme(Brightness b, AppLang lang) {
  final c = b == Brightness.light ? SaathiColors.light : SaathiColors.dark;
  final scheme = ColorScheme.fromSeed(
    seedColor: const Color(0xFF1A1E3D),
    brightness: b,
  ).copyWith(
    primary: c.ink,
    onPrimary: c.paper,
    secondary: c.marigold,
    onSecondary: c.onMarigold,
    surface: c.surface,
    onSurface: c.ink,
    error: c.bad,
  );
  final bodyStyle = AppFonts.body(lang, color: c.ink);
  return ThemeData(
    useMaterial3: true,
    brightness: b,
    colorScheme: scheme,
    scaffoldBackgroundColor: c.paper,
    extensions: [c],
    textTheme: TextTheme(
      bodyLarge: bodyStyle,
      bodyMedium: bodyStyle.copyWith(fontSize: 15),
      bodySmall: bodyStyle.copyWith(fontSize: 13, color: c.muted),
      titleMedium: AppFonts.display(lang, size: 19, color: c.ink),
      titleLarge: AppFonts.display(lang, size: 24, weight: FontWeight.w800, color: c.ink),
      labelLarge: AppFonts.body(lang, size: 16, weight: FontWeight.w700),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: c.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: c.line, width: 1.5)),
      enabledBorder:
          OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: c.line, width: 1.5)),
      focusedBorder:
          OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: c.marigold, width: 2)),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: c.ink,
        foregroundColor: c.paper,
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: AppFonts.body(lang, size: 17, weight: FontWeight.w700),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: c.ink,
        minimumSize: const Size(0, 44),
        side: BorderSide(color: c.line, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: AppFonts.body(lang, size: 15, weight: FontWeight.w600),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: c.ink,
      contentTextStyle: AppFonts.body(lang, size: 15, weight: FontWeight.w600, color: c.paper),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: c.surface,
      indicatorColor: c.marigold,
      labelTextStyle: WidgetStatePropertyAll(AppFonts.body(lang, size: 12, weight: FontWeight.w600, color: c.ink)),
      iconTheme: WidgetStateProperty.resolveWith(
          (s) => IconThemeData(color: s.contains(WidgetState.selected) ? c.onMarigold : c.muted)),
    ),
  );
}
