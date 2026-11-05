import '../services/wordle_engine.dart';
import 'game_status.dart';
import 'guess_result.dart';

/// Immutable snapshot of one puzzle (daily or practice).
class GameState {
  const GameState({
    required this.mode,
    required this.answer,
    this.guesses = const [],
    this.currentInput = '',
    this.status = GameStatus.playing,
    this.dateKey,
    this.challengeNumber,
  });

  final GameMode mode;
  final String answer;
  final List<String> guesses;
  final String currentInput;
  final GameStatus status;

  /// UTC date key (daily mode only).
  final String? dateKey;

  /// Daily challenge number (daily mode only).
  final int? challengeNumber;

  bool get isFinished => status != GameStatus.playing;
  bool get isWon => status == GameStatus.won;

  List<GuessResult> get results => [
        for (final g in guesses)
          GuessResult(word: g, statuses: WordleEngine.evaluateGuess(answer, g)),
      ];

  /// Status implied by a list of guesses.
  static GameStatus statusFor(String answer, List<String> guesses) {
    if (guesses.isNotEmpty && guesses.last == answer) return GameStatus.won;
    if (guesses.length >= WordleEngine.maxAttempts) return GameStatus.lost;
    return GameStatus.playing;
  }

  GameState copyWith({List<String>? guesses, String? currentInput, GameStatus? status}) {
    return GameState(
      mode: mode,
      answer: answer,
      guesses: guesses ?? this.guesses,
      currentInput: currentInput ?? this.currentInput,
      status: status ?? this.status,
      dateKey: dateKey,
      challengeNumber: challengeNumber,
    );
  }

  Map<String, Object?> toJson() => {
        'v': 1,
        'mode': mode.name,
        'answer': answer,
        'guesses': guesses,
        'input': currentInput,
        'dateKey': dateKey,
        'number': challengeNumber,
      };

  /// Defensive parser: returns null for anything missing or inconsistent.
  static GameState? fromJson(Object? json) {
    try {
      if (json is! Map) return null;
      if (json['v'] != 1) return null;
      final mode = GameMode.values.where((m) => m.name == json['mode']);
      if (mode.isEmpty) return null;
      final word = RegExp(r'^[a-z]{5}$');
      final answer = json['answer'];
      if (answer is! String || !word.hasMatch(answer)) return null;
      final rawGuesses = json['guesses'];
      if (rawGuesses is! List || rawGuesses.length > WordleEngine.maxAttempts) return null;
      final guesses = <String>[];
      for (final g in rawGuesses) {
        if (g is! String || !word.hasMatch(g)) return null;
        guesses.add(g);
      }
      final status = statusFor(answer, guesses);
      var input = json['input'];
      if (input is! String || !RegExp(r'^[a-z]{0,5}$').hasMatch(input) || status != GameStatus.playing) {
        input = '';
      }
      final key = json['dateKey'];
      final number = json['number'];
      return GameState(
        mode: mode.first,
        answer: answer,
        guesses: guesses,
        currentInput: input,
        status: status,
        dateKey: key is String ? key : null,
        challengeNumber: number is int ? number : null,
      );
    } catch (_) {
      return null;
    }
  }
}
