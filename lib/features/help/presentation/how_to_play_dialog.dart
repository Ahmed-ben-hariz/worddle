import 'package:flutter/material.dart';

import '../../game/domain/models/letter_status.dart';
import '../../game/presentation/widgets/letter_tile.dart';

class HowToPlayDialog extends StatelessWidget {
  const HowToPlayDialog({super.key});

  Widget _example(String word, int highlight, LetterStatus status) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          for (var i = 0; i < word.length; i++)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: LetterTile(
                letter: word[i],
                status: i == highlight ? status : null,
                size: 38,
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                const Expanded(
                  child: Text('How to play', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                ),
                IconButton(
                  tooltip: 'Close',
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ]),
              const SizedBox(height: 6),
              const Text(
                'Guess the hidden five-letter word in six tries. Each guess must be a valid word. '
                'After every guess the tiles change color to show how close you were.',
                style: TextStyle(height: 1.4),
              ),
              const Divider(height: 28),
              const Text('Examples', style: TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              _example('weary', 0, LetterStatus.correct),
              const Text('W is in the word and in the correct spot.', style: TextStyle(height: 1.4)),
              const SizedBox(height: 10),
              _example('pills', 1, LetterStatus.present),
              const Text('I is in the word but in the wrong spot.', style: TextStyle(height: 1.4)),
              const SizedBox(height: 10),
              _example('vague', 3, LetterStatus.absent),
              const Text('U is not in the word in any spot.', style: TextStyle(height: 1.4)),
              const Divider(height: 28),
              const Text(
                'Repeated letters are handled carefully: a letter only turns yellow or green as many '
                'times as it really appears in the answer.',
                style: TextStyle(height: 1.4),
              ),
              const SizedBox(height: 10),
              const Text(
                'Daily Challenge: one puzzle for everyone, new at 00:00 UTC.\n'
                'Practice: unlimited random puzzles that do not affect your daily stats.',
                style: TextStyle(height: 1.4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
