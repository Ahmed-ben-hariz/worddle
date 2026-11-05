import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:worddle/core/constants/app_colors.dart';
import 'package:worddle/core/theme/app_theme.dart';
import 'package:worddle/features/game/domain/models/guess_result.dart';
import 'package:worddle/features/game/domain/models/letter_status.dart';
import 'package:worddle/features/game/presentation/widgets/guess_grid.dart';
import 'package:worddle/features/game/presentation/widgets/letter_tile.dart';

Widget host(Widget child) => MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(body: SizedBox(width: 360, height: 420, child: child)),
    );

void main() {
  testWidgets('displays six rows and five columns', (tester) async {
    await tester.pumpWidget(host(const GuessGrid(results: [], currentInput: '')));
    expect(find.byType(LetterTile), findsNWidgets(30));
    expect(find.byKey(const ValueKey('row-0')), findsOneWidget);
    expect(find.byKey(const ValueKey('row-5')), findsOneWidget);
  });

  testWidgets('shows typed letters and feedback colors', (tester) async {
    const results = [
      GuessResult(word: 'slate', statuses: [
        LetterStatus.absent,
        LetterStatus.absent,
        LetterStatus.present,
        LetterStatus.absent,
        LetterStatus.correct,
      ]),
    ];
    await tester.pumpWidget(host(const GuessGrid(results: results, currentInput: 'cr')));
    await tester.pump();

    Color faceColor(int tileIndex) {
      final face = find.descendant(of: find.byType(LetterTile).at(tileIndex), matching: find.byKey(const Key('tile-face')));
      final box = tester.widget<Container>(face).decoration! as BoxDecoration;
      return box.color!;
    }

    expect(faceColor(0), AppColors.absentLight);
    expect(faceColor(2), AppColors.presentLight);
    expect(faceColor(4), AppColors.correctLight);
    expect(faceColor(5), AppColors.tileEmptyLight); // typed, not yet submitted
    expect(find.text('S'), findsOneWidget);
    expect(find.text('C'), findsOneWidget);
    expect(find.text('R'), findsOneWidget);
  });
}
