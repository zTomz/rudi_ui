import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../foundation/theme.dart';

/// Shows a modal Rudi dialog.
Future<T?> showRudiDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  required String barrierLabel,
  bool barrierDismissible = true,
  bool useRootNavigator = true,
}) {
  final themes = InheritedTheme.capture(
    from: context,
    to: Navigator.of(context, rootNavigator: useRootNavigator).context,
  );
  final colors = context.rudiTheme.colors;
  return showGeneralDialog<T>(
    context: context,
    useRootNavigator: useRootNavigator,
    barrierDismissible: barrierDismissible,
    barrierLabel: barrierLabel,
    barrierColor: colors.scrim,
    transitionDuration: MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : context.rudiTheme.motion.normal,
    pageBuilder: (context, animation, secondaryAnimation) {
      return themes.wrap(builder(context));
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: context.rudiTheme.motion.standardCurve,
      );
      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.96, end: 1).animate(curved),
          child: child,
        ),
      );
    },
  );
}

/// A responsive modal dialog surface.
final class RudiDialog extends StatelessWidget {
  /// Creates a Rudi dialog.
  const RudiDialog({
    required this.title,
    required this.content,
    this.icon,
    this.actions = const <Widget>[],
    this.expanded = false,
    super.key,
  });

  /// Dialog title.
  final Widget title;

  /// Main dialog content.
  final Widget content;

  /// Optional leading header icon.
  final Widget? icon;

  /// Dialog actions.
  final List<Widget> actions;

  /// Whether to use the larger dialog width.
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final theme = context.rudiTheme;
    return SafeArea(
      child: Center(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final dialogPadding = constraints.maxWidth < 420
                ? theme.spacing.lg
                : theme.spacing.xl;
            final maxContentWidth = math.max(
              220.0,
              constraints.maxWidth -
                  (theme.spacing.md * 2) -
                  (dialogPadding * 2),
            );
            final contentWidth = expanded
                ? math.min(600.0, maxContentWidth)
                : math.min(290.0, maxContentWidth);
            return Container(
              margin: EdgeInsets.all(theme.spacing.md),
              constraints: BoxConstraints(
                maxWidth: contentWidth + dialogPadding * 2,
                maxHeight: constraints.maxHeight - theme.spacing.md * 2,
              ),
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: theme.colors.background,
                borderRadius: BorderRadius.circular(theme.radii.xl),
              ),
              child: SingleChildScrollView(
                padding: EdgeInsets.all(dialogPadding),
                child: SizedBox(
                  width: contentWidth,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (expanded)
                        _ExpandedDialogHeader(icon: icon, title: title)
                      else
                        _DialogHeader(icon: icon, title: title),
                      SizedBox(height: theme.spacing.md),
                      DefaultTextStyle(
                        style: theme.text.body.copyWith(
                          color: theme.colors.mutedForeground,
                        ),
                        textAlign: expanded
                            ? TextAlign.start
                            : TextAlign.center,
                        child: content,
                      ),
                      if (actions.isNotEmpty) ...[
                        SizedBox(height: theme.spacing.lg),
                        _DialogActions(
                          actions: actions,
                          contentWidth: contentWidth,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

final class _DialogHeader extends StatelessWidget {
  const _DialogHeader({required this.icon, required this.title});

  final Widget? icon;
  final Widget title;

  @override
  Widget build(BuildContext context) {
    final theme = context.rudiTheme;
    return Column(
      children: [
        if (icon != null) ...[
          IconTheme(
            data: IconThemeData(color: theme.colors.foreground, size: 60),
            child: icon!,
          ),
          SizedBox(height: theme.spacing.lg),
        ],
        DefaultTextStyle(
          style: theme.text.headline,
          textAlign: TextAlign.center,
          child: title,
        ),
      ],
    );
  }
}

final class _ExpandedDialogHeader extends StatelessWidget {
  const _ExpandedDialogHeader({required this.icon, required this.title});

  final Widget? icon;
  final Widget title;

  @override
  Widget build(BuildContext context) {
    final theme = context.rudiTheme;
    return Row(
      children: [
        if (icon != null) ...[
          IconTheme(
            data: IconThemeData(color: theme.colors.foreground, size: 40),
            child: icon!,
          ),
          SizedBox(width: theme.spacing.md),
        ],
        Expanded(
          child: DefaultTextStyle(style: theme.text.headline, child: title),
        ),
      ],
    );
  }
}

final class _DialogActions extends StatelessWidget {
  const _DialogActions({required this.actions, required this.contentWidth});

  final List<Widget> actions;
  final double contentWidth;

  @override
  Widget build(BuildContext context) {
    final spacing = context.rudiTheme.spacing.sm;
    if (contentWidth >= 460) {
      return Row(
        children: [
          for (final (index, action) in actions.indexed) ...[
            Expanded(child: action),
            if (index < actions.length - 1) SizedBox(width: spacing),
          ],
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (index, action) in actions.indexed) ...[
          action,
          if (index < actions.length - 1) SizedBox(height: spacing),
        ],
      ],
    );
  }
}
