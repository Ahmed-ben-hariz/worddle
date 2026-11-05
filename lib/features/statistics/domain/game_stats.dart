import '../../../core/utils/date_utils.dart';

/// Win/loss statistics for one game mode. Daily and practice each own one.
class GameStats {
  const GameStats({
    this.played = 0,
    this.won = 0,
    this.currentStreak = 0,
    this.maxStreak = 0,
    this.distribution = const [0, 0, 0, 0, 0, 0],
    this.lastWinKey,
  });

  final int played;
  final int won;
  final int currentStreak;
  final int maxStreak;

  /// Wins by number of guesses: index 0 = solved in 1 guess ... index 5 = 6.
  final List<int> distribution;

  /// UTC date key of the last daily win (used to detect broken streaks).
  final String? lastWinKey;

  int get winPercent => played == 0 ? 0 : (won * 100 / played).round();

  /// Streak to display. For daily stats, a streak is broken once a full UTC day
  /// passes without a win, so pass today's [todayKey] to account for that.
  int streakAsOf(String? todayKey) {
    if (todayKey == null || lastWinKey == null || currentStreak == 0) return currentStreak;
    final last = parseDateKey(lastWinKey);
    final today = parseDateKey(todayKey);
    if (last == null || today == null) return currentStreak;
    return utcDaysBetween(last, today) <= 1 ? currentStreak : 0;
  }

  /// Returns updated stats after one finished game.
  /// Pass [dateKey] for daily games so streaks require consecutive days.
  GameStats recordResult({required bool won, int? attempts, String? dateKey}) {
    final dist = List<int>.of(distribution);
    var streak = currentStreak;
    var newMax = maxStreak;
    String? winKey = lastWinKey;
    if (won) {
      if (attempts != null && attempts >= 1 && attempts <= dist.length) {
        dist[attempts - 1]++;
      }
      if (dateKey != null) {
        final last = parseDateKey(lastWinKey);
        final today = parseDateKey(dateKey);
        final consecutive = last != null && today != null && utcDaysBetween(last, today) == 1;
        streak = consecutive ? streak + 1 : 1;
        winKey = dateKey;
      } else {
        streak += 1;
      }
      if (streak > newMax) newMax = streak;
    } else {
      streak = 0;
    }
    return GameStats(
      played: played + 1,
      won: this.won + (won ? 1 : 0),
      currentStreak: streak,
      maxStreak: newMax,
      distribution: dist,
      lastWinKey: winKey,
    );
  }

  Map<String, Object?> toJson() => {
        'v': 1,
        'played': played,
        'won': won,
        'current': currentStreak,
        'max': maxStreak,
        'dist': distribution,
        'lastWin': lastWinKey,
      };

  static GameStats fromJson(Object? json) {
    try {
      if (json is! Map || json['v'] != 1) return const GameStats();
      int n(Object? v) => v is int && v >= 0 ? v : 0;
      final rawDist = json['dist'];
      final dist = rawDist is List && rawDist.length == 6
          ? [for (final v in rawDist) n(v)]
          : const [0, 0, 0, 0, 0, 0];
      final lw = json['lastWin'];
      return GameStats(
        played: n(json['played']),
        won: n(json['won']),
        currentStreak: n(json['current']),
        maxStreak: n(json['max']),
        distribution: dist,
        lastWinKey: lw is String ? lw : null,
      );
    } catch (_) {
      return const GameStats();
    }
  }
}
