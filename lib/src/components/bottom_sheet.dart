import 'dart:async';

import 'package:flutter/physics.dart';
import 'package:flutter/widgets.dart';

import '../foundation/theme.dart';
import 'actions.dart';
import 'icons.dart';

/// Opens a sheet. Dragging its header tracks the finger; release springs back or dismisses.
/// Pass a null [closeIcon] to omit the close button while retaining route dismissal.
Future<T?> showRudiBottomSheet<T>({
  required BuildContext context,
  String title = '',
  required String barrierLabel,
  bool barrierDismissible = true,
  bool useRootNavigator = true,
  Widget? closeIcon = const RudiGlyph(RudiGlyphType.close),
  required WidgetBuilder builder,
}) {
  final navigator = Navigator.of(context, rootNavigator: useRootNavigator);
  return navigator.push(
    _SheetRoute<T>(
      title: title,
      builder: builder,
      closeIcon: closeIcon,
      themes: InheritedTheme.capture(from: context, to: navigator.context),
      label: barrierLabel,
      dismissible: barrierDismissible,
      reducedMotion: MediaQuery.disableAnimationsOf(context),
    ),
  );
}

final class _SheetRoute<T>({
  required final String title,
  required final WidgetBuilder builder,
  required final Widget? closeIcon,
  required final CapturedThemes themes,
  required final String label,
  required final bool reducedMotion,
  required final bool dismissible,
}) extends PopupRoute<T> {
  final _surfaceKey = GlobalKey();
  double _drag = 0;
  double _dragStart = 1;
  void _settle() {
    if (reducedMotion) {
      controller?.value = 1;
      return;
    }
    unawaited(controller?.animateWith(createSimulation(forward: true)!));
  }

  bool _closing = false;
  @override
  Color get barrierColor => const Color(0x66000000);
  @override
  bool get barrierDismissible => dismissible;
  @override
  String get barrierLabel => label;
  @override
  Duration get transitionDuration =>
      reducedMotion ? Duration.zero : const Duration(milliseconds: 420);
  @override
  Duration get reverseTransitionDuration =>
      reducedMotion ? Duration.zero : const Duration(milliseconds: 260);
  @override
  Simulation? createSimulation({required bool forward}) => reducedMotion
      ? null
      : SpringSimulation(
          SpringDescription(
            mass: 1,
            stiffness: forward ? 440 : 780,
            damping: forward ? 42 : 55,
          ),
          controller?.value ?? 0,
          forward ? 1 : 0,
          0,
          snapToEnd: true,
        );
  @override
  bool didPop(T? result) {
    _closing = true;
    return super.didPop(result);
  }

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) => themes.wrap(
    Builder(
      builder: (context) {
        final theme = context.rudiTheme;
        return SafeArea(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                16,
                24,
                16,
                16 + MediaQuery.viewInsetsOf(context).bottom,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: 520,
                  maxHeight: MediaQuery.sizeOf(context).height * .86,
                ),
                child: SlideTransition(
                  position: animation.drive(
                    Tween(begin: const Offset(0, 1), end: Offset.zero),
                  ),
                  child: DecoratedBox(
                    key: _surfaceKey,
                    decoration: BoxDecoration(
                      color: theme.colors.background,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onVerticalDragStart: (_) {
                              if (!_closing && dismissible) {
                                _drag = 0;
                                _dragStart = controller?.value ?? 1;
                                controller?.stop();
                              }
                            },
                            onVerticalDragUpdate: (details) {
                              if (_closing || !dismissible) return;
                              _drag += details.delta.dy;
                              if (reducedMotion) return;
                              controller?.value =
                                  (_dragStart -
                                          _drag /
                                              (_surfaceKey
                                                      .currentContext
                                                      ?.size
                                                      ?.height ??
                                                  420))
                                      .clamp(0, 1);
                            },
                            onVerticalDragEnd: (details) {
                              if (_closing || !dismissible) return;
                              if (_drag > 90 ||
                                  details.velocity.pixelsPerSecond.dy > 700) {
                                navigator?.pop();
                              } else {
                                _settle();
                              }
                            },
                            onVerticalDragCancel: () {
                              if (!_closing && dismissible) {
                                _settle();
                              }
                            },
                            child: Column(
                              children: [
                                Center(
                                  child: Container(
                                    width: 32,
                                    height: 4,
                                    margin: const EdgeInsets.symmetric(
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: theme.colors.outline,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                ),
                                ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    minHeight: 48,
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          title,
                                          style: theme.text.title,
                                        ),
                                      ),
                                      if (closeIcon case final icon?)
                                        RudiIconButton(
                                          icon: icon,
                                          semanticLabel: label,
                                          onPressed: () =>
                                              Navigator.of(context).pop(),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Flexible(
                            child: SingleChildScrollView(
                              child: builder(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    ),
  );
}
