import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

/// Small message pill that fades in, holds, then fades out on its own
/// (no timers - driven by an animation controller). Give it a new key
/// per message to replay.
class GameToast extends StatefulWidget {
  const GameToast({super.key, required this.message});

  final String message;

  @override
  State<GameToast> createState() => _GameToastState();
}

class _GameToastState extends State<GameToast> with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1900))..forward();

  late final Animation<double> _opacity = TweenSequence<double>([
    TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 8),
    TweenSequenceItem(tween: ConstantTween(1.0), weight: 74),
    TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 18),
  ]).animate(_controller);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.gameColors;
    return IgnorePointer(
      child: FadeTransition(
        opacity: _opacity,
        child: Container(
          key: const Key('game-toast'),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            color: colors.toastBackground,
            borderRadius: BorderRadius.circular(10),
            boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 12, offset: Offset(0, 4))],
          ),
          child: Text(
            widget.message,
            style: TextStyle(color: colors.toastText, fontWeight: FontWeight.w800, letterSpacing: 0.5),
          ),
        ),
      ),
    );
  }
}
