import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../domain/models/guess_result.dart';
import 'guess_row.dart';

/// Six rows by five columns. Tile size adapts to the available space.
class GuessGrid extends StatelessWidget {
  const GuessGrid({
    super.key,
    required this.results,
    required this.currentInput,
    this.revealingRow,
    this.celebrateRow,
    this.shakeTick = 0,
  });

  final List<GuessResult> results;
  final String currentInput;
  final int? revealingRow;
  final int? celebrateRow;
  final int shakeTick;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const rowGap = 5.0;
        const colPad = 5.0;
        final byWidth = (constraints.maxWidth - colPad * AppConstants.wordLength) / AppConstants.wordLength;
        final byHeight =
            (constraints.maxHeight - rowGap * (AppConstants.maxAttempts - 1)) / AppConstants.maxAttempts;
        final size = math.max(24.0, math.min(62.0, math.min(byWidth, byHeight)));

        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var r = 0; r < AppConstants.maxAttempts; r++)
                Padding(
                  padding: EdgeInsets.only(bottom: r == AppConstants.maxAttempts - 1 ? 0 : rowGap),
                  child: GuessRow(
                    key: ValueKey('row-$r'),
                    tileSize: size,
                    letters: r < results.length
                        ? results[r].word
                        : (r == results.length ? currentInput : ''),
                    statuses: r < results.length ? results[r].statuses : null,
                    animateReveal: revealingRow == r,
                    isCurrent: r == results.length,
                    shakeTick: shakeTick,
                    celebrate: celebrateRow == r,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
