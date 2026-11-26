import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const teal = Color(0xFF0E7C7B);
  static const tealHover = Color(0xFF0B6564);
  static const tealDeep = Color(0xFF006161);
  static const navy = Color(0xFF1A2332);
  static const mist = Color(0xFFF3F6F8);
  static const surface = Color(0xFFF3F6F8);
  static const card = Color(0xFFFFFFFF);
  static const border = Color(0xFFD7E0E6);
  static const muted = Color(0xFF5B6B76);
  static const pending = Color(0xFFE8A838);
  static const inProgress = Color(0xFF2B6CB0);
  static const completed = Color(0xFF2F855A);
  static const error = Color(0xFFC53030);
  static const softTealFill = Color(0xFFE9F5F4);

  // Backward-compatible aliases
  static const navyDark = navy;
}

class AppTheme {
  static String get _displayFont => GoogleFonts.plusJakartaSans().fontFamily!;
  static String get _bodyFont => GoogleFonts.inter().fontFamily!;

  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.teal,
      primary: AppColors.teal,
      onPrimary: Colors.white,
      secondary: AppColors.muted,
      surface: AppColors.mist,
      onSurface: AppColors.navy,
      error: AppColors.error,
    );

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.mist,
      fontFamily: _bodyFont,
    );

    final textTheme = base.textTheme.copyWith(
      displayLarge: base.textTheme.displayLarge?.copyWith(
        fontFamily: _displayFont,
        fontSize: 30,
        fontWeight: FontWeight.w700,
        height: 1.2,
        letterSpacing: -0.4,
        color: AppColors.navy,
      ),
      headlineLarge: base.textTheme.headlineLarge?.copyWith(
        fontFamily: _displayFont,
        fontSize: 24,
        fontWeight: FontWeight.w600,
        height: 1.3,
        letterSpacing: -0.2,
        color: AppColors.navy,
      ),
      headlineMedium: base.textTheme.headlineMedium?.copyWith(
        fontFamily: _displayFont,
        fontSize: 22,
        fontWeight: FontWeight.w600,
        height: 1.3,
        color: AppColors.navy,
      ),
      headlineSmall: base.textTheme.headlineSmall?.copyWith(
        fontFamily: _displayFont,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 1.3,
        color: AppColors.navy,
      ),
      titleLarge: base.textTheme.titleLarge?.copyWith(
        fontFamily: _displayFont,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.navy,
      ),
      titleMedium: base.textTheme.titleMedium?.copyWith(
        fontFamily: _displayFont,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.navy,
      ),
      bodyLarge: base.textTheme.bodyLarge?.copyWith(
        fontFamily: _bodyFont,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: AppColors.navy,
      ),
      bodyMedium: base.textTheme.bodyMedium?.copyWith(
        fontFamily: _bodyFont,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.45,
        color: AppColors.navy,
      ),
      bodySmall: base.textTheme.bodySmall?.copyWith(
        fontFamily: _bodyFont,
        fontSize: 13,
        fontWeight: FontWeight.w400,
        height: 1.4,
        color: AppColors.muted,
      ),
      labelLarge: base.textTheme.labelLarge?.copyWith(
        fontFamily: _bodyFont,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.navy,
      ),
    );

    return base.copyWith(
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.mist,
        foregroundColor: AppColors.navy,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: _displayFont,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.navy,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.card,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.border),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: 1,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.teal,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.teal.withValues(alpha: 0.4),
          minimumSize: const Size.fromHeight(48),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: TextStyle(
            fontFamily: _bodyFont,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.teal,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.navy,
          side: const BorderSide(color: AppColors.border),
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.teal,
          textStyle: TextStyle(fontFamily: _bodyFont, fontWeight: FontWeight.w500),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.card,
        hintStyle: const TextStyle(color: AppColors.muted),
        labelStyle: const TextStyle(color: AppColors.muted),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.teal, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.error),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.softTealFill,
        selectedColor: AppColors.teal.withValues(alpha: 0.15),
        labelStyle: TextStyle(
          fontFamily: _bodyFont,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.card,
        indicatorColor: AppColors.teal.withValues(alpha: 0.12),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontFamily: _bodyFont,
            fontSize: 12,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            color: selected ? AppColors.teal : AppColors.muted,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? AppColors.teal : AppColors.muted,
            size: 22,
          );
        }),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: AppColors.card,
        indicatorColor: AppColors.teal.withValues(alpha: 0.12),
        selectedIconTheme: const IconThemeData(color: AppColors.teal),
        unselectedIconTheme: const IconThemeData(color: AppColors.muted),
        selectedLabelTextStyle: TextStyle(
          fontFamily: _bodyFont,
          color: AppColors.teal,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        unselectedLabelTextStyle: TextStyle(
          fontFamily: _bodyFont,
          color: AppColors.muted,
          fontSize: 12,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.navy,
        contentTextStyle: TextStyle(fontFamily: _bodyFont, color: Colors.white),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.border),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.teal,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
    );
  }
}
