import 'package:flutter/physics.dart';
import 'package:flutter/widgets.dart';

import '../foundation/theme.dart';
import 'actions.dart';
import 'icons.dart';

/// Opens a spring-driven Rudi bottom sheet.
Future<T?> showRudiBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  required String barrierLabel,
  bool useRootNavigator = false,
  bool isDismissible = true,
  bool enableDrag = true,
  Color? barrierColor,
  RouteSettings? routeSettings,
  bool? requestFocus,
}) {
  final navigator = Navigator.of(context, rootNavigator: useRootNavigator);
  return navigator.push(
    _RudiSheetRoute<T>(
      builder: builder,
      capturedThemes: InheritedTheme.capture(
        from: context,
        to: navigator.context,
      ),
      animationsDisabled: MediaQuery.disableAnimationsOf(context),
      enableDrag: enableDrag,
      isDismissible: isDismissible,
      modalBarrierColor: barrierColor ?? context.rudiTheme.colors.scrim,
      modalBarrierLabel: barrierLabel,
      settings: routeSettings,
      requestFocus: requestFocus,
    ),
  );
}

/// A reusable bottom-sheet shell for forms and actions.
final class RudiBottomSheet extends StatelessWidget {
  /// Creates a Rudi bottom-sheet surface.
  const RudiBottomSheet({
    required this.title,
    required this.children,
    this.actions = const <Widget>[],
    this.trailing,
    this.scrollable = true,
    super.key,
  });

  /// Title displayed at the top of the sheet.
  final Widget title;

  /// Main sheet content.
  final List<Widget> children;

  /// Actions displayed after the content.
  final List<Widget> actions;

  /// Optional action shown next to the title.
  final Widget? trailing;

  /// Whether overflowing content scrolls inside the sheet.
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    final theme = context.rudiTheme;
    final body = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ..._spaced(children, SizedBox(height: theme.spacing.md)),
        if (actions.isNotEmpty) ...[
          if (children.isNotEmpty) SizedBox(height: theme.spacing.lg),
          ..._spaced(actions, SizedBox(height: theme.spacing.sm)),
        ],
      ],
    );

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(
          left: theme.spacing.md,
          right: theme.spacing.md,
          top: theme.spacing.md,
          bottom: MediaQuery.viewInsetsOf(context).bottom + theme.spacing.md,
        ),
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: theme.colors.background,
            borderRadius: BorderRadius.circular(theme.radii.xl),
          ),
          padding: EdgeInsets.all(theme.spacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: DefaultTextStyle(
                      style: theme.text.title,
                      child: title,
                    ),
                  ),
                  ?trailing,
                ],
              ),
              if (children.isNotEmpty || actions.isNotEmpty) ...[
                SizedBox(height: theme.spacing.md),
                if (scrollable)
                  Flexible(
                    child: SingleChildScrollView(
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      child: body,
                    ),
                  )
                else
                  body,
              ],
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _spaced(List<Widget> widgets, Widget gap) {
    return [
      for (final (index, widget) in widgets.indexed) ...[
        widget,
        if (index < widgets.length - 1) gap,
      ],
    ];
  }
}

/// Standard close action for a [RudiBottomSheet].
final class RudiBottomSheetCloseButton extends StatelessWidget {
  /// Stable key used by the standard close control.
  static const buttonKey = ValueKey('close-bottom-sheet-button');

  /// Creates a bottom-sheet close action.
  const RudiBottomSheetCloseButton({
    required this.semanticLabel,
    this.icon = const RudiGlyph(RudiGlyphType.close),
    this.onPressed,
    super.key,
  });

  /// Accessible close label supplied by the application localization.
  final String semanticLabel;

  /// Close icon owned by the consuming application or Rudi UI.
  final Widget icon;

  /// Optional override; defaults to popping the closest navigator.
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return RudiIconButton(
      key: buttonKey,
      icon: icon,
      semanticLabel: semanticLabel,
      onPressed: onPressed ?? Navigator.of(context).pop,
    );
  }
}

final class _RudiSheetRoute<T> extends PopupRoute<T> {
  _RudiSheetRoute({
    required this.builder,
    required this.capturedThemes,
    required this.animationsDisabled,
    required this.enableDrag,
    required this.isDismissible,
    required this.modalBarrierColor,
    required this.modalBarrierLabel,
    super.settings,
    super.requestFocus,
  });

  final WidgetBuilder builder;
  final CapturedThemes capturedThemes;
  final bool animationsDisabled;
  final bool enableDrag;
  final bool isDismissible;
  final Color modalBarrierColor;
  final String modalBarrierLabel;

  static const _enterSpring = SpringDescription(
    mass: 1,
    stiffness: 438.6,
    damping: 41.9,
  );
  static const _exitSpring = SpringDescription(
    mass: 1,
    stiffness: 987,
    damping: 62.8,
  );
  static const _overdragResistance = 100.0;
  static const _closeVelocity = 0.9;
  static const _closePosition = 0.5;

  double? _releaseVelocity;
  double _reducedDrag = 0;
  var _popped = false;

  Animation<double> get sheetAnimation => controller!;
  double get sheetValue => controller!.value;

  @override
  Color get barrierColor => modalBarrierColor;

  @override
  bool get barrierDismissible => isDismissible;

  @override
  String get barrierLabel => modalBarrierLabel;

  @override
  Curve get barrierCurve => Curves.easeOutCubic;

  @override
  Duration get transitionDuration =>
      animationsDisabled ? Duration.zero : const Duration(milliseconds: 300);

  @override
  Duration get reverseTransitionDuration =>
      animationsDisabled ? Duration.zero : const Duration(milliseconds: 200);

  @override
  Animation<double>? get animation {
    final raw = super.animation;
    return raw == null ? null : _ClampedAnimation(raw);
  }

  @override
  AnimationController createAnimationController() {
    if (animationsDisabled) {
      return AnimationController(
        duration: Duration.zero,
        reverseDuration: Duration.zero,
        debugLabel: 'RudiSheetRoute',
        vsync: navigator!,
      );
    }
    return AnimationController.unbounded(
      duration: transitionDuration,
      reverseDuration: reverseTransitionDuration,
      debugLabel: 'RudiSheetRoute',
      animationBehavior: AnimationBehavior.normal,
      vsync: navigator!,
    );
  }

  @override
  Simulation? createSimulation({required bool forward}) {
    if (animationsDisabled) return null;
    final velocity = _releaseVelocity ?? 0;
    _releaseVelocity = null;
    return SpringSimulation(
      forward ? _enterSpring : _exitSpring,
      controller?.value ?? 0,
      forward ? 1 : 0,
      -velocity,
      snapToEnd: true,
    );
  }

  @override
  bool didPop(T? result) {
    _popped = true;
    return super.didPop(result);
  }

  void dragBy(double relativeDelta) {
    if (_popped) return;
    if (animationsDisabled) {
      _reducedDrag += relativeDelta;
      return;
    }
    final animationController = controller!;
    var delta = relativeDelta;
    if (animationController.value > 1) {
      final overshoot = animationController.value - 1;
      delta *= 1 / (1 + overshoot * _overdragResistance);
    }
    animationController.value -= delta;
  }

  void endDrag(double relativeVelocity) {
    if (_popped) return;
    if (animationsDisabled) {
      final close =
          _reducedDrag > _closePosition || relativeVelocity > _closeVelocity;
      _reducedDrag = 0;
      if (close) navigator?.pop();
      return;
    }
    final animationController = controller!;
    final value = animationController.value;
    if (value > 1) {
      final overshoot = value - 1;
      final damped = relativeVelocity / (1 + overshoot * _overdragResistance);
      animationController.animateWith(
        SpringSimulation(_enterSpring, value, 1, -damped, snapToEnd: true),
      );
      return;
    }
    final close = switch (relativeVelocity) {
      > _closeVelocity => true,
      < -_closeVelocity => false,
      _ => value < _closePosition,
    };
    if (close) {
      _releaseVelocity = relativeVelocity;
      navigator?.pop();
    } else {
      animationController.animateWith(
        SpringSimulation(
          _enterSpring,
          value,
          1,
          -relativeVelocity,
          snapToEnd: true,
        ),
      );
    }
  }

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return capturedThemes.wrap(
      _RudiSheetPage<T>(route: this, builder: builder),
    );
  }
}

final class _RudiSheetPage<T> extends StatefulWidget {
  const _RudiSheetPage({required this.route, required this.builder});

  final _RudiSheetRoute<T> route;
  final WidgetBuilder builder;

  @override
  State<_RudiSheetPage<T>> createState() => _RudiSheetPageState<T>();
}

final class _RudiSheetPageState<T> extends State<_RudiSheetPage<T>> {
  final _sheetKey = GlobalKey();

  double get _sheetHeight {
    final renderObject =
        _sheetKey.currentContext?.findRenderObject() as RenderBox?;
    return renderObject?.size.height.clamp(1, double.infinity) ?? 1;
  }

  @override
  Widget build(BuildContext context) {
    final route = widget.route;
    final sheet = SizedBox(
      key: _sheetKey,
      width: double.infinity,
      child: widget.builder(context),
    );
    return Semantics(
      scopesRoute: true,
      namesRoute: true,
      label: route.modalBarrierLabel,
      explicitChildNodes: true,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.only(top: context.rudiTheme.spacing.md),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: 720 + context.rudiTheme.spacing.md * 2,
              ),
              child: AnimatedBuilder(
                animation: route.sheetAnimation,
                builder: (context, child) => FractionalTranslation(
                  translation: Offset(0, 1 - route.sheetValue),
                  child: child,
                ),
                child: route.enableDrag
                    ? GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        excludeFromSemantics: true,
                        onVerticalDragUpdate: (details) {
                          route.dragBy(details.primaryDelta! / _sheetHeight);
                        },
                        onVerticalDragEnd: (details) {
                          route.endDrag(
                            details.velocity.pixelsPerSecond.dy / _sheetHeight,
                          );
                        },
                        onVerticalDragCancel: () => route.endDrag(0),
                        child: sheet,
                      )
                    : sheet,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

final class _ClampedAnimation extends Animation<double>
    with AnimationWithParentMixin<double> {
  _ClampedAnimation(this.parent);

  @override
  final Animation<double> parent;

  @override
  double get value => parent.value.clamp(0, 1);
}
