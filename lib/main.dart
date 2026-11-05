import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/providers.dart';
import 'features/game/data/word_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  try {
    final prefs = await SharedPreferences.getInstance();
    final words = await const WordRepository().load();
    runApp(ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        wordListProvider.overrideWithValue(words),
      ],
      child: const WorddleApp(),
    ));
  } catch (error) {
    runApp(MaterialApp(
      home: Scaffold(body: Center(child: Padding(padding: const EdgeInsets.all(24), child: Text('Worddle could not start:\n$error')))),
    ));
  }
}
