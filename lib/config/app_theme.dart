import 'package:flutter/material.dart';
import 'design_tokens.dart';

class AppTheme {
  static ThemeData get light => _build(Brightness.light);

  static ThemeData get dark => _build(Brightness.dark);

  /// Returns the theme for a specific [locale] (e.g. `ar`), switching the
  /// primary typeface to an Arabic-capable font so RTL text renders fully.
  static ThemeData lightForLocale(String locale) =>
      _build(Brightness.light, fontFamily: _fontFor(locale));

  static ThemeData darkForLocale(String locale) =>
      _build(Brightness.dark, fontFamily: _fontFor(locale));

  static String? _fontFor(String locale) {
    if (locale == 'ar') return 'Noto Sans Arabic';
    return null;
  }

  static ThemeData _build(Brightness brightness, {String? fontFamily}) {
    final isDark = brightness == Brightness.dark;
    final background = isDark ? const Color(0xFF0B0B0F) : AppColors.background;
    final surface = isDark ? const Color(0xFF16161C) : AppColors.surface;
    final textPrimary = isDark ? const Color(0xFFF2F2F4) : AppColors.textPrimary;
    final textSecondary =
        isDark ? const Color(0xFF9E9EA6) : AppColors.textSecondary;
    final textHint = isDark ? const Color(0xFF6E6E78) : AppColors.textHint;
    final border = isDark ? const Color(0xFF2C2C34) : AppColors.border;
    final primary = isDark ? const Color(0xFFE8E8EA) : AppColors.primary;
    final onPrimary = isDark ? const Color(0xFF0B0B0F) : AppColors.onPrimary;
    final primaryGradient = isDark
        ? const LinearGradient(
            colors: [Color(0xFF2A2A34), Color(0xFF1A1A22)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        : AppColors.primaryGradient;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      fontFamily: fontFamily,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: primary,
        onPrimary: onPrimary,
        secondary: AppColors.secondary,
        onSecondary: AppColors.onSecondary,
        surface: surface,
        onSurface: textPrimary,
        error: AppColors.error,
        onError: AppColors.onPrimary,
      ),
      scaffoldBackgroundColor: background,
      cardTheme: CardThemeData(
        elevation: 0,
        color: surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTypography.titleLarge.copyWith(color: textPrimary),
        iconTheme: IconThemeData(color: textPrimary),
      ),
      dividerTheme: DividerThemeData(color: border.withValues(alpha: 0.4)),
      iconTheme: IconThemeData(color: textPrimary),
      textTheme: TextTheme(
        displayLarge: AppTypography.h1.copyWith(color: textPrimary),
        displayMedium: AppTypography.h2.copyWith(color: textPrimary),
        titleLarge: AppTypography.titleLarge.copyWith(color: textPrimary),
        titleMedium: AppTypography.titleMedium.copyWith(color: textPrimary),
        bodyLarge: AppTypography.bodyLarge.copyWith(color: textPrimary),
        bodyMedium: AppTypography.bodyMedium.copyWith(color: textPrimary),
        bodySmall: AppTypography.bodySmall.copyWith(color: textPrimary),
        labelMedium: AppTypography.labelMedium.copyWith(color: textSecondary),
        labelLarge: AppTypography.titleMedium.copyWith(
          color: textPrimary,
          fontWeight: FontWeight.w600,
        ),
        headlineMedium: AppTypography.h2.copyWith(color: textPrimary),
        titleSmall: AppTypography.bodyMedium.copyWith(
          color: textSecondary,
          fontWeight: FontWeight.w600,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: onPrimary,
          minimumSize: const Size(double.infinity, 54),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: AppTypography.bodyLarge.copyWith(
            color: onPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.error, width: 1),
        ),
        hintStyle: AppTypography.bodyMedium.copyWith(color: textHint),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        indicatorColor: primary.withValues(alpha: 0.1),
      ),
      secondaryHeaderColor: AppColors.secondary.withValues(alpha: 0.12),
    );
  }

  /// Convenience accessor used by widgets that need the dark gradient.
  static LinearGradient gradientFor(Brightness brightness) =>
      brightness == Brightness.dark
          ? const LinearGradient(
              colors: [Color(0xFF2A2A34), Color(0xFF1A1A22)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            )
          : AppColors.primaryGradient;
}