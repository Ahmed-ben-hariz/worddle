import 'package:flutter_test/flutter_test.dart';
import 'package:worddle/core/constants/app_constants.dart';
import 'package:worddle/features/game/domain/models/game_status.dart';
import 'package:worddle/features/game/presentation/providers/game_provider.dart';
import 'package:worddle/features/settings/presentation/providers/settings_provider.dart';
import 'package:worddle/features/statistics/presentation/providers/stats_provider.dart';
import 'package:flutter/material.dart';

import '../../helpers/test_helpers.dart';

void main() {
  group('game rules', () {
    test('incomplete guess is rejected', () async {
      final prefs = await freshPrefs();
      final container = makeContainer(prefs);
      addTearDown(container.dispose);
      final ctrl = container.read(gameControllerProvider.notifier);
      await guess(ctrl, 'sla');
      final s = container.read(gameControllerProvider);
      expect(s.game.guesses, isEmpty);
      expect(s.message, 'Not enough letters');
      expect(s.shakeTick, 1);
    });

    test('invalid dictionary word is rejected', () async {
      final prefs = await freshPrefs();
      final container = makeContainer(prefs);
      addTearDown(container.dispose);
      final ctrl = container.read(gameControllerProvider.notifier);
      await guess(ctrl, 'zzzzz');
      final s = container.read(gameControllerProvider);
      expect(s.game.guesses, isEmpty);
      expect(s.message, 'Not in word list');
      expect(s.game.currentInput, 'zzzzz'); // stays so the player can edit it
    });

    test('valid guess is accepted and input cannot exceed five letters', () async {
      final prefs = await freshPrefs();
      final container = makeContainer(prefs);
      addTearDown(container.dispose);
      final ctrl = container.read(gameControllerProvider.notifier);
      typeWord(ctrl, 'slatexx');
      expect(container.read(gameControllerProvider).game.currentInput, 'slate');
      await ctrl.submitGuess();
      final s = container.read(gameControllerProvider);
      expect(s.game.guesses, ['slate']);
      expect(s.game.currentInput, '');
      expect(s.game.status, GameStatus.playing);
      expect(s.keyboardStatuses['a']!.name, 'correct');
      expect(s.keyboardStatuses['s']!.name, 'absent');
      expect(s.keyboardStatuses['e']!.name, 'correct');
    });

    test('winning guess ends the game and records stats once', () async {
      final prefs = await freshPrefs();
      final container = makeContainer(prefs);
      addTearDown(container.dispose);
      final ctrl = container.read(gameControllerProvider.notifier);
      await guess(ctrl, 'slate');
      await guess(ctrl, 'crane');
      final s = container.read(gameControllerProvider);
      expect(s.game.status, GameStatus.won);
      expect(s.resultTick, 1);
      final stats = container.read(statsProvider)[GameMode.daily]!;
      expect(stats.played, 1);
      expect(stats.won, 1);
      expect(stats.distribution[1], 1);
      expect(stats.currentStreak, 1);
      // Further input is blocked and stats do not change.
      await guess(ctrl, 'crane');
      expect(container.read(gameControllerProvider).game.guesses.length, 2);
      expect(container.read(statsProvider)[GameMode.daily]!.played, 1);
    });

    test('sixth unsuccessful guess ends the game; more guesses are blocked', () async {
      final prefs = await freshPrefs();
      final container = makeContainer(prefs);
      addTearDown(container.dispose);
      final ctrl = container.read(gameControllerProvider.notifier);
      for (final w in ['slate', 'audio', 'irate', 'adieu', 'stare', 'apple']) {
        await guess(ctrl, w);
      }
      var s = container.read(gameControllerProvider);
      expect(s.game.status, GameStatus.lost);
      expect(s.message, 'CRANE');
      final stats = container.read(statsProvider)[GameMode.daily]!;
      expect(stats.played, 1);
      expect(stats.won, 0);
      expect(stats.currentStreak, 0);
      await guess(ctrl, 'about');
      s = container.read(gameControllerProvider);
      expect(s.game.guesses.length, 6);
    });

    test('submitting during the reveal animation is ignored', () async {
      final prefs = await freshPrefs();
      final container = makeContainer(
        prefs,
        timings: const AnimationTimings(reveal: Duration(milliseconds: 30), celebrate: Duration.zero),
      );
      addTearDown(container.dispose);
      final ctrl = container.read(gameControllerProvider.notifier);
      typeWord(ctrl, 'slate');
      final pending = ctrl.submitGuess();
      expect(container.read(gameControllerProvider).busy, isTrue);
      typeWord(ctrl, 'audio'); // ignored while flipping
      await ctrl.submitGuess(); // ignored
      expect(container.read(gameControllerProvider).game.currentInput, '');
      await pending;
      expect(container.read(gameControllerProvider).game.guesses, ['slate']);
      expect(container.read(gameControllerProvider).busy, isFalse);
    });
  });

  group('daily challenge & persistence', () {
    test('unfinished daily game is restored after a restart', () async {
      final prefs = await freshPrefs();
      final first = makeContainer(prefs);
      final ctrl = first.read(gameControllerProvider.notifier);
      await guess(ctrl, 'slate');
      typeWord(ctrl, 'au');
      first.dispose();

      final second = makeContainer(prefs);
      addTearDown(second.dispose);
      final s = second.read(gameControllerProvider);
      expect(s.game.mode, GameMode.daily);
      expect(s.game.guesses, ['slate']);
      expect(s.game.currentInput, 'au');
      expect(s.game.challengeNumber, 69); // 2026-03-10 is day 69 since 2026-01-01
    });

    test('completed daily progress survives restart and cannot be replayed', () async {
      final prefs = await freshPrefs();
      final first = makeContainer(prefs);
      await guess(first.read(gameControllerProvider.notifier), 'crane');
      first.dispose();

      final second = makeContainer(prefs);
      addTearDown(second.dispose);
      var s = second.read(gameControllerProvider);
      expect(s.game.isWon, isTrue);
      expect(s.game.guesses, ['crane']);
      final ctrl = second.read(gameControllerProvider.notifier);
      await guess(ctrl, 'slate'); // blocked
      expect(second.read(gameControllerProvider).game.guesses, ['crane']);
      expect(second.read(statsProvider)[GameMode.daily]!.played, 1);
    });

    test('a new UTC date prepares a fresh daily puzzle', () async {
      final prefs = await freshPrefs();
      final day1 = makeContainer(prefs, now: DateTime.utc(2026, 3, 10, 23, 0));
      await guess(day1.read(gameControllerProvider.notifier), 'crane');
      day1.dispose();

      final day2 = makeContainer(prefs, now: DateTime.utc(2026, 3, 11, 0, 1));
      addTearDown(day2.dispose);
      final s = day2.read(gameControllerProvider);
      expect(s.game.guesses, isEmpty);
      expect(s.game.challengeNumber, 70);
      // yesterday's win still counts and a next-day win extends the streak.
      await guess(day2.read(gameControllerProvider.notifier), 'crane');
      expect(day2.read(statsProvider)[GameMode.daily]!.currentStreak, 2);
    });
  });

  group('practice mode', () {
    test('practice is separate, resumable, and does not affect daily stats', () async {
      final prefs = await freshPrefs();
      final first = makeContainer(prefs);
      final ctrl = first.read(gameControllerProvider.notifier);
      ctrl.setMode(GameMode.practice);
      await guess(ctrl, 'slate');
      await guess(ctrl, 'crane');
      expect(first.read(statsProvider)[GameMode.practice]!.played, 1);
      expect(first.read(statsProvider)[GameMode.daily]!.played, 0);
      ctrl.startNewPractice();
      await guess(ctrl, 'audio');
      first.dispose();

      final second = makeContainer(prefs);
      addTearDown(second.dispose);
      final s = second.read(gameControllerProvider);
      expect(s.game.mode, GameMode.practice); // last mode is remembered
      expect(s.game.guesses, ['audio']);
      expect(second.read(statsProvider)[GameMode.practice]!.played, 1);
    });
  });

  group('settings & corrupt data', () {
    test('settings persist across restarts', () async {
      final prefs = await freshPrefs();
      final first = makeContainer(prefs);
      await first.read(settingsProvider.notifier).setThemeMode(ThemeMode.dark);
      await first.read(settingsProvider.notifier).setHaptics(false);
      first.dispose();

      final second = makeContainer(prefs);
      addTearDown(second.dispose);
      final s = second.read(settingsProvider);
      expect(s.themeMode, ThemeMode.dark);
      expect(s.hapticsEnabled, isFalse);
    });

    test('corrupt saved data falls back to a fresh game', () async {
      final prefs = await freshPrefs({
        'worddle.v1.game.daily': '{not json',
        'worddle.v1.stats.daily': '[1,2,3]',
        'worddle.v1.settings': '42',
        'worddle.v1.mode': 'banana',
      });
      final container = makeContainer(prefs);
      addTearDown(container.dispose);
      final s = container.read(gameControllerProvider);
      expect(s.game.mode, GameMode.daily);
      expect(s.game.guesses, isEmpty);
      expect(container.read(statsProvider)[GameMode.daily]!.played, 0);
      expect(container.read(settingsProvider).themeMode, ThemeMode.system);
    });
  });
}
