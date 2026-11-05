import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:worddle/core/constants/app_colors.dart';
import 'package:worddle/core/theme/app_theme.dart';
import 'package:worddle/features/game/domain/models/letter_status.dart';
import 'package:worddle/features/game/presentation/widgets/game_keyboard.dart';

void main() {
  Widget host(GameKeyboard kb) => MaterialApp(theme: AppTheme.light, home: Scaffold(body: Center(child: kb)));

  testWidgets('keys respond to taps', (tester) async {
    final letters = <String>[];
    var enter = 0;
    var back = 0;
    await tester.pumpWidget(host(GameKeyboard(
      statuses: const {},
      onLetter: letters.add,
      onEnter: () => enter++,
      onBackspace: () => back++,
    )));
    await tester.tap(find.byKey(const Key('key-q')));
    await tester.tap(find.byKey(const Key('key-m')));
    await tester.tap(find.byKey(const Key('key-enter')));
    await tester.tap(find.byKey(const Key('key-backspace')));
    expect(letters, ['q', 'm']);
    expect(enter, 1);
    expect(back, 1);
    expect(find.byType(InkWell), findsNWidgets(28)); // 26 letters + enter + backspace
  });

  testWidgets('keys display feedback colors', (tester) async {
    await tester.pumpWidget(host(GameKeyboard(
      statuses: const {'a': LetterStatus.correct, 'b': LetterStatus.present, 'c': LetterStatus.absent},
      onLetter: (_) {},
      onEnter: () {},
      onBackspace: () {},
    )));
    Color? colorOf(String k) {
      final box = tester
          .widget<AnimatedContainer>(find.descendant(of: find.byKey(Key('key-$k')), matching: find.byType(AnimatedContainer)))
          .decoration! as BoxDecoration;
      return box.color;
    }

    expect(colorOf('a'), AppColors.correctLight);
    expect(colorOf('b'), AppColors.presentLight);
    expect(colorOf('c'), AppColors.absentLight);
    expect(colorOf('d'), AppColors.keyLight);
  });
}
