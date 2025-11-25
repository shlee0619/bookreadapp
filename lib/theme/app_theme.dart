import 'package:flutter/material.dart';

ThemeData buildBooklogTheme(Brightness brightness) {
  const primaryColor = Color(0xFF3B4CCA);
  final isDark = brightness == Brightness.dark;

  final base = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: brightness,
    ),
    useMaterial3: true,
  );

  return base.copyWith(
    scaffoldBackgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
    appBarTheme: base.appBarTheme.copyWith(
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: isDark ? Colors.white : Colors.black87,
      ),
      iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black87),
    ),
    cardTheme: base.cardTheme.copyWith(
      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isDark ? Colors.grey[800]! : const Color(0xFFE9EDF8),
        ),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),
    chipTheme: base.chipTheme.copyWith(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      backgroundColor: isDark ? Colors.grey[800] : null,
      labelStyle: TextStyle(color: isDark ? Colors.white : Colors.black87),
    ),
    floatingActionButtonTheme: base.floatingActionButtonTheme.copyWith(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
    ),
    inputDecorationTheme: base.inputDecorationTheme.copyWith(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: isDark ? Colors.grey[700]! : const Color(0xFFE9EDF8),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: isDark ? Colors.grey[700]! : const Color(0xFFE9EDF8),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: primaryColor),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      fillColor: isDark ? Colors.grey[900] : null,
      filled: isDark,
    ),
    bottomNavigationBarTheme: base.bottomNavigationBarTheme.copyWith(
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      selectedItemColor: primaryColor,
      unselectedItemColor: isDark ? Colors.grey[400] : Colors.grey[600],
    ),
  );
}
