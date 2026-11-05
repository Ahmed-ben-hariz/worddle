import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../settings/domain/app_settings.dart';
import '../../statistics/domain/game_stats.dart';
import '../domain/models/game_state.dart';
import '../domain/models/game_status.dart';

/// All SharedPreferences access lives here. Every read is defensive: missing,
/// corrupt or outdated data silently falls back to defaults.
class GameStorage {
  GameStorage(this._prefs);

  final SharedPreferences _prefs;

  static const _settingsKey = 'worddle.v1.settings';
  static const _modeKey = 'worddle.v1.mode';
  static String _gameKey(GameMode m) => 'worddle.v1.game.${m.name}';
  static String _statsKey(GameMode m) => 'worddle.v1.stats.${m.name}';

  Object? _readJson(String key) {
    try {
      final raw = _prefs.getString(key);
      return raw == null ? null : jsonDecode(raw);
    } catch (_) {
      return null;
    }
  }

  Future<void> _writeJson(String key, Object value) async {
    try {
      await _prefs.setString(key, jsonEncode(value));
    } catch (_) {
      // Persistence is best-effort; never crash gameplay.
    }
  }

  AppSettings loadSettings() => AppSettings.fromJson(_readJson(_settingsKey));
  Future<void> saveSettings(AppSettings s) => _writeJson(_settingsKey, s.toJson());

  GameMode loadMode() {
    final raw = _prefs.getString(_modeKey);
    return GameMode.values.firstWhere((m) => m.name == raw, orElse: () => GameMode.daily);
  }

  Future<void> saveMode(GameMode mode) async {
    try {
      await _prefs.setString(_modeKey, mode.name);
    } catch (_) {}
  }

  GameState? loadGame(GameMode mode) {
    final game = GameState.fromJson(_readJson(_gameKey(mode)));
    return game != null && game.mode == mode ? game : null;
  }

  Future<void> saveGame(GameState game) => _writeJson(_gameKey(game.mode), game.toJson());

  GameStats loadStats(GameMode mode) => GameStats.fromJson(_readJson(_statsKey(mode)));
  Future<void> saveStats(GameMode mode, GameStats stats) => _writeJson(_statsKey(mode), stats.toJson());
}
