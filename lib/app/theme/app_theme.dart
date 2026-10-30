import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

/// Бүкіл қосымшаның бірыңғай тақырыбы (Material 3).
/// Түстер, қаріп өлшемдері, өрістер мен батырмалар стилі осында баптаған.
class AppTheme {
  AppTheme._();

  static const double radius = 16;
  static const double fieldRadius = 12;

  static ThemeData get light => _build(
        ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.light,
        ).copyWith(
          primary: AppColors.primary,
          onPrimary: Colors.white,
          secondary: AppColors.accent,
          onSecondary: AppColors.onAccent,
          surface: AppColors.surface,
          onSurface: AppColors.text,
          error: AppColors.danger,
        ),
        scaffold: AppColors.background,
        border: AppColors.border,
      );

  static ThemeData get dark => _build(
        ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.dark,
        ).copyWith(
          primary: AppColors.darkPrimary,
          onPrimary: AppColors.primaryDark,
          secondary: AppColors.accent,
          onSecondary: AppColors.onAccent,
          surface: AppColors.darkSurface,
          onSurface: AppColors.darkText,
          error: const Color(0xFFEF9A9A),
        ),
        scaffold: AppColors.darkBackground,
        border: const Color(0xFF4A3E38),
      );

  static ThemeData _build(
    ColorScheme cs, {
    required Color scaffold,
    required Color border,
  }) {
    OutlineInputBorder outline(Color c, [double w = 1.2]) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(fieldRadius),
          borderSide: BorderSide(color: c, width: w),
        );

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: cs,
      scaffoldBackgroundColor: scaffold,
      appBarTheme: AppBarTheme(
        backgroundColor: scaffold,
        foregroundColor: cs.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: cs.onSurface,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cs.surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        border: outline(border),
        enabledBorder: outline(border),
        focusedBorder: outline(cs.primary, 1.8),
        errorBorder: outline(cs.error),
        focusedErrorBorder: outline(cs.error, 1.8),
        errorStyle: const TextStyle(fontSize: 12),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: cs.surface,
        indicatorColor: cs.primary.withAlpha(36),
        height: 68,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.onAccent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      dividerColor: border,
    );

    // Типографика: Heading 1 – 28, Heading 2 – 22, Title – 16, Body – 16/14, Label – 12
    final text = base.textTheme
        .copyWith(
          headlineLarge:
              const TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
          headlineMedium:
              const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
          titleMedium:
              const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          bodyLarge: const TextStyle(fontSize: 16),
          bodyMedium: const TextStyle(fontSize: 14),
          labelSmall:
              const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        )
        .apply(bodyColor: cs.onSurface, displayColor: cs.onSurface);

    return base.copyWith(textTheme: text);
  }
}

/// Қосымша мәтін түсі (ағымдағы тақырыпқа сәйкес).
Color secondaryTextColor(BuildContext context) =>
    Theme.of(context).colorScheme.onSurface.withAlpha(166);
