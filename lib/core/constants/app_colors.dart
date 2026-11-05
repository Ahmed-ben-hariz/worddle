import 'package:flutter/material.dart';

import '../../features/game/domain/models/letter_status.dart';

/// Raw palette. Widgets read colors through [GameColors] (theme aware).
class AppColors {
  const AppColors._();

  // Light
  static const Color backgroundLight = Color(0xFFFAF8F4);
  static const Color textLight = Color(0xFF2A2A2D);
  static const Color tileEmptyLight = Color(0xFFFFFFFF);
  static const Color tileBorderLight = Color(0xFFD6D3CD);
  static const Color tileBorderFilledLight = Color(0xFF8C8A86);
  static const Color correctLight = Color(0xFF1B9A62);
  static const Color presentLight = Color(0xFFE5AE24);
  static const Color absentLight = Color(0xFF7B7D80);
  static const Color keyLight = Color(0xFFDAD8D3);

  // Dark
  static const Color backgroundDark = Color(0xFF121214);
  static const Color textDark = Color(0xFFFFFFFF);
  static const Color tileEmptyDark = Color(0xFF1C1C20);
  static const Color tileBorderDark = Color(0xFF3F3F45);
  static const Color tileBorderFilledDark = Color(0xFF7A7A82);
  static const Color correctDark = Color(0xFF2BAA70);
  static const Color presentDark = Color(0xFFE3B341);
  static const Color absentDark = Color(0xFF3A3A40);
  static const Color keyDark = Color(0xFF585C63);

  /// Dark text used on the amber "present" color for contrast.
  static const Color onPresent = Color(0xFF1D1B16);
}

@immutable
class GameColors extends ThemeExtension<GameColors> {
  const GameColors({
    required this.tileEmpty,
    required this.tileBorder,
    required this.tileBorderFilled,
    required this.tileText,
    required this.correct,
    required this.present,
    required this.absent,
    required this.keyBackground,
    required this.keyText,
    required this.toastBackground,
    required this.toastText,
  });

  final Color tileEmpty;
  final Color tileBorder;
  final Color tileBorderFilled;
  final Color tileText;
  final Color correct;
  final Color present;
  final Color absent;
  final Color keyBackground;
  final Color keyText;
  final Color toastBackground;
  final Color toastText;

  static const GameColors light = GameColors(
    tileEmpty: AppColors.tileEmptyLight,
    tileBorder: AppColors.tileBorderLight,
    tileBorderFilled: AppColors.tileBorderFilledLight,
    tileText: AppColors.textLight,
    correct: AppColors.correctLight,
    present: AppColors.presentLight,
    absent: AppColors.absentLight,
    keyBackground: AppColors.keyLight,
    keyText: AppColors.textLight,
    toastBackground: AppColors.textLight,
    toastText: AppColors.backgroundLight,
  );

  static const GameColors dark = GameColors(
    tileEmpty: AppColors.tileEmptyDark,
    tileBorder: AppColors.tileBorderDark,
    tileBorderFilled: AppColors.tileBorderFilledDark,
    tileText: AppColors.textDark,
    correct: AppColors.correctDark,
    present: AppColors.presentDark,
    absent: AppColors.absentDark,
    keyBackground: AppColors.keyDark,
    keyText: AppColors.textDark,
    toastBackground: AppColors.textDark,
    toastText: AppColors.backgroundDark,
  );

  /// Background color for a tile / key with the given [status].
  Color colorFor(LetterStatus status) {
    switch (status) {
      case LetterStatus.correct:
        return correct;
      case LetterStatus.present:
        return present;
      case LetterStatus.absent:
        return absent;
      case LetterStatus.unknown:
        return keyBackground;
    }
  }

  /// Readable foreground color on top of [colorFor].
  Color onColorFor(LetterStatus status) {
    switch (status) {
      case LetterStatus.correct:
      case LetterStatus.absent:
        return Colors.white;
      case LetterStatus.present:
        return AppColors.onPresent;
      case LetterStatus.unknown:
        return keyText;
    }
  }

  @override
  GameColors copyWith({
    Color? tileEmpty,
    Color? tileBorder,
    Color? tileBorderFilled,
    Color? tileText,
    Color? correct,
    Color? present,
    Color? absent,
    Color? keyBackground,
    Color? keyText,
    Color? toastBackground,
    Color? toastText,
  }) {
    return GameColors(
      tileEmpty: tileEmpty ?? this.tileEmpty,
      tileBorder: tileBorder ?? this.tileBorder,
      tileBorderFilled: tileBorderFilled ?? this.tileBorderFilled,
      tileText: tileText ?? this.tileText,
      correct: correct ?? this.correct,
      present: present ?? this.present,
      absent: absent ?? this.absent,
      keyBackground: keyBackground ?? this.keyBackground,
      keyText: keyText ?? this.keyText,
      toastBackground: toastBackground ?? this.toastBackground,
      toastText: toastText ?? this.toastText,
    );
  }

  @override
  GameColors lerp(ThemeExtension<GameColors>? other, double t) {
    if (other is! GameColors) return this;
    Color mix(Color a, Color b) => Color.lerp(a, b, t)!;
    return GameColors(
      tileEmpty: mix(tileEmpty, other.tileEmpty),
      tileBorder: mix(tileBorder, other.tileBorder),
      tileBorderFilled: mix(tileBorderFilled, other.tileBorderFilled),
      tileText: mix(tileText, other.tileText),
      correct: mix(correct, other.correct),
      present: mix(present, other.present),
      absent: mix(absent, other.absent),
      keyBackground: mix(keyBackground, other.keyBackground),
      keyText: mix(keyText, other.keyText),
      toastBackground: mix(toastBackground, other.toastBackground),
      toastText: mix(toastText, other.toastText),
    );
  }
}

extension GameColorsContext on BuildContext {
  GameColors get gameColors =>
      Theme.of(this).extension<GameColors>() ?? GameColors.light;
}
