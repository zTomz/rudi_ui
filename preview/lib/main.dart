import 'package:device_preview/device_preview.dart';
import 'package:flutter/widgets.dart';

import 'src/preview_app.dart';

export 'src/preview_app.dart' show RudiPreviewApp;

void main() {
  DevicePreview.enable(
    enabled: true,
    padding: const EdgeInsets.all(16),
    backgroundDecoration: const BoxDecoration(color: Color(0xFF10100F)),
  );
  runApp(const RudiPreviewApp());
}
