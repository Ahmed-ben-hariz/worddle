import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:worddle/features/game/domain/models/game_state.dart';
import 'package:worddle/features/game/domain/models/game_status.dart';
import 'package:worddle/features/game/domain/models/word_list.dart';
import 'package:worddle/features/game/domain/services/share_text_builder.dart';

void main() {
  test('normalizes, deduplicates and separates dictionaries', () {
    final list = WordList.fromText(
      answers: 'Apple\napple\n  CRANE \n# comment\n\n',
      guesses: 'slate\nCRANE\nbad\n12345\nSlate\n',
    );
    expect(list.answers, ['apple', 'crane']);
    expect(list.isValidGuess('slate'), isTrue);
    expect(list.isValidGuess('crane'), isTrue); // answers are always valid guesses
    expect(list.isValidGuess('bad'), isFalse);
    expect(list.isAnswer('slate'), isFalse);
  });

  test('invalid answer entries fail initialization', () {
    expect(() => WordList.fromText(answers: 'apple\nabc', guesses: ''), throwsFormatException);
    expect(() => WordList.fromText(answers: '', guesses: ''), throwsFormatException);
  });

  test('bundled asset files are valid', () {
    final answers = File('assets/words/answers.txt').readAsStringSync();
    final guesses = File('assets/words/valid_guesses.txt').readAsStringSync();
    final list = WordList.fromText(answers: answers, guesses: guesses);
    expect(list.answers.length, greaterThan(500));
    expect(list.totalWords, greaterThan(10000));
    final raw = answers.split('\n').where((l) => l.trim().isNotEmpty).toList();
    expect(raw.length, list.answers.length, reason: 'no duplicates or invalid lines');
    for (final w in list.answers) {
      expect(list.isValidGuess(w), isTrue);
    }
  });

  test('game state JSON round trip and validation', () {
    const g = GameState(mode: GameMode.daily, answer: 'crane', guesses: ['slate'], currentInput: 'au', dateKey: '2026-03-10', challengeNumber: 69);
    final back = GameState.fromJson(g.toJson())!;
    expect(back.guesses, ['slate']);
    expect(back.currentInput, 'au');
    expect(GameState.fromJson({'v': 1, 'mode': 'daily', 'answer': 'CRANE', 'guesses': []}), isNull);
    expect(GameState.fromJson({'v': 2}), isNull);
    expect(GameState.fromJson(null), isNull);
  });

  test('share text never reveals the answer', () {
    const g = GameState(mode: GameMode.daily, answer: 'crane', guesses: ['slate', 'crane'], dateKey: '2026-03-10', challengeNumber: 42, status: GameStatus.won);
    final text = ShareTextBuilder.build(g);
    expect(text.startsWith('Worddle #42 2/6'), isTrue);
    expect(text.toLowerCase().contains('crane'), isFalse);
    expect(text.toLowerCase().contains('slate'), isFalse);
    expect(text.trim().split('\n').last, '\u{1F7E9}\u{1F7E9}\u{1F7E9}\u{1F7E9}\u{1F7E9}');
  });
}
