import 'package:flutter/material.dart';

ThemeData buildMedTheme() {
  const Color primary = Color(0xFF2DBE74); // soft green
  const Color background = Color(0xFFF7FAF8); // near white with green tint
  const Color surface = Colors.white;

  final base = ThemeData.light(useMaterial3: true);
  return base.copyWith(
    colorScheme: base.colorScheme.copyWith(
      primary: primary,
      secondary: const Color(0xFF0EAD69),
      surface: surface,
    ),
    scaffoldBackgroundColor: background,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      foregroundColor: Colors.black87,
      centerTitle: false,
    ),
    cardTheme: CardThemeData(
      color: surface,
      elevation: 1,
      shadowColor: Colors.black.withOpacity(0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    textTheme: base.textTheme.apply(
      bodyColor: Colors.black87,
      displayColor: Colors.black87,
    ),
    checkboxTheme: CheckboxThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
    ),
  );
}

BoxDecoration roundedCardDecoration() {
  return BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 12,
        offset: const Offset(0, 4),
      ),
    ],
  );
}
