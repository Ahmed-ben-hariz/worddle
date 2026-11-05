import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData get light => _build(
        brightness: Brightness.light,
        background: AppColors.backgroundLight,
        foreground: AppColors.textLight,
        extension: GameColors.light,
      );

  static ThemeData get dark => _build(
        brightness: Brightness.dark,
        background: AppColors.backgroundDark,
        foreground: AppColors.textDark,
        extension: GameColors.dark,
      );

  static ThemeData _build({
    required Brightness brightness,
    required Color background,
    required Color foreground,
    required GameColors extension,
  }) {
    final scheme = ColorScheme.fromSeed(
      seedColor: extension.correct,
      brightness: brightness,
    ).copyWith(
      surface: background,
      onSurface: foreground,
      primary: extension.correct,
      onPrimary: Colors.white,
    );
    final base = ThemeData(useMaterial3: true, colorScheme: scheme);

    return base.copyWith(
      scaffoldBackgroundColor: background,
      extensions: <ThemeExtension<dynamic>>[extension],
      textTheme: base.textTheme.apply(bodyColor: foreground, displayColor: foreground),
      iconTheme: IconThemeData(color: foreground),
      dividerColor: extension.tileBorder,
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: extension.toastBackground,
        contentTextStyle: TextStyle(color: extension.toastText, fontWeight: FontWeight.w600),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: extension.correct,
          foregroundColor: Colors.white,
          minimumSize: const Size(0, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, letterSpacing: 0.4),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: foreground,
          minimumSize: const Size(0, 48),
          side: BorderSide(color: extension.tileBorderFilled),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
