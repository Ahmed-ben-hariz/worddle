import 'package:flutter_test/flutter_test.dart';
import 'package:worddle/features/statistics/domain/game_stats.dart';

void main() {
  test('records wins, losses, streaks and distribution', () {
    var s = const GameStats();
    s = s.recordResult(won: true, attempts: 3);
    s = s.recordResult(won: true, attempts: 3);
    s = s.recordResult(won: false);
    s = s.recordResult(won: true, attempts: 6);
    expect(s.played, 4);
    expect(s.won, 3);
    expect(s.winPercent, 75);
    expect(s.currentStreak, 1);
    expect(s.maxStreak, 2);
    expect(s.distribution, [0, 0, 2, 0, 0, 1]);
  });

  test('daily streak requires consecutive UTC days', () {
    var s = const GameStats();
    s = s.recordResult(won: true, attempts: 2, dateKey: '2026-03-01');
    s = s.recordResult(won: true, attempts: 2, dateKey: '2026-03-02');
    expect(s.currentStreak, 2);
    s = s.recordResult(won: true, attempts: 2, dateKey: '2026-03-04'); // skipped a day
    expect(s.currentStreak, 1);
    expect(s.maxStreak, 2);
    expect(s.streakAsOf('2026-03-05'), 1);
    expect(s.streakAsOf('2026-03-06'), 0); // streak lapsed
  });

  test('JSON round trip and corrupt input', () {
    final s = const GameStats().recordResult(won: true, attempts: 4, dateKey: '2026-03-01');
    final back = GameStats.fromJson(s.toJson());
    expect(back.played, 1);
    expect(back.distribution, s.distribution);
    expect(back.lastWinKey, '2026-03-01');
    expect(GameStats.fromJson('garbage').played, 0);
    expect(GameStats.fromJson({'v': 1, 'played': -4, 'dist': [1]}).played, 0);
  });
}
