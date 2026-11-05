import 'package:flutter/material.dart';

import '../../domain/models/letter_status.dart';
import 'keyboard_key.dart';

/// Three-row QWERTY keyboard with Enter and Backspace.
class GameKeyboard extends StatelessWidget {
  const GameKeyboard({
    super.key,
    required this.statuses,
    required this.onLetter,
    required this.onEnter,
    required this.onBackspace,
    this.keyHeight = 54,
  });

  final Map<String, LetterStatus> statuses;
  final ValueChanged<String> onLetter;
  final VoidCallback onEnter;
  final VoidCallback onBackspace;
  final double keyHeight;

  static const List<String> rows = ['qwertyuiop', 'asdfghjkl', 'zxcvbnm'];

  Widget _letter(String ch) => Expanded(
        flex: 10,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2.5),
          child: KeyboardKey(
            key: Key('key-$ch'),
            label: ch.toUpperCase(),
            status: statuses[ch] ?? LetterStatus.unknown,
            height: keyHeight,
            onTap: () => onLetter(ch),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(children: [for (final ch in rows[0].split('')) _letter(ch)]),
          const SizedBox(height: 6),
          Row(children: [
            const Spacer(flex: 5),
            for (final ch in rows[1].split('')) _letter(ch),
            const Spacer(flex: 5),
          ]),
          const SizedBox(height: 6),
          Row(children: [
            Expanded(
              flex: 15,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2.5),
                child: KeyboardKey(
                  key: const Key('key-enter'),
                  label: 'ENTER',
                  semanticLabel: 'Enter',
                  height: keyHeight,
                  onTap: onEnter,
                ),
              ),
            ),
            for (final ch in rows[2].split('')) _letter(ch),
            Expanded(
              flex: 15,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2.5),
                child: KeyboardKey(
                  key: const Key('key-backspace'),
                  icon: Icons.backspace_outlined,
                  semanticLabel: 'Backspace',
                  height: keyHeight,
                  onTap: onBackspace,
                ),
              ),
            ),
          ]),
        ],
      ),
    );
  }
}
