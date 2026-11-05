import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/providers.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../statistics/presentation/providers/stats_provider.dart';
import '../../../statistics/presentation/widgets/stats_widgets.dart';
import '../../domain/models/game_status.dart';
import '../../domain/services/share_text_builder.dart';
import '../providers/game_provider.dart';

/// Shown after a game ends (and reopened from "View results").
class GameResultDialog extends ConsumerWidget {
  const GameResultDialog({super.key});

  Future<void> _share(BuildContext context, String text) async {
    final messenger = ScaffoldMessenger.maybeOf(context);
    try {
      await Share.share(text);
    } catch (_) {
      await Clipboard.setData(ClipboardData(text: text));
      messenger?.showSnackBar(const SnackBar(content: Text('Result copied to clipboard')));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final game = ref.watch(gameControllerProvider).game;
    final stats = ref.watch(statsProvider)[game.mode]!;
    final now = ref.read(clockProvider)();
    final isDaily = game.mode == GameMode.daily;
    final won = game.isWon;

    final title = won ? 'You won!' : (game.isFinished ? 'Game over' : 'In progress');
    final subtitle = won
        ? 'Solved in ${game.guesses.length} ${game.guesses.length == 1 ? 'guess' : 'guesses'}.'
        : (game.isFinished ? 'The word was ${game.answer.toUpperCase()}.' : '');

    final left = timeUntilNextUtcDay(now);
    final countdown = '${left.inHours}h ${left.inMinutes.remainder(60)}m';

    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  tooltip: 'Close',
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              Text(title, key: const Key('result-title'), style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900)),
              if (subtitle.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(fontSize: 15)),
              ],
              const SizedBox(height: 22),
              StatsSummary(stats: stats, todayKey: isDaily ? dateKey(now) : null),
              const SizedBox(height: 18),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  isDaily ? 'DAILY GUESS DISTRIBUTION' : 'PRACTICE GUESS DISTRIBUTION',
                  style: const TextStyle(fontWeight: FontWeight.w800, letterSpacing: 1.1, fontSize: 12),
                ),
              ),
              const SizedBox(height: 6),
              GuessDistribution(distribution: stats.distribution, highlight: won ? game.guesses.length : null),
              const SizedBox(height: 22),
              if (isDaily) ...[
                Text('Next puzzle in $countdown', style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 14),
                PrimaryButton(
                  label: 'Share',
                  icon: Icons.ios_share_rounded,
                  onPressed: game.isFinished ? () => _share(context, ShareTextBuilder.build(game)) : null,
                ),
                const SizedBox(height: 10),
                PrimaryButton(
                  label: 'Play practice',
                  outlined: true,
                  onPressed: () {
                    Navigator.of(context).pop();
                    ref.read(gameControllerProvider.notifier).setMode(GameMode.practice);
                  },
                ),
              ] else
                PrimaryButton(
                  label: 'Play again',
                  icon: Icons.refresh_rounded,
                  onPressed: () {
                    Navigator.of(context).pop();
                    ref.read(gameControllerProvider.notifier).startNewPractice();
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
