import 'dart:math' as math;

import '../../../../core/utils/date_utils.dart';

/// Deterministic daily puzzle selection.
///
/// Challenge #1 is [epoch]; the answer is `answers[(number - 1) % length]`.
/// Because the index depends only on the date, every player sees the same
/// word. Keep the answers list append-only so past puzzles never change.
class DailyWordService {
  DailyWordService(this.answers, {DateTime? epoch}) : epoch = epoch ?? defaultEpoch {
    if (answers.isEmpty) throw ArgumentError('answers must not be empty');
  }

  static final DateTime defaultEpoch = DateTime.utc(2026, 1, 1);

  final List<String> answers;
  final DateTime epoch;

  /// 1-based challenge number for the UTC day of [instant]
  /// (clamped to 1 for devices whose clock is before the epoch).
  int challengeNumber(DateTime instant) =>
      math.max(1, utcDaysBetween(epoch, instant) + 1);

  String answerForNumber(int number) => answers[(number - 1) % answers.length];

  String answerFor(DateTime instant) => answerForNumber(challengeNumber(instant));

  String keyFor(DateTime instant) => dateKey(instant);

  Duration timeUntilNext(DateTime now) => timeUntilNextUtcDay(now);
}
