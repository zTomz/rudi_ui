import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../tool/check_import_boundaries.dart';

void main() {
  late Directory temporaryDirectory;
  late Directory libraryDirectory;

  setUp(() {
    temporaryDirectory = Directory.systemTemp.createTempSync(
      'rudi-import-boundaries-',
    );
    libraryDirectory = Directory(
      '${temporaryDirectory.path}${Platform.pathSeparator}lib',
    )..createSync();
  });

  tearDown(() => temporaryDirectory.deleteSync(recursive: true));

  test('allows Dart, Flutter widgets, package-local and relative imports', () {
    File('${libraryDirectory.path}${Platform.pathSeparator}allowed.dart')
        .writeAsStringSync('''
import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:rudi_ui/rudi_ui.dart';
import 'src/local.dart';
''');

    expect(findImportBoundaryViolations(libraryDirectory), isEmpty);
  });

  test('rejects UI frameworks, foreign packages and escaping paths', () {
    File('${libraryDirectory.path}${Platform.pathSeparator}forbidden.dart')
        .writeAsStringSync('''
import 'package:flutter/material.dart';
import 'package:loop/loop_app.dart';
import 'package:some_package/some_package.dart';
import '../outside.dart';
''');

    final violations = findImportBoundaryViolations(libraryDirectory);

    expect(violations, hasLength(4));
    expect(violations[0], contains('package:flutter/material.dart'));
    expect(violations[1], contains('package:loop/loop_app.dart'));
    expect(violations[2], contains('package:some_package/some_package.dart'));
    expect(violations[3], contains('../outside.dart'));
  });
}
