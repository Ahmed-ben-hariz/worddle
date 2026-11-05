import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../../../core/utils/date_utils.dart';
import '../../game/domain/models/game_status.dart';
import 'providers/stats_provider.dart';
import 'widgets/stats_widgets.dart';

class StatisticsScreen extends ConsumerStatefulWidget {
  const StatisticsScreen({super.key, this.initialMode = GameMode.daily});

  final GameMode initialMode;

  @override
  ConsumerState<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends ConsumerState<StatisticsScreen> {
  late GameMode _mode = widget.initialMode;

  @override
  Widget build(BuildContext context) {
    final stats = ref.watch(statsProvider)[_mode]!;
    final today = _mode == GameMode.daily ? dateKey(ref.read(clockProvider)()) : null;
    return Scaffold(
      appBar: AppBar(title: const Text('Statistics'), backgroundColor: Colors.transparent, scrolledUnderElevation: 0),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                SegmentedButton<GameMode>(
                  showSelectedIcon: false,
                  segments: const [
                    ButtonSegment(value: GameMode.daily, label: Text('Daily')),
                    ButtonSegment(value: GameMode.practice, label: Text('Practice')),
                  ],
                  selected: {_mode},
                  onSelectionChanged: (s) => setState(() => _mode = s.first),
                ),
                const SizedBox(height: 24),
                StatsSummary(stats: stats, todayKey: today),
                const SizedBox(height: 28),
                const Text('GUESS DISTRIBUTION', style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 1.2)),
                const SizedBox(height: 10),
                GuessDistribution(distribution: stats.distribution),
                const SizedBox(height: 20),
                Text(
                  _mode == GameMode.daily
                      ? 'Daily streaks need a win on consecutive UTC days.'
                      : 'Practice games are tracked separately from the daily challenge.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
