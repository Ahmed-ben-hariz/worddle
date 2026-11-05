import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../domain/game_stats.dart';

class StatsSummary extends StatelessWidget {
  const StatsSummary({super.key, required this.stats, this.todayKey});

  final GameStats stats;

  /// When set, the displayed current streak accounts for missed days.
  final String? todayKey;

  @override
  Widget build(BuildContext context) {
    Widget cell(String value, String label) => Expanded(
          child: Column(children: [
            Text(value, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w800)),
            const SizedBox(height: 2),
            Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, height: 1.2)),
          ]),
        );
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        cell('${stats.played}', 'Played'),
        cell('${stats.winPercent}', 'Win %'),
        cell('${stats.streakAsOf(todayKey)}', 'Current\nstreak'),
        cell('${stats.maxStreak}', 'Max\nstreak'),
      ],
    );
  }
}

class GuessDistribution extends StatelessWidget {
  const GuessDistribution({super.key, required this.distribution, this.highlight});

  final List<int> distribution;

  /// 1-based number of guesses to highlight (the game just finished).
  final int? highlight;

  @override
  Widget build(BuildContext context) {
    final colors = context.gameColors;
    final maxCount = distribution.fold<int>(0, (m, v) => v > m ? v : m);
    return Column(
      children: [
        for (var i = 0; i < distribution.length; i++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Row(
              children: [
                SizedBox(width: 18, child: Text('${i + 1}', style: const TextStyle(fontWeight: FontWeight.w700))),
                Expanded(
                  child: LayoutBuilder(builder: (context, c) {
                    final fraction = maxCount == 0 ? 0.0 : distribution[i] / maxCount;
                    final width = (c.maxWidth * fraction).clamp(26.0, c.maxWidth);
                    return Align(
                      alignment: Alignment.centerLeft,
                      child: AnimatedContainer(
                        key: Key('dist-bar-${i + 1}'),
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeOutCubic,
                        width: width,
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        alignment: Alignment.centerRight,
                        decoration: BoxDecoration(
                          color: highlight == i + 1 ? colors.correct : colors.absent,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${distribution[i]}',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
