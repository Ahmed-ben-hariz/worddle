class AppConstants {
  const AppConstants._();

  static const int wordLength = 5;
  static const int maxAttempts = 6;

  static const Duration flipDuration = Duration(milliseconds: 450);
  static const Duration flipStagger = Duration(milliseconds: 220);

  /// Total time a row needs to finish revealing.
  static Duration get revealTotal => flipDuration + flipStagger * (wordLength - 1);

  static const Duration celebrateDuration = Duration(milliseconds: 900);
  static const Duration shakeDuration = Duration(milliseconds: 420);
  static const Duration popDuration = Duration(milliseconds: 120);
  static const Duration keyColorDuration = Duration(milliseconds: 250);
}

/// How long the game controller waits for animations. Tests use [instant].
class AnimationTimings {
  const AnimationTimings({
    this.reveal = const Duration(milliseconds: 1330),
    this.celebrate = const Duration(milliseconds: 900),
  });

  final Duration reveal;
  final Duration celebrate;

  static const AnimationTimings instant =
      AnimationTimings(reveal: Duration.zero, celebrate: Duration.zero);
}
