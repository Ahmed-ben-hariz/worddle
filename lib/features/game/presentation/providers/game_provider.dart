import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../statistics/presentation/providers/stats_provider.dart';
import '../../data/game_storage.dart';
import '../../domain/models/game_state.dart';
import '../../domain/models/game_status.dart';
import '../../domain/models/guess_result.dart';
import '../../domain/models/letter_status.dart';
import '../../domain/models/word_list.dart';
import '../../domain/services/daily_word_service.dart';
import '../../domain/services/wordle_engine.dart';

/// UI-facing state: the puzzle plus transient animation/message info.
class GameUiState {
  const GameUiState({
    required this.game,
    this.busy = false,
    this.revealingRow,
    this.celebrateRow,
    this.message,
    this.messageTick = 0,
    this.shakeTick = 0,
    this.resultTick = 0,
  });

  final GameState game;

  /// True while a row is flipping; input is ignored.
  final bool busy;
  final int? revealingRow;
  final int? celebrateRow;
  final String? message;
  final int messageTick;
  final int shakeTick;

  /// Incremented whenever the results dialog should be shown.
  final int resultTick;

  /// Guesses whose colors are already visible (hides the row mid-flip so the
  /// keyboard doesn't spoil the animation).
  List<String> get visibleGuesses =>
      revealingRow == null ? game.guesses : game.guesses.sublist(0, revealingRow!);

  Map<String, LetterStatus> get keyboardStatuses =>
      WordleEngine.keyboardStatuses(game.answer, visibleGuesses);

  List<GuessResult> get results => game.results;

  GameUiState copyWith({
    GameState? game,
    bool? busy,
    int? revealingRow,
    bool clearRevealingRow = false,
    int? celebrateRow,
    bool clearCelebrateRow = false,
    String? message,
    bool clearMessage = false,
    int? messageTick,
    int? shakeTick,
    int? resultTick,
  }) {
    return GameUiState(
      game: game ?? this.game,
      busy: busy ?? this.busy,
      revealingRow: clearRevealingRow ? null : (revealingRow ?? this.revealingRow),
      celebrateRow: clearCelebrateRow ? null : (celebrateRow ?? this.celebrateRow),
      message: clearMessage ? null : (message ?? this.message),
      messageTick: messageTick ?? this.messageTick,
      shakeTick: shakeTick ?? this.shakeTick,
      resultTick: resultTick ?? this.resultTick,
    );
  }
}

final gameControllerProvider = NotifierProvider<GameController, GameUiState>(GameController.new);

class GameController extends Notifier<GameUiState> {
  bool _disposed = false;

  WordList get _words => ref.read(wordListProvider);
  GameStorage get _storage => ref.read(storageProvider);
  DateTime _now() => ref.read(clockProvider)();
  DailyWordService get _dailyService => DailyWordService(_words.answers);

  @override
  GameUiState build() {
    _disposed = false;
    ref.onDispose(() => _disposed = true);
    return GameUiState(game: _loadOrCreate(_storage.loadMode()));
  }

  // ---------------------------------------------------------------- loading

  GameState _loadOrCreate(GameMode mode) {
    final saved = _storage.loadGame(mode);
    if (mode == GameMode.daily) {
      final fresh = _newDaily();
      // The deterministic answer wins over any stale or mismatched save.
      if (saved != null && saved.dateKey == fresh.dateKey && saved.answer == fresh.answer) {
        return saved;
      }
      _storage.saveGame(fresh);
      return fresh;
    }
    if (saved != null && _words.isValidGuess(saved.answer)) return saved;
    final fresh = _newPractice();
    _storage.saveGame(fresh);
    return fresh;
  }

  GameState _newDaily() {
    final now = _now();
    final service = _dailyService;
    return GameState(
      mode: GameMode.daily,
      answer: service.answerFor(now),
      dateKey: service.keyFor(now),
      challengeNumber: service.challengeNumber(now),
    );
  }

  GameState _newPractice({String? avoid}) {
    final answers = _words.answers;
    final random = ref.read(randomProvider);
    var answer = answers[random.nextInt(answers.length)];
    if (answers.length > 1) {
      var guard = 0;
      while (answer == avoid && guard++ < 10) {
        answer = answers[random.nextInt(answers.length)];
      }
    }
    return GameState(mode: GameMode.practice, answer: answer);
  }

  // ------------------------------------------------------------------ input

  bool get _canType => !state.busy && !state.game.isFinished;

  void addLetter(String letter) {
    final l = letter.toLowerCase();
    if (!RegExp(r'^[a-z]$').hasMatch(l)) return;
    if (!_canType || state.game.currentInput.length >= WordleEngine.wordLength) return;
    ref.read(hapticsProvider).tap();
    _update(state.game.copyWith(currentInput: state.game.currentInput + l));
  }

  void deleteLetter() {
    final input = state.game.currentInput;
    if (!_canType || input.isEmpty) return;
    ref.read(hapticsProvider).tap();
    _update(state.game.copyWith(currentInput: input.substring(0, input.length - 1)));
  }

  void _update(GameState game) {
    state = state.copyWith(game: game);
    _storage.saveGame(game);
  }

  void _toast(String text, {bool shake = false}) {
    state = state.copyWith(
      message: text,
      messageTick: state.messageTick + 1,
      shakeTick: shake ? state.shakeTick + 1 : state.shakeTick,
    );
  }

  // ----------------------------------------------------------------- submit

  Future<void> submitGuess() async {
    if (state.busy || state.game.isFinished) return;

    // A new UTC day started while the app stayed open.
    if (state.game.mode == GameMode.daily && state.game.dateKey != dateKey(_now())) {
      refreshDaily();
      return;
    }

    final game = state.game;
    final guess = game.currentInput;
    if (guess.length != WordleEngine.wordLength) {
      ref.read(hapticsProvider).error();
      _toast('Not enough letters', shake: true);
      return;
    }
    if (!_words.isValidGuess(guess)) {
      ref.read(hapticsProvider).error();
      _toast('Not in word list', shake: true);
      return;
    }

    final guesses = [...game.guesses, guess];
    final status = GameState.statusFor(game.answer, guesses);
    final updated = game.copyWith(guesses: guesses, currentInput: '', status: status);
    final row = guesses.length - 1;

    // Persist stats first, then the game, so a result is counted exactly once.
    if (status != GameStatus.playing) {
      ref.read(statsProvider.notifier).record(
            game.mode,
            won: status == GameStatus.won,
            attempts: guesses.length,
            dateKey: game.mode == GameMode.daily ? game.dateKey : null,
          );
    }
    await _storage.saveGame(updated);
    state = state.copyWith(game: updated, busy: true, revealingRow: row, clearMessage: true);

    final timings = ref.read(animationTimingsProvider);
    await Future<void>.delayed(timings.reveal);
    if (_disposed) return;

    state = state.copyWith(busy: false, clearRevealingRow: true);
    if (status == GameStatus.playing) return;

    if (status == GameStatus.won) {
      ref.read(hapticsProvider).success();
      state = state.copyWith(
        celebrateRow: row,
        message: _winMessage(guesses.length),
        messageTick: state.messageTick + 1,
      );
      await Future<void>.delayed(timings.celebrate);
      if (_disposed) return;
      state = state.copyWith(clearCelebrateRow: true);
    } else {
      _toast(game.answer.toUpperCase());
    }
    state = state.copyWith(resultTick: state.resultTick + 1);
  }

  static String _winMessage(int attempts) =>
      const ['Genius!', 'Magnificent!', 'Impressive!', 'Splendid!', 'Great!', 'Phew!'][attempts - 1];

  // ------------------------------------------------------------------ modes

  /// Switch between daily and practice. Each mode keeps its own saved game.
  void setMode(GameMode mode) {
    if (state.busy || mode == state.game.mode) return;
    _storage.saveMode(mode);
    final game = _loadOrCreate(mode);
    state = state.copyWith(
      game: game,
      clearMessage: true,
      clearRevealingRow: true,
      clearCelebrateRow: true,
      resultTick: game.isFinished ? state.resultTick + 1 : state.resultTick,
    );
  }

  /// Starts a fresh random practice puzzle (abandons any unfinished one).
  void startNewPractice() {
    if (state.busy) return;
    final game = _newPractice(avoid: state.game.mode == GameMode.practice ? state.game.answer : null);
    _storage.saveMode(GameMode.practice);
    _storage.saveGame(game);
    state = state.copyWith(game: game, clearMessage: true, clearRevealingRow: true, clearCelebrateRow: true);
  }

  /// Rolls the daily puzzle over when the UTC date changes (e.g. on app resume).
  void refreshDaily() {
    if (state.busy) return;
    final today = dateKey(_now());
    final saved = _storage.loadGame(GameMode.daily);
    if (state.game.mode == GameMode.daily && state.game.dateKey != today) {
      final fresh = _newDaily();
      _storage.saveGame(fresh);
      state = state.copyWith(game: fresh, clearMessage: true);
      _toast('New daily puzzle!');
    } else if (state.game.mode == GameMode.practice && saved?.dateKey != today) {
      _storage.saveGame(_newDaily());
    }
  }
}
