import 'dart:io';

const _forbiddenImports = <String>[
  'package:flutter/material.dart',
  'package:flutter/cupertino.dart',
  'package:material_ui/',
  'package:cupertino_ui/',
  'package:loop/',
  'package:flutter_hooks/',
  'package:hooks_riverpod/',
  'package:riverpod/',
  'package:auto_route/',
  'package:cue/',
  'package:motor/',
];

void main() {
  final violations = <String>[];
  final roots = <Directory>[
    Directory('packages/rudi_ui/lib'),
    Directory('packages/rudi_ui_fonts/lib'),
  ];

  for (final root in roots) {
    if (!root.existsSync()) {
      continue;
    }
    for (final entity in root.listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) {
        continue;
      }
      final lines = entity.readAsLinesSync();
      for (var index = 0; index < lines.length; index++) {
        final line = lines[index];
        for (final forbidden in _forbiddenImports) {
          if (line.contains(forbidden)) {
            violations.add('${entity.path}:${index + 1}: $forbidden');
          }
        }
      }
    }
  }

  if (violations.isNotEmpty) {
    stderr.writeln('Forbidden design-system dependencies found:');
    stderr.writeln(violations.join('\n'));
    exitCode = 1;
  }
}
