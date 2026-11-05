import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    return Scaffold(
      appBar: AppBar(title: const Text('Settings'), backgroundColor: Colors.transparent, scrolledUnderElevation: 0),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const Text('THEME', style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 1.2)),
                const SizedBox(height: 10),
                SegmentedButton<ThemeMode>(
                  showSelectedIcon: false,
                  segments: const [
                    ButtonSegment(value: ThemeMode.light, label: Text('Light'), icon: Icon(Icons.light_mode_outlined)),
                    ButtonSegment(value: ThemeMode.dark, label: Text('Dark'), icon: Icon(Icons.dark_mode_outlined)),
                    ButtonSegment(value: ThemeMode.system, label: Text('System'), icon: Icon(Icons.brightness_auto_outlined)),
                  ],
                  selected: {settings.themeMode},
                  onSelectionChanged: (s) => notifier.setThemeMode(s.first),
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  key: const Key('haptics-switch'),
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Haptic feedback'),
                  subtitle: const Text('Vibrate lightly on key presses and results'),
                  value: settings.hapticsEnabled,
                  onChanged: notifier.setHaptics,
                ),
                const Divider(height: 32),
                const Text('ABOUT', style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 1.2)),
                const SizedBox(height: 8),
                const Text(
                  'Worddle works fully offline. The word lists are derived from the '
                  'public-domain dwyl/english-words project (Unlicense) plus a '
                  'hand-curated list of answers. The daily puzzle changes at 00:00 UTC.',
                  style: TextStyle(height: 1.4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
