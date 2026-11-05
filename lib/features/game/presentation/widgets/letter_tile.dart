import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/models/letter_status.dart';

/// One square of the grid. [status] is null until the guess is submitted.
/// [flip] (0..1) drives the reveal: the colored face appears past 0.5.
class LetterTile extends StatefulWidget {
  const LetterTile({
    super.key,
    required this.letter,
    this.status,
    this.flip = 1,
    this.size = 56,
    this.lift = 0,
  });

  final String letter;
  final LetterStatus? status;
  final double flip;
  final double size;

  /// Upward offset in logical pixels (win celebration hop).
  final double lift;

  @override
  State<LetterTile> createState() => _LetterTileState();
}

class _LetterTileState extends State<LetterTile> with SingleTickerProviderStateMixin {
  late final AnimationController _pop =
      AnimationController(vsync: this, duration: AppConstants.popDuration);

  @override
  void didUpdateWidget(LetterTile old) {
    super.didUpdateWidget(old);
    if (old.letter.isEmpty && widget.letter.isNotEmpty && widget.status == null) {
      _pop.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _pop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.gameColors;
    final status = widget.status;
    final revealed = status != null && widget.flip >= 0.5;
    final angle = status == null
        ? 0.0
        : (widget.flip < 0.5 ? widget.flip * math.pi : (widget.flip - 1) * math.pi);

    final Color bg = revealed ? colors.colorFor(status) : colors.tileEmpty;
    final Color border = revealed
        ? bg
        : (widget.letter.isNotEmpty ? colors.tileBorderFilled : colors.tileBorder);
    final Color fg = revealed ? colors.onColorFor(status) : colors.tileText;

    final face = Container(
      key: const Key('tile-face'),
      width: widget.size,
      height: widget.size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: border, width: 2),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        widget.letter.toUpperCase(),
        style: TextStyle(
          color: fg,
          fontSize: widget.size * 0.52,
          fontWeight: FontWeight.w800,
          height: 1,
        ),
      ),
    );

    return Semantics(
      label: widget.letter.isEmpty
          ? 'empty'
          : '${widget.letter}, ${status == null ? 'not submitted' : status.name}',
      excludeSemantics: true,
      child: Transform.translate(
        offset: Offset(0, -widget.lift),
        child: AnimatedBuilder(
          animation: _pop,
          builder: (context, child) => Transform.scale(
            scale: 1 + 0.12 * math.sin(_pop.value * math.pi),
            child: child,
          ),
          child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.0015)
              ..rotateX(angle),
            child: face,
          ),
        ),
      ),
    );
  }
}
