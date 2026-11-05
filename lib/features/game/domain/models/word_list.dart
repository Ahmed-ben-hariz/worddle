/// Offline dictionaries: curated solutions plus extra accepted guesses.
class WordList {
  WordList({required Iterable<String> answers, required Iterable<String> extraGuesses})
      : answers = List.unmodifiable(_dedupe(answers.map(_normalize))),
        _guesses = {...extraGuesses.map(_normalize).where(_isValid)} {
    for (final a in this.answers) {
      if (!_isValid(a)) {
        throw FormatException('Invalid answer word: "$a"');
      }
    }
    if (this.answers.isEmpty) {
      throw const FormatException('Answer list is empty');
    }
    _answerSet = this.answers.toSet();
  }

  /// Parses newline-separated text. Answers are strictly validated
  /// (throws [FormatException]); invalid guess entries are skipped.
  factory WordList.fromText({required String answers, required String guesses}) {
    return WordList(answers: _lines(answers), extraGuesses: _lines(guesses));
  }

  /// Stable, ordered, unique solution words (append-only).
  final List<String> answers;
  final Set<String> _guesses;
  late final Set<String> _answerSet;

  bool isAnswer(String word) => _answerSet.contains(word.toLowerCase());

  /// True when [word] is an accepted guess (answers are always accepted).
  bool isValidGuess(String word) {
    final w = word.toLowerCase();
    return _answerSet.contains(w) || _guesses.contains(w);
  }

  int get totalWords => {..._answerSet, ..._guesses}.length;

  static final RegExp _pattern = RegExp(r'^[a-z]{5}$');
  static bool _isValid(String w) => _pattern.hasMatch(w);
  static String _normalize(String w) => w.trim().toLowerCase();
  static Iterable<String> _lines(String raw) => raw
      .split(RegExp(r'\r?\n'))
      .map((l) => l.trim())
      .where((l) => l.isNotEmpty && !l.startsWith('#'));

  static List<String> _dedupe(Iterable<String> words) {
    final seen = <String>{};
    return [
      for (final w in words)
        if (seen.add(w)) w,
    ];
  }
}
