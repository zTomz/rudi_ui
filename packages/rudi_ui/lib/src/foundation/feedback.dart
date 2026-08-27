import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// Controls optional tactile and audible feedback produced by Rudi UI.
@immutable
final class RudiFeedbackPolicy {
  /// Creates a feedback policy.
  const RudiFeedbackPolicy({
    this.hapticsEnabled = true,
    this.soundsEnabled = true,
  });

  /// A policy that disables all optional feedback.
  static const silent = RudiFeedbackPolicy(
    hapticsEnabled: false,
    soundsEnabled: false,
  );

  /// Whether supported platforms may emit haptic feedback.
  final bool hapticsEnabled;

  /// Whether supported platforms may emit system click sounds.
  final bool soundsEnabled;

  /// Emits selection feedback when enabled.
  Future<void> selection() async {
    if (hapticsEnabled) {
      await HapticFeedback.selectionClick();
    }
  }

  /// Emits confirmation feedback when enabled.
  Future<void> confirmation() async {
    if (hapticsEnabled) {
      await HapticFeedback.mediumImpact();
    }
    if (soundsEnabled) {
      await SystemSound.play(SystemSoundType.click);
    }
  }

  /// Emits warning feedback when enabled.
  Future<void> warning() async {
    if (hapticsEnabled) {
      await HapticFeedback.heavyImpact();
    }
  }
}
