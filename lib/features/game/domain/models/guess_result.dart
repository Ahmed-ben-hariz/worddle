import 'letter_status.dart';

/// A submitted guess together with its per-letter feedback.
class GuessResult {
  const GuessResult({required this.word, required this.statuses});

  final String word;
  final List<LetterStatus> statuses;

  bool get isCorrect => statuses.every((s) => s == LetterStatus.correct);

  /// One row of share emojis (no letters, so the answer is never revealed).
  String toEmojiRow() => statuses.map((s) {
        switch (s) {
          case LetterStatus.correct:
            return '\u{1F7E9}';
          case LetterStatus.present:
            return '\u{1F7E8}';
          case LetterStatus.absent:
          case LetterStatus.unknown:
            return '\u2B1B';
        }
      }).join();
}
