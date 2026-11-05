import '../models/letter_status.dart';

/// Pure Dart game rules (no Flutter imports).
class WordleEngine {
  const WordleEngine._();

  static const int wordLength = 5;
  static const int maxAttempts = 6;

  /// Two-pass evaluation with correct duplicate-letter handling.
  static List<LetterStatus> evaluateGuess(String answer, String guess) {
    final a = answer.toLowerCase();
    final g = guess.toLowerCase();
    if (a.length != g.length) {
      throw ArgumentError('answer and guess must have the same length');
    }
    final result = List<LetterStatus>.filled(g.length, LetterStatus.absent);
    final remaining = <String, int>{};

    // Pass 1: exact matches; count the answer letters that are still unmatched.
    for (var i = 0; i < g.length; i++) {
      if (g[i] == a[i]) {
        result[i] = LetterStatus.correct;
      } else {
        remaining[a[i]] = (remaining[a[i]] ?? 0) + 1;
      }
    }
    // Pass 2: misplaced letters consume the remaining counts.
    for (var i = 0; i < g.length; i++) {
      if (result[i] == LetterStatus.correct) continue;
      final left = remaining[g[i]] ?? 0;
      if (left > 0) {
        result[i] = LetterStatus.present;
        remaining[g[i]] = left - 1;
      }
    }
    return result;
  }

  /// Best known status per letter. A stronger status is never downgraded.
  static Map<String, LetterStatus> keyboardStatuses(
    String answer,
    Iterable<String> guesses,
  ) {
    final map = <String, LetterStatus>{};
    for (final guess in guesses) {
      final statuses = evaluateGuess(answer, guess);
      for (var i = 0; i < guess.length; i++) {
        final letter = guess[i].toLowerCase();
        map[letter] = LetterStatus.stronger(map[letter] ?? LetterStatus.unknown, statuses[i]);
      }
    }
    return map;
  }
}

/// Convenience alias matching the spec: `evaluateGuess(answer, guess)`.
List<LetterStatus> evaluateGuess(String answer, String guess) =>
    WordleEngine.evaluateGuess(answer, guess);
