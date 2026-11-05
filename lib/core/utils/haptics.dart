import 'package:flutter/services.dart';

/// Thin wrapper so haptics respect the user setting and never throw.
class Haptics {
  const Haptics(this.isEnabled);

  final bool Function() isEnabled;

  void _run(Future<void> Function() action) {
    if (!isEnabled()) return;
    Future<void>.sync(action).catchError((Object _) {});
  }

  void tap() => _run(HapticFeedback.selectionClick);
  void error() => _run(HapticFeedback.heavyImpact);
  void success() => _run(HapticFeedback.mediumImpact);
}
