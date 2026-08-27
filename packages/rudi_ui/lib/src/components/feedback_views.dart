import 'package:flutter/widgets.dart';

import '../foundation/theme.dart';
import 'actions.dart';
import 'icons.dart';
import 'progress.dart';

/// A neutral empty-state presentation.
final class RudiEmptyView extends StatelessWidget {
  /// Creates an empty-state view.
  const RudiEmptyView({
    required this.title,
    required this.message,
    this.icon,
    this.action,
    this.compact = false,
    super.key,
  });

  /// Empty-state title.
  final String title;

  /// Empty-state explanation.
  final String message;

  /// Optional illustration or icon.
  final Widget? icon;

  /// Optional recovery or creation action.
  final Widget? action;

  /// Whether to use a compact inline layout.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = context.rudiTheme;
    final content = <Widget>[
      IconTheme(
        data: IconThemeData(
          color: theme.colors.accent,
          size: compact ? 28 : 48,
        ),
        child: icon ?? const RudiGlyph(RudiGlyphType.info),
      ),
      SizedBox(height: theme.spacing.md),
      Text(title, textAlign: TextAlign.center, style: theme.text.title),
      SizedBox(height: theme.spacing.xs),
      Text(
        message,
        textAlign: TextAlign.center,
        style: theme.text.body.copyWith(color: theme.colors.mutedForeground),
      ),
      if (action != null) ...[SizedBox(height: theme.spacing.lg), action!],
    ];
    return Semantics(
      container: true,
      child: Container(
        padding: EdgeInsets.all(compact ? theme.spacing.md : theme.spacing.xl),
        child: Column(mainAxisSize: MainAxisSize.min, children: content),
      ),
    );
  }
}

/// A neutral error presentation with injected recovery actions.
final class RudiErrorView extends StatefulWidget {
  /// Creates an error view.
  const RudiErrorView({
    required this.title,
    required this.message,
    this.details,
    this.showDetailsLabel,
    this.hideDetailsLabel,
    this.primaryAction,
    this.secondaryAction,
    this.compact = false,
    super.key,
  }) : assert(
         details == null ||
             (showDetailsLabel != null && hideDetailsLabel != null),
         'Localized details labels are required when details are provided.',
       );

  /// Error title.
  final String title;

  /// User-facing error explanation.
  final String message;

  /// Optional technical details.
  final String? details;

  /// Localized label used to reveal [details].
  final String? showDetailsLabel;

  /// Localized label used to hide [details].
  final String? hideDetailsLabel;

  /// Primary recovery action.
  final Widget? primaryAction;

  /// Secondary recovery or reporting action.
  final Widget? secondaryAction;

  /// Whether to use a compact inline layout.
  final bool compact;

  @override
  State<RudiErrorView> createState() => _RudiErrorViewState();
}

final class _RudiErrorViewState extends State<RudiErrorView> {
  bool _detailsVisible = false;

  @override
  Widget build(BuildContext context) {
    final theme = context.rudiTheme;
    return Semantics(
      container: true,
      liveRegion: true,
      child: Container(
        padding: EdgeInsets.all(
          widget.compact ? theme.spacing.md : theme.spacing.xl,
        ),
        decoration: widget.compact
            ? BoxDecoration(
                color: theme.colors.surfaceContainer,
                borderRadius: BorderRadius.circular(theme.radii.lg),
              )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RudiGlyph(
              RudiGlyphType.error,
              size: widget.compact ? 28 : 48,
              color: theme.colors.error,
            ),
            SizedBox(height: theme.spacing.md),
            Text(
              widget.title,
              textAlign: TextAlign.center,
              style: theme.text.title,
            ),
            SizedBox(height: theme.spacing.xs),
            Text(
              widget.message,
              textAlign: TextAlign.center,
              style: theme.text.body.copyWith(
                color: theme.colors.mutedForeground,
              ),
            ),
            if (widget.details case final details?) ...[
              SizedBox(height: theme.spacing.sm),
              RudiPressable(
                onPressed: () =>
                    setState(() => _detailsVisible = !_detailsVisible),
                builder: (context, state) => Text(
                  _detailsVisible
                      ? widget.hideDetailsLabel!
                      : widget.showDetailsLabel!,
                  style: theme.text.label.copyWith(color: theme.colors.accent),
                ),
              ),
              if (_detailsVisible) ...[
                SizedBox(height: theme.spacing.sm),
                Text(
                  details,
                  style: theme.text.caption.copyWith(
                    color: theme.colors.mutedForeground,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ],
            if (widget.primaryAction != null ||
                widget.secondaryAction != null) ...[
              SizedBox(height: theme.spacing.lg),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: theme.spacing.sm,
                runSpacing: theme.spacing.sm,
                children: [
                  if (widget.secondaryAction != null) widget.secondaryAction!,
                  if (widget.primaryAction != null) widget.primaryAction!,
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// A centered loading state with optional status copy.
final class RudiLoadingView extends StatelessWidget {
  /// Creates a loading state.
  const RudiLoadingView({this.label, super.key});

  /// Optional visible and semantic status label.
  final String? label;

  @override
  Widget build(BuildContext context) {
    final theme = context.rudiTheme;
    return Semantics(
      liveRegion: true,
      label: label,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 240),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const RudiLinearProgress(),
              if (label case final text?) ...[
                SizedBox(height: theme.spacing.md),
                Text(
                  text,
                  textAlign: TextAlign.center,
                  style: theme.text.body.copyWith(
                    color: theme.colors.mutedForeground,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
