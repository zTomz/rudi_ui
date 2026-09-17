import 'package:flutter/widgets.dart';
import 'package:rudi_ui/rudi_ui.dart';

import 'workspace/preview_workspace.dart';

final class RudiPreviewApp extends StatefulWidget {
  const RudiPreviewApp({super.key});

  @override
  State<RudiPreviewApp> createState() => _RudiPreviewAppState();
}

final class _RudiPreviewAppState extends State<RudiPreviewApp> {
  RudiThemeMode _themeMode = RudiThemeMode.system;

  @override
  Widget build(BuildContext context) {
    return RudiApp(
      title: 'Rudi UI Component Lab',
      themeMode: _themeMode,
      theme: _previewTheme(RudiThemeData.light()),
      darkTheme: _previewTheme(RudiThemeData.dark()),
      home: PreviewWorkspace(
        themeMode: _themeMode,
        onThemeModeChanged: (value) => setState(() => _themeMode = value),
      ),
    );
  }
}

RudiThemeData _previewTheme(RudiThemeData base) {
  return base.copyWith(
    colors: base.colors.copyWith(accent: const Color(0xFF7658FF)),
  );
}
