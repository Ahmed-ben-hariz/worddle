import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:worddle/core/constants/app_constants.dart';
import 'package:worddle/core/providers.dart';
import 'package:worddle/features/game/domain/models/word_list.dart';
import 'package:worddle/features/game/presentation/providers/game_provider.dart';

/// Single-answer list so the daily and practice answer are always "crane".
WordList testWords() => WordList(
      answers: const ['crane'],
      extraGuesses: const ['slate', 'audio', 'irate', 'adieu', 'stare', 'apple', 'alley', 'about', 'trace'],
    );

Future<SharedPreferences> freshPrefs([Map<String, Object> initial = const {}]) async {
  SharedPreferences.setMockInitialValues(initial);
  return SharedPreferences.getInstance();
}

List<Override> testOverrides(
  SharedPreferences prefs, {
  WordList? words,
  DateTime? now,
  AnimationTimings timings = AnimationTimings.instant,
}) {
  final clock = now ?? DateTime.utc(2026, 3, 10, 12);
  return [
    sharedPreferencesProvider.overrideWithValue(prefs),
    wordListProvider.overrideWithValue(words ?? testWords()),
    clockProvider.overrideWithValue(() => clock),
    animationTimingsProvider.overrideWithValue(timings),
  ];
}

ProviderContainer makeContainer(
  SharedPreferences prefs, {
  WordList? words,
  DateTime? now,
  AnimationTimings timings = AnimationTimings.instant,
}) {
  final c = ProviderContainer(overrides: testOverrides(prefs, words: words, now: now, timings: timings));
  return c;
}

void typeWord(GameController controller, String word) {
  for (final ch in word.split('')) {
    controller.addLetter(ch);
  }
}

Future<void> guess(GameController controller, String word) async {
  typeWord(controller, word);
  await controller.submitGuess();
}
