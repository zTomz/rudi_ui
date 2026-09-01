import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../components/overlays.dart';
import '../foundation/theme.dart';
import '../foundation/tokens.dart';

/// Selects how [RudiApp] resolves light and dark themes.
enum RudiThemeMode {
  /// Follow the platform brightness.
  system,

  /// Always use the light theme.
  light,

  /// Always use the dark theme.
  dark,
}

/// A widgets-only application shell configured for Rudi UI.
final class RudiApp extends StatelessWidget {
  /// Creates a navigator-based Rudi application.
  const RudiApp({
    required this.home,
    this.title = '',
    this.theme,
    this.darkTheme,
    this.themeMode = RudiThemeMode.system,
    this.builder,
    this.locale,
    this.localizationsDelegates,
    this.supportedLocales = const <Locale>[Locale('en', 'US')],
    this.debugShowCheckedModeBanner = false,
    super.key,
  }) : routerConfig = null;

  /// Creates a Router-based Rudi application.
  const RudiApp.router({
    required RouterConfig<Object> this.routerConfig,
    this.title = '',
    this.theme,
    this.darkTheme,
    this.themeMode = RudiThemeMode.system,
    this.builder,
    this.locale,
    this.localizationsDelegates,
    this.supportedLocales = const <Locale>[Locale('en', 'US')],
    this.debugShowCheckedModeBanner = false,
    super.key,
  }) : home = null;

  /// Root route for navigator-based applications.
  final Widget? home;

  /// Router configuration for Router-based applications.
  final RouterConfig<Object>? routerConfig;

  /// Application title.
  final String title;

  /// Light theme. Defaults to the official Rudi light theme.
  final RudiThemeData? theme;

  /// Dark theme. Defaults to the official Rudi dark theme.
  final RudiThemeData? darkTheme;

  /// Theme-selection behavior.
  final RudiThemeMode themeMode;

  /// Optional builder invoked inside the Rudi system scopes.
  final TransitionBuilder? builder;

  /// Explicit application locale.
  final Locale? locale;

  /// Localization delegates installed by the consuming application.
  final Iterable<LocalizationsDelegate<dynamic>>? localizationsDelegates;

  /// Locales supported by the consuming application.
  final Iterable<Locale> supportedLocales;

  /// Whether to show Flutter's debug banner.
  final bool debugShowCheckedModeBanner;

  @override
  Widget build(BuildContext context) {
    final light = theme ?? RudiThemeData.light();
    final dark = darkTheme ?? RudiThemeData.dark();
    Widget appBuilder(BuildContext context, Widget? child) {
      final media = MediaQuery.maybeOf(context);
      final platformBrightness = media?.platformBrightness ?? Brightness.light;
      final useDark = switch (themeMode) {
        RudiThemeMode.system => platformBrightness == Brightness.dark,
        RudiThemeMode.light => false,
        RudiThemeMode.dark => true,
      };
      var active = useDark ? dark : light;
      if (media?.highContrast ?? false) {
        final contrastTheme = useDark
            ? RudiThemeData.dark(
                accent: active.colors.accent,
                highContrast: true,
                feedback: active.feedback,
              )
            : RudiThemeData.light(
                accent: active.colors.accent,
                highContrast: true,
                feedback: active.feedback,
              );
        active = active.copyWith(
          colors: contrastTheme.colors,
          highContrast: true,
        );
      }
      final content = child ?? const SizedBox.shrink();
      return AnimatedRudiTheme(
        data: active,
        duration: media?.disableAnimations ?? false
            ? Duration.zero
            : active.motion.normal,
        child: Builder(
          builder: (context) {
            final themedChild = builder?.call(context, content) ?? content;
            return DefaultTextStyle(
              style: context.rudiTheme.text.body,
              child: IconTheme(
                data: IconThemeData(color: context.rudiTheme.colors.foreground),
                child: AnnotatedRegion<SystemUiOverlayStyle>(
                  value:
                      (useDark
                              ? SystemUiOverlayStyle.light
                              : SystemUiOverlayStyle.dark)
                          .copyWith(
                            statusBarColor: const Color(0x00000000),
                            systemNavigationBarColor: active.colors.background,
                          ),
                  child: RudiMessenger(child: themedChild),
                ),
              ),
            );
          },
        ),
      );
    }

    if (routerConfig case final config?) {
      return WidgetsApp.router(
        title: title,
        color: light.colors.background,
        routerConfig: config,
        builder: appBuilder,
        locale: locale,
        localizationsDelegates: localizationsDelegates,
        supportedLocales: supportedLocales,
        debugShowCheckedModeBanner: debugShowCheckedModeBanner,
      );
    }
    return WidgetsApp(
      title: title,
      color: light.colors.background,
      home: home,
      pageRouteBuilder: <T>(settings, builder) => PageRouteBuilder<T>(
        settings: settings,
        pageBuilder: (context, animation, secondaryAnimation) =>
            builder(context),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final disabled = MediaQuery.disableAnimationsOf(context);
          return disabled
              ? child
              : FadeTransition(opacity: animation, child: child);
        },
      ),
      builder: appBuilder,
      locale: locale,
      localizationsDelegates: localizationsDelegates,
      supportedLocales: supportedLocales,
      debugShowCheckedModeBanner: debugShowCheckedModeBanner,
    );
  }
}

/// A responsive page surface with safe-area and readable-width handling.
final class RudiPage extends StatelessWidget {
  /// Creates a page surface.
  const RudiPage({
    required this.child,
    this.navigation,
    this.padding,
    this.constrainContent = false,
    super.key,
  });

  /// Main page content.
  final Widget child;

  /// Optional navigation floated above the bottom safe area.
  final Widget? navigation;

  /// Optional content padding.
  final EdgeInsetsGeometry? padding;

  /// Whether to center and constrain content on wide windows.
  final bool constrainContent;

  @override
  Widget build(BuildContext context) {
    final theme = context.rudiTheme;
    Widget content = ColoredBox(
      color: theme.colors.background,
      child: SafeArea(
        child: Padding(
          padding: padding ?? EdgeInsets.all(theme.spacing.md),
          child: child,
        ),
      ),
    );
    if (constrainContent) {
      content = ColoredBox(
        color: theme.colors.background,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 840),
            child: content,
          ),
        ),
      );
    }
    if (navigation == null) {
      return content;
    }
    final navigationMargin =
        MediaQuery.sizeOf(context).width >= RudiBreakpoints.expanded
        ? theme.spacing.xl
        : theme.spacing.md;
    return Stack(
      children: [
        content,
        PositionedDirectional(
          start: theme.spacing.md,
          end: theme.spacing.md,
          bottom: MediaQuery.paddingOf(context).bottom + navigationMargin,
          child: Center(child: navigation),
        ),
      ],
    );
  }
}
