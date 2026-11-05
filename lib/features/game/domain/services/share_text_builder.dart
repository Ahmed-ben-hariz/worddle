import '../models/game_state.dart';
import '../models/game_status.dart';
import 'wordle_engine.dart';

/// Builds the spoiler-free share text (never contains the answer).
class ShareTextBuilder {
  const ShareTextBuilder._();

  static String build(GameState game) {
    final label = game.mode == GameMode.daily
        ? 'Worddle #${game.challengeNumber ?? '?'}'
        : 'Worddle Practice';
    final score = game.isWon ? '${game.guesses.length}' : 'X';
    final grid = game.results.map((r) => r.toEmojiRow()).join('\n');
    return '$label $score/${WordleEngine.maxAttempts}\n\n$grid';
  }
}
