import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../domain/models/game_status.dart';

class GameHeader extends StatelessWidget {
  const GameHeader({
    super.key,
    required this.onHelp,
    required this.onStats,
    required this.onSettings,
  });

  final VoidCallback onHelp;
  final VoidCallback onStats;
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 2, 4, 0),
      child: Row(
        children: [
          IconButton(tooltip: 'How to play', icon: const Icon(Icons.help_outline_rounded), onPressed: onHelp),
          const Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                'WORDDLE',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, letterSpacing: 5),
              ),
            ),
          ),
          IconButton(tooltip: 'Statistics', icon: const Icon(Icons.leaderboard_outlined), onPressed: onStats),
          IconButton(tooltip: 'Settings', icon: const Icon(Icons.settings_outlined), onPressed: onSettings),
        ],
      ),
    );
  }
}

/// Daily / Practice switch plus the challenge number.
class ModeBar extends StatelessWidget {
  const ModeBar({
    super.key,
    required this.mode,
    required this.challengeNumber,
    required this.onModeChanged,
    this.onNewPractice,
    this.enabled = true,
  });

  final GameMode mode;
  final int? challengeNumber;
  final ValueChanged<GameMode> onModeChanged;
  final VoidCallback? onNewPractice;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ModeToggle(mode: mode, enabled: enabled, onChanged: onModeChanged),
            const SizedBox(width: 16),
            if (mode == GameMode.daily)
              Text(
                challengeNumber == null ? 'Daily Challenge' : 'Challenge #$challengeNumber',
                key: const Key('challenge-label'),
                style: const TextStyle(fontWeight: FontWeight.w700),
              )
            else
              TextButton.icon(
                key: const Key('new-practice'),
                onPressed: enabled ? onNewPractice : null,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('New game'),
              ),
          ],
        ),
      ),
    );
  }
}

class _ModeToggle extends StatelessWidget {
  const _ModeToggle({required this.mode, required this.enabled, required this.onChanged});

  final GameMode mode;
  final bool enabled;
  final ValueChanged<GameMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.gameColors;
    Widget segment(GameMode m, String label) {
      final selected = m == mode;
      return GestureDetector(
        key: Key('mode-${m.name}'),
        behavior: HitTestBehavior.opaque,
        onTap: enabled && !selected ? () => onChanged(m) : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: selected ? colors.correct : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: selected ? Colors.white : colors.tileText,
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        border: Border.all(color: colors.tileBorderFilled),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        segment(GameMode.daily, 'Daily'),
        segment(GameMode.practice, 'Practice'),
      ]),
    );
  }
}
