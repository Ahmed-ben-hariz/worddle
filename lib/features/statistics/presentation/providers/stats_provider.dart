import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers.dart';
import '../../../game/domain/models/game_status.dart';
import '../../domain/game_stats.dart';

final statsProvider = NotifierProvider<StatsNotifier, Map<GameMode, GameStats>>(StatsNotifier.new);

class StatsNotifier extends Notifier<Map<GameMode, GameStats>> {
  @override
  Map<GameMode, GameStats> build() {
    final storage = ref.read(storageProvider);
    return {for (final m in GameMode.values) m: storage.loadStats(m)};
  }

  /// Records one finished game (called exactly once per game by the controller).
  void record(GameMode mode, {required bool won, int? attempts, String? dateKey}) {
    final updated = state[mode]!.recordResult(won: won, attempts: attempts, dateKey: dateKey);
    state = {...state, mode: updated};
    ref.read(storageProvider).saveStats(mode, updated);
  }
}
