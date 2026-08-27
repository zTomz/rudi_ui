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
            final horizontalMargin = constraints.maxWidth < 480
                ? theme.spacing.md
                : theme.spacing.xl;
            final maxWidth = expanded ? 720.0 : 520.0;
            return ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: maxWidth,
                maxHeight: constraints.maxHeight - theme.spacing.xl,
              ),
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: horizontalMargin),
                padding: EdgeInsets.all(theme.spacing.lg),
                decoration: BoxDecoration(
                  color: theme.colors.surfaceContainer,
                  borderRadius: BorderRadius.circular(theme.radii.xl),
                  border: Border.all(color: theme.colors.outline),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (icon != null) ...[
                          IconTheme(
                            data: IconThemeData(
                              color: theme.colors.accent,
                              size: 28,
                            ),
                            child: icon!,
                          ),
                          SizedBox(width: theme.spacing.md),
                        ],
                        Expanded(
                          child: DefaultTextStyle(
                            style: theme.text.headline,
                            child: title,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: theme.spacing.md),
                    Flexible(
                      child: SingleChildScrollView(
                        child: DefaultTextStyle(
                          style: theme.text.body,
                          child: content,
                        ),
                      ),
                    ),
                    if (actions.isNotEmpty) ...[
                      SizedBox(height: theme.spacing.lg),
                      LayoutBuilder(
                        builder: (context, actionConstraints) {
                          if (actionConstraints.maxWidth < 420) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: actions
                                  .map(
                                    (action) => Padding(
                                      padding: EdgeInsets.only(
                                        top: theme.spacing.sm,
                                      ),
                                      child: action,
                                    ),
                                  )
                                  .toList(),
                            );
                          }
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: actions
                                .map(
                                  (action) => Padding(
                                    padding: EdgeInsetsDirectional.only(
                                      start: theme.spacing.sm,
                                    ),
                                    child: action,
                                  ),
                                )
                                .toList(),
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Shows a modal Rudi bottom sheet.
Future<T?> showRudiBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  required String barrierLabel,
  bool barrierDismissible = true,
  bool useRootNavigator = true,
}) {
  final navigator = Navigator.of(context, rootNavigator: useRootNavigator);
  final themes = InheritedTheme.capture(from: context, to: navigator.context);
  return navigator.push<T>(
    _RudiBottomSheetRoute<T>(
      builder: builder,
      themes: themes,
      barrierLabel: barrierLabel,
      barrierDismissible: barrierDismissible,
      barrierColor: context.rudiTheme.colors.scrim,
      animationsDisabled: MediaQuery.disableAnimationsOf(context),
    ),
  );
}

final class _RudiBottomSheetRoute<T> extends PopupRoute<T> {
  _RudiBottomSheetRoute({
    required this.builder,
    required this.themes,
    required this._barrierLabel,
    required this._barrierDismissible,
    required this._barrierColor,
    required this.animationsDisabled,
  });

  final WidgetBuilder builder;
  final CapturedThemes themes;
  final bool animationsDisabled;
  final String _barrierLabel;
  final bool _barrierDismissible;
  final Color _barrierColor;

  @override
  Color? get barrierColor => _barrierColor;

  @override
  bool get barrierDismissible => _barrierDismissible;

  @override
  String? get barrierLabel => _barrierLabel;

  @override
  Duration get transitionDuration =>
      animationsDisabled ? Duration.zero : const Duration(milliseconds: 300);

  @override
  Duration get reverseTransitionDuration =>
      animationsDisabled ? Duration.zero : const Duration(milliseconds: 200);

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return themes.wrap(
      Align(
        alignment: Alignment.bottomCenter,
        child: RudiBottomSheet(
          onDismissed: barrierDismissible ? () => navigator?.pop() : null,
          child: builder(context),
        ),
      ),
    );
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final curved = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
    );
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 1),
        end: Offset.zero,
      ).animate(curved),
      child: child,
    );
  }
}

/// Surface and drag behavior for a modal bottom sheet.
final class RudiBottomSheet extends StatefulWidget {
  /// Creates a bottom-sheet surface.
  const RudiBottomSheet({
    required this.child,
    this.onDismissed,
    this.maxWidth = 720,
    super.key,
  });

  /// Sheet content.
  final Widget child;

  /// Called when a downward drag crosses the dismissal threshold.
  final VoidCallback? onDismissed;

  /// Maximum sheet width on large windows.
  final double maxWidth;

  @override
  State<RudiBottomSheet> createState() => _RudiBottomSheetState();
}

final class _RudiBottomSheetState extends State<RudiBottomSheet> {
  double _offset = 0;

  @override
  Widget build(BuildContext context) {
    final theme = context.rudiTheme;
    return SafeArea(
      top: false,
      child: Transform.translate(
        offset: Offset(0, _offset),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: widget.maxWidth,
            maxHeight: MediaQuery.sizeOf(context).height * 0.92,
          ),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onVerticalDragUpdate: widget.onDismissed == null
                ? null
                : (details) {
                    setState(() {
                      _offset = (_offset + details.delta.dy).clamp(0, 400);
                    });
                  },
            onVerticalDragEnd: widget.onDismissed == null
                ? null
                : (details) {
                    if (_offset > 120 || (details.primaryVelocity ?? 0) > 700) {
                      widget.onDismissed!();
                    } else {
                      setState(() => _offset = 0);
                    }
                  },
            child: Container(
              padding: EdgeInsets.fromLTRB(
                theme.spacing.lg,
                theme.spacing.sm,
                theme.spacing.lg,
                MediaQuery.viewInsetsOf(context).bottom + theme.spacing.lg,
              ),
              decoration: BoxDecoration(
                color: theme.colors.surfaceContainer,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(theme.radii.xl),
                ),
                border: Border.all(color: theme.colors.outline),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 48,
                    height: 5,
                    margin: EdgeInsets.only(bottom: theme.spacing.md),
                    decoration: BoxDecoration(
                      color: theme.colors.outline,
                      borderRadius: BorderRadius.circular(theme.radii.pill),
                    ),
                  ),
                  Flexible(child: widget.child),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
