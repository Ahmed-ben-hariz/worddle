import 'package:flutter_test/flutter_test.dart';
import 'package:worddle/core/utils/date_utils.dart';
import 'package:worddle/features/game/domain/services/daily_word_service.dart';

void main() {
  final answers = ['alpha', 'bravo', 'candy', 'delta', 'eagle'];
  final service = DailyWordService(answers, epoch: DateTime.utc(2026, 1, 1));

  test('same date produces the same answer, regardless of time of day', () {
    final morning = DateTime.utc(2026, 1, 3, 0, 0, 1);
    final night = DateTime.utc(2026, 1, 3, 23, 59, 59);
    expect(service.answerFor(morning), service.answerFor(night));
    expect(service.answerFor(morning), 'candy');
  });

  test('different dates select the appropriate puzzles', () {
    expect(service.challengeNumber(DateTime.utc(2026, 1, 1)), 1);
    expect(service.answerFor(DateTime.utc(2026, 1, 1)), 'alpha');
    expect(service.answerFor(DateTime.utc(2026, 1, 2)), 'bravo');
    expect(service.answerFor(DateTime.utc(2026, 1, 5)), 'eagle');
    // wraps around after the list is exhausted
    expect(service.answerFor(DateTime.utc(2026, 1, 6)), 'alpha');
  });

  test('non-UTC instants are converted to the UTC day', () {
    final local = DateTime.parse('2026-01-02T01:30:00+05:00'); // = 2026-01-01 20:30 UTC
    expect(service.challengeNumber(local), 1);
  });

  test('dates before the epoch clamp to challenge 1', () {
    expect(service.challengeNumber(DateTime.utc(2025, 6, 1)), 1);
  });

  test('appending new words does not change earlier puzzles', () {
    final extended = DailyWordService([...answers, 'fable', 'giant'], epoch: DateTime.utc(2026, 1, 1));
    for (var day = 1; day <= 5; day++) {
      final date = DateTime.utc(2026, 1, day);
      expect(extended.answerFor(date), service.answerFor(date));
    }
  });

  test('date helpers', () {
    expect(dateKey(DateTime.utc(2026, 3, 9, 23, 59)), '2026-03-09');
    expect(parseDateKey('2026-03-09'), DateTime.utc(2026, 3, 9));
    expect(parseDateKey('nonsense'), isNull);
    expect(timeUntilNextUtcDay(DateTime.utc(2026, 3, 9, 22)), const Duration(hours: 2));
  });
}
