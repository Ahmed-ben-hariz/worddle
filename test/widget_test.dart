import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:worddle/app.dart';

import 'helpers/test_helpers.dart';

void main() {
  testWidgets('app boots into the game screen', (tester) async {
    final prefs = await freshPrefs();
    await tester.pumpWidget(ProviderScope(overrides: testOverrides(prefs), child: const WorddleApp()));
    await tester.pump();
    expect(find.text('WORDDLE'), findsOneWidget);
    expect(find.byIcon(Icons.leaderboard_outlined), findsOneWidget);
    expect(find.byIcon(Icons.help_outline_rounded), findsOneWidget);
    expect(find.byIcon(Icons.settings_outlined), findsOneWidget);
  });
}
