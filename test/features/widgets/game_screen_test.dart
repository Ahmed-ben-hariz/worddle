import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:worddle/app.dart';
import 'package:worddle/core/constants/app_constants.dart';
import 'package:worddle/features/game/presentation/widgets/game_result_dialog.dart';
import 'package:worddle/features/game/presentation/widgets/letter_tile.dart';

import '../../helpers/test_helpers.dart';

Future<void> tapWord(WidgetTester tester, String word) async {
  for (final ch in word.split('')) {
    await tester.tap(find.byKey(Key('key-$ch')));
    await tester.pump(const Duration(milliseconds: 20));
  }
}

void main() {
  testWidgets('full game: type, submit, win and see the result dialog', (tester) async {
    tester.view.physicalSize = const Size(360, 640); // small phone
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final prefs = await freshPrefs();
    await tester.pumpWidget(ProviderScope(
      overrides: testOverrides(prefs, timings: const AnimationTimings()),
      child: const WorddleApp(),
    ));
    await tester.pump();
    expect(find.text('WORDDLE'), findsOneWidget);
    expect(find.byType(LetterTile), findsNWidgets(30));

    await tapWord(tester, 'zzzzz');
    await tester.tap(find.byKey(const Key('key-enter')));
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.text('Not in word list'), findsOneWidget);
    for (var i = 0; i < 5; i++) {
      await tester.tap(find.byKey(const Key('key-backspace')));
      await tester.pump(const Duration(milliseconds: 20));
    }

    await tapWord(tester, 'crane');
    await tester.tap(find.byKey(const Key('key-enter')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 4));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byType(GameResultDialog), findsOneWidget);
    expect(find.text('You won!'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
