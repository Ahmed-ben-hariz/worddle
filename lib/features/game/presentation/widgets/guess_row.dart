import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../domain/models/letter_status.dart';
import 'letter_tile.dart';

/// A row of five tiles. Owns the reveal, shake and celebration animations.
class GuessRow extends StatefulWidget {
  const GuessRow({
    super.key,
    required this.letters,
    required this.tileSize,
    this.statuses,
    this.animateReveal = false,
    this.isCurrent = false,
    this.shakeTick = 0,
    this.celebrate = false,
  });

  /// 0-5 characters typed or submitted for this row.
  final String letters;
  final double tileSize;

  /// Non-null once the row has been submitted.
  final List<LetterStatus>? statuses;

  /// Play the flip animation when [statuses] first appears.
  final bool animateReveal;

  /// The row being typed into (the only one that shakes).
  final bool isCurrent;
  final int shakeTick;
  final bool celebrate;

  @override
  State<GuessRow> createState() => _GuessRowState();
}

class _GuessRowState extends State<GuessRow> with TickerProviderStateMixin {
  late final AnimationController _reveal = AnimationController(
    vsync: this,
    duration: AppConstants.revealTotal,
    value: widget.statuses != null && !widget.animateReveal ? 1 : 0,
  );
  late final AnimationController _shake =
      AnimationController(vsync: this, duration: AppConstants.shakeDuration);
  late final AnimationController _win =
      AnimationController(vsync: this, duration: AppConstants.celebrateDuration);

  @override
  void initState() {
    super.initState();
    if (widget.statuses != null && widget.animateReveal) _reveal.forward(from: 0);
  }

  @override
  void didUpdateWidget(GuessRow old) {
    super.didUpdateWidget(old);
    if (old.statuses == null && widget.statuses != null) {
      if (widget.animateReveal) {
        _reveal.forward(from: 0);
      } else {
        _reveal.value = 1;
      }
    } else if (old.statuses != null && widget.statuses == null) {
      _reveal.value = 0;
    }
    if (widget.isCurrent && widget.shakeTick != old.shakeTick) _shake.forward(from: 0);
    if (widget.celebrate && !old.celebrate) _win.forward(from: 0);
  }

  @override
  void dispose() {
    _reveal.dispose();
    _shake.dispose();
    _win.dispose();
    super.dispose();
  }

  double _flipFor(int i) {
    final total = AppConstants.revealTotal.inMilliseconds;
    final start = AppConstants.flipStagger.inMilliseconds * i / total;
    final end = (AppConstants.flipStagger.inMilliseconds * i + AppConstants.flipDuration.inMilliseconds) / total;
    final p = ((_reveal.value - start) / (end - start)).clamp(0.0, 1.0);
    return Curves.easeInOut.transform(p);
  }

  double _liftFor(int i) {
    final t = ((_win.value - i * 0.1) / 0.5).clamp(0.0, 1.0);
    return math.sin(t * math.pi) * widget.tileSize * 0.25;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_reveal, _shake, _win]),
      builder: (context, _) {
        final dx = math.sin(_shake.value * math.pi * 6) * 8 * (1 - _shake.value);
        return Transform.translate(
          offset: Offset(dx, 0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < AppConstants.wordLength; i++)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2.5),
                  child: LetterTile(
                    letter: i < widget.letters.length ? widget.letters[i] : '',
                    status: widget.statuses?[i],
                    flip: widget.statuses == null ? 0 : _flipFor(i),
                    size: widget.tileSize,
                    lift: _liftFor(i),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
