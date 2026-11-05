import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../features/game/data/game_storage.dart';
import '../features/game/domain/models/word_list.dart';
import '../features/settings/presentation/providers/settings_provider.dart';
import 'constants/app_constants.dart';
import 'utils/haptics.dart';

/// Overridden in `main()` (and in tests) with real instances.
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) => throw UnimplementedError('sharedPreferencesProvider must be overridden'));
final wordListProvider = Provider<WordList>((ref) => throw UnimplementedError('wordListProvider must be overridden'));

final storageProvider = Provider<GameStorage>((ref) => GameStorage(ref.watch(sharedPreferencesProvider)));

/// Current instant; overridable for tests.
final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);
final randomProvider = Provider<Random>((ref) => Random());
final animationTimingsProvider = Provider<AnimationTimings>((ref) => const AnimationTimings());

final hapticsProvider = Provider<Haptics>((ref) => Haptics(() => ref.read(settingsProvider).hapticsEnabled));
