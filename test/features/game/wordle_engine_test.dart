import 'package:flutter_test/flutter_test.dart';
import 'package:worddle/features/game/domain/models/letter_status.dart';
import 'package:worddle/features/game/domain/services/wordle_engine.dart';

const c = LetterStatus.correct;
const p = LetterStatus.present;
const a = LetterStatus.absent;

void main() {
  group('evaluateGuess', () {
    test('correct answer', () {
      expect(evaluateGuess('apple', 'apple'), [c, c, c, c, c]);
    });

    test('completely incorrect guess', () {
      expect(evaluateGuess('apple', 'sount'), [a, a, a, a, a]);
    });

    test('correct letters in incorrect positions', () {
      expect(evaluateGuess('crane', 'nacre'), [p, p, p, p, c]);
    });

    test('duplicate letters in the answer', () {
      // 'apple' has two P: both misplaced Ps in the guess are present.
      expect(evaluateGuess('apple', 'pxxpx'), [p, a, a, p, a]);
      // 'crane' has one E (exact match at the end): the other Es are absent.
      expect(evaluateGuess('crane', 'eerie'), [a, a, p, a, c]);
    });

    test('duplicate letters in the guess', () {
      // single E in answer 'crane' at index 4; guess has two Es, the exact match wins.
      expect(evaluateGuess('crane', 'eexxe'), [a, a, a, a, c]);
      // single A in 'crane' (index 2): first A is present, second A is absent.
      expect(evaluateGuess('crane', 'aaxxx'), [p, a, a, a, a]);
    });

    test('exact match consumes the letter before a misplaced duplicate', () {
      // 'abbey' vs 'babes': classic example.
      expect(evaluateGuess('abbey', 'babes'), [p, p, c, c, a]);
    });

    test('mixed correct, present and absent (APPLE vs ALLEY)', () {
      expect(evaluateGuess('apple', 'alley'), [c, p, a, p, a]);
    });

    test('is case-insensitive and validates lengths', () {
      expect(evaluateGuess('APPLE', 'apple'), [c, c, c, c, c]);
      expect(() => evaluateGuess('apple', 'app'), throwsArgumentError);
    });
  });

  group('keyboardStatuses', () {
    test('keeps the strongest status and never downgrades', () {
      // 'crane': first guess 'trace' -> r,a,c,e correct/present...; second guess reuses letters badly.
      final first = WordleEngine.keyboardStatuses('crane', ['trace']);
      expect(first['t'], LetterStatus.absent);
      expect(first['r'], LetterStatus.correct);
      expect(first['c'], LetterStatus.present);
      expect(first['e'], LetterStatus.correct);

      final both = WordleEngine.keyboardStatuses('crane', ['crane', 'eerie']);
      // 'e' was correct in guess 1, and only present/absent in guess 2.
      expect(both['e'], LetterStatus.correct);
    });

    test('priority order is correct > present > absent > unknown', () {
      expect(LetterStatus.stronger(LetterStatus.absent, LetterStatus.present), LetterStatus.present);
      expect(LetterStatus.stronger(LetterStatus.correct, LetterStatus.present), LetterStatus.correct);
      expect(LetterStatus.stronger(LetterStatus.unknown, LetterStatus.absent), LetterStatus.absent);
    });
  });
}
