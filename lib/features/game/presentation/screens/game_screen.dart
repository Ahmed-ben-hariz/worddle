import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/widgets/animated_dialog.dart';
import '../../../help/presentation/how_to_play_dialog.dart';
import '../../../settings/presentation/settings_screen.dart';
import '../../../statistics/presentation/statistics_screen.dart';
import '../providers/game_provider.dart';
import '../widgets/game_header.dart';
import '../widgets/game_keyboard.dart';
import '../widgets/game_result_dialog.dart';
import '../widgets/game_toast.dart';
import '../widgets/guess_grid.dart';

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> with WidgetsBindingObserver {
  bool _resultOpen = false;

  GameController get _controller => ref.read(gameControllerProvider.notifier);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    HardwareKeyboard.instance.addHandler(_onHardwareKey);
    // Reopen the results of an already completed puzzle (e.g. today's daily).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && ref.read(gameControllerProvider).game.isFinished) _showResults();
    });
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_onHardwareKey);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _controller.refreshDaily();
  }

  bool _onHardwareKey(KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) return false;
    if (!mounted || ModalRoute.of(context)?.isCurrent != true) return false;
    final hw = HardwareKeyboard.instance;
    if (hw.isControlPressed || hw.isMetaPressed || hw.isAltPressed) return false;

    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.enter || key == LogicalKeyboardKey.numpadEnter) {
      _controller.submitGuess();
      return true;
    }
    if (key == LogicalKeyboardKey.backspace) {
      _controller.deleteLetter();
      return true;
    }
    final label = key.keyLabel;
    if (label.length == 1 && RegExp(r'^[a-zA-Z]$').hasMatch(label)) {
      _controller.addLetter(label);
      return true;
    }
    return false;
  }

  Future<void> _showResults() async {
    if (_resultOpen || !mounted) return;
    _resultOpen = true;
    await showAnimatedDialog<void>(context: context, builder: (_) => const GameResultDialog());
    _resultOpen = false;
  }

  Future<void> _newPractice() async {
    final game = ref.read(gameControllerProvider).game;
    final inProgress = !game.isFinished && game.guesses.isNotEmpty;
    if (inProgress) {
      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Start a new game?'),
          content: const Text('Your current practice game will be abandoned.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
            TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('New game')),
          ],
        ),
      );
      if (ok != true) return;
    }
    _controller.startNewPractice();
  }

  @override
  Widget build(BuildContext context) {
    final ui = ref.watch(gameControllerProvider);
    final game = ui.game;

    ref.listen<int>(gameControllerProvider.select((s) => s.resultTick), (prev, next) {
      if (prev != next) _showResults();
    });

    final height = MediaQuery.sizeOf(context).height;
    final keyHeight = height < 650 ? 44.0 : (height < 760 ? 50.0 : 56.0);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
              children: [
                GameHeader(
                  onHelp: () => showAnimatedDialog<void>(context: context, builder: (_) => const HowToPlayDialog()),
                  onStats: () => Navigator.of(context).push(slideUpRoute<void>((_) => StatisticsScreen(initialMode: game.mode))),
                  onSettings: () => Navigator.of(context).push(slideUpRoute<void>((_) => const SettingsScreen())),
                ),
                ModeBar(
                  mode: game.mode,
                  challengeNumber: game.challengeNumber,
                  enabled: !ui.busy,
                  onModeChanged: _controller.setMode,
                  onNewPractice: _newPractice,
                ),
                Expanded(
                  child: Stack(
                    alignment: Alignment.topCenter,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
                        child: GuessGrid(
                          results: [for (final r in ui.results) r],
                          currentInput: game.currentInput,
                          revealingRow: ui.revealingRow,
                          celebrateRow: ui.celebrateRow,
                          shakeTick: ui.shakeTick,
                        ),
                      ),
                      if (ui.message != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: GameToast(key: ValueKey(ui.messageTick), message: ui.message!),
                        ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 40,
                  child: game.isFinished && !ui.busy
                      ? TextButton.icon(
                          key: const Key('view-results'),
                          onPressed: _showResults,
                          icon: const Icon(Icons.emoji_events_outlined, size: 18),
                          label: const Text('View results'),
                        )
                      : null,
                ),
                GameKeyboard(
                  statuses: ui.keyboardStatuses,
                  keyHeight: keyHeight,
                  onLetter: _controller.addLetter,
                  onEnter: _controller.submitGuess,
                  onBackspace: _controller.deleteLetter,
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
