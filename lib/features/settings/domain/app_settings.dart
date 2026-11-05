import 'package:flutter/material.dart';

class AppSettings {
  const AppSettings({this.themeMode = ThemeMode.system, this.hapticsEnabled = true});

  final ThemeMode themeMode;
  final bool hapticsEnabled;

  AppSettings copyWith({ThemeMode? themeMode, bool? hapticsEnabled}) => AppSettings(
        themeMode: themeMode ?? this.themeMode,
        hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
      );

  Map<String, Object?> toJson() => {'v': 1, 'theme': themeMode.name, 'haptics': hapticsEnabled};

  static AppSettings fromJson(Object? json) {
    if (json is! Map || json['v'] != 1) return const AppSettings();
    final mode = ThemeMode.values.where((m) => m.name == json['theme']);
    return AppSettings(
      themeMode: mode.isEmpty ? ThemeMode.system : mode.first,
      hapticsEnabled: json['haptics'] is bool ? json['haptics'] as bool : true,
    );
  }
}
