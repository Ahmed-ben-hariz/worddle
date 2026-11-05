import 'package:flutter/services.dart';

import '../domain/models/word_list.dart';

/// Loads the bundled, offline dictionaries. Never touches the network.
class WordRepository {
  const WordRepository();

  static const String answersAsset = 'assets/words/answers.txt';
  static const String guessesAsset = 'assets/words/valid_guesses.txt';

  Future<WordList> load({AssetBundle? bundle}) async {
    final b = bundle ?? rootBundle;
    final answers = await b.loadString(answersAsset);
    final guesses = await b.loadString(guessesAsset);
    return WordList.fromText(answers: answers, guesses: guesses);
  }
}
