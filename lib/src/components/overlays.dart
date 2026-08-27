import 'dart:async';
import 'dart:collection';

import 'package:flutter/widgets.dart';

import '../foundation/theme.dart';
import 'actions.dart';

/// Immutable description of a transient Rudi message.
@immutable
final class RudiSnack {
  /// Creates a transient message.
  const RudiSnack({
    required this.message,
    this.icon,
    this.duration = const Duration(seconds: 4),
    this.actionLabel,
    this.onAction,
    this.maxLines = 3,
  });

  /// Visible message.
  final String message;

  /// Optional leading widget.
  final Widget? icon;

  /// Display duration.
  final Duration duration;

  /// Optional action label.
  final String? actionLabel;

  /// Optional action callback.
  final VoidCallback? onAction;

  /// Maximum number of message lines.
  final int maxLines;
}

/// Programmatic controller for a [RudiMessenger].
final class RudiMessengerController {
  RudiMessengerState? _state;

  /// Queues a transient message.
  void show(RudiSnack snack) => _state?.show(snack);

  /// Dismisses the current message.
  void hideCurrent() => _state?.hideCurrent();

  /// Dismisses and removes all queued messages.
  void clear() => _state?.clear();
}

/// Hosts transient messages above its child without Material's Scaffold.
final class RudiMessenger extends StatefulWidget {
  /// Creates a messenger host.
  const RudiMessenger({required this.child, this.controller, super.key});

  /// Content below transient messages.
  final Widget child;

  /// Optional external controller.
  final RudiMessengerController? controller;

  /// Returns the closest messenger state.
  static RudiMessengerState of(BuildContext context) {
    final state = maybeOf(context);
    assert(state != null, 'No RudiMessenger found in context.');
    return state!;
  }

  /// Returns the closest messenger state, if present.
  static RudiMessengerState? maybeOf(BuildContext context) {
    return context.findAncestorStateOfType<RudiMessengerState>();
  }

  @override
  State<RudiMessenger> createState() => RudiMessengerState();
}

/// Mutable state and imperative API for [RudiMessenger].
final class RudiMessengerState extends State<RudiMessenger> {
  final Queue<RudiSnack> _queue = Queue<RudiSnack>();
  Timer? _timer;
  RudiSnack? _current;

  /// Queues a transient message.
  void show(RudiSnack snack) {
    _queue.add(snack);
    _showNext();
  }

  /// Dismisses the current message and advances the queue.
  void hideCurrent() {
    _timer?.cancel();
    if (_current != null) {
      setState(() => _current = null);
    }
    _showNext();
  }

  /// Clears the current and queued messages.
  void clear() {
    _timer?.cancel();
    _queue.clear();
    if (_current != null) {
      setState(() => _current = null);
    }
  }

  void _showNext() {
    if (_current != null || _queue.isEmpty || !mounted) {
      return;
    }
    final next = _queue.removeFirst();
    setState(() => _current = next);
    _timer = Timer(next.duration, hideCurrent);
  }

  void _attachController(RudiMessengerController? controller) {
    if (controller != null) {
      controller._state = this;
    }
  }

  void _detachController(RudiMessengerController? controller) {
    if (controller?._state == this) {
      controller?._state = null;
    }
  }

  @override
  void initState() {
    super.initState();
    _attachController(widget.controller);
  }

  @override
  void didUpdateWidget(RudiMessenger oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      _detachController(oldWidget.controller);
      _attachController(widget.controller);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _detachController(widget.controller);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.rudiTheme;
    final animationsDisabled = MediaQuery.disableAnimationsOf(context);
    return Stack(
      fit: StackFit.expand,
      children: [
        widget.child,
        PositionedDirectional(
          start: theme.spacing.md,
          end: theme.spacing.md,
          bottom: MediaQuery.viewPaddingOf(context).bottom + theme.spacing.md,
          child: IgnorePointer(
            ignoring: _current == null,
            child: AnimatedSlide(
              offset: _current == null ? const Offset(0, 1.5) : Offset.zero,
              duration: animationsDisabled
                  ? Duration.zero
                  : theme.motion.normal,
              curve: theme.motion.standardCurve,
              child: AnimatedOpacity(
                opacity: _current == null ? 0 : 1,
                duration: animationsDisabled
                    ? Duration.zero
                    : theme.motion.fast,
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 560),
                    child: _current == null
                        ? const SizedBox.shrink()
                        : _RudiSnackView(
                            snack: _current!,
                            onDismiss: hideCurrent,
                          ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

final class _RudiSnackView extends StatelessWidget {
  const _RudiSnackView({required this.snack, required this.onDismiss});

  final RudiSnack snack;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final theme = context.rudiTheme;
    return Semantics(
      liveRegion: true,
      container: true,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: theme.spacing.md,
          vertical: theme.spacing.sm,
        ),
        decoration: BoxDecoration(
          color: theme.colors.primary,
          borderRadius: BorderRadius.circular(theme.radii.lg),
        ),
        child: Row(
          children: [
            if (snack.icon != null) ...[
              IconTheme(
                data: IconThemeData(color: theme.colors.onPrimary, size: 20),
                child: snack.icon!,
              ),
              SizedBox(width: theme.spacing.sm),
            ],
            Expanded(
              child: Text(
                snack.message,
                maxLines: snack.maxLines,
                overflow: TextOverflow.ellipsis,
                style: theme.text.body.copyWith(color: theme.colors.onPrimary),
              ),
            ),
            if (snack.actionLabel case final label?) ...[
              SizedBox(width: theme.spacing.sm),
              RudiPressable(
                onPressed: () {
                  snack.onAction?.call();
                  onDismiss();
                },
                builder: (context, state) => Padding(
                  padding: EdgeInsets.all(theme.spacing.sm),
                  child: Text(
                    label,
                    style: theme.text.label.copyWith(
                      color: theme.colors.accent,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
