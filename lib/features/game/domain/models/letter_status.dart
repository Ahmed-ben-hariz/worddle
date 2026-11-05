/// Feedback for one letter. Enum order doubles as priority:
/// correct > present > absent > unknown.
enum LetterStatus {
  unknown,
  absent,
  present,
  correct;

  int get priority => index;

  /// Returns whichever status has the higher priority.
  static LetterStatus stronger(LetterStatus a, LetterStatus b) =>
      a.priority >= b.priority ? a : b;
}
