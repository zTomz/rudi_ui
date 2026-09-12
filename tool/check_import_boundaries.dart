import 'dart:io';

final _directivePattern = RegExp(
  r'''^\s*(?:import|export|part)\s+['"]([^'"]+)['"]''',
);

void main() {
  final violations = findImportBoundaryViolations(Directory('lib'));

  if (violations.isNotEmpty) {
    stderr.writeln('Imports outside the widgets-only package boundary found:');
    stderr.writeln(violations.join('\n'));
    exitCode = 1;
  }
}

List<String> findImportBoundaryViolations(Directory root) {
  final violations = <String>[];
  final libraryRoot = root.absolute;

  for (final entity in libraryRoot.listSync(recursive: true)) {
    if (entity is! File || !entity.path.endsWith('.dart')) {
      continue;
    }
    final lines = entity.readAsLinesSync();
    for (var index = 0; index < lines.length; index++) {
      final match = _directivePattern.firstMatch(lines[index]);
      if (match == null) {
        continue;
      }
      final uri = match.group(1)!;
      if (!_isAllowed(uri, from: entity, libraryRoot: libraryRoot)) {
        violations.add('${entity.path}:${index + 1}: $uri');
      }
    }
  }
  return violations;
}

bool _isAllowed(
  String uri, {
  required File from,
  required Directory libraryRoot,
}) {
  if (uri.startsWith('dart:') || uri.startsWith('package:rudi_ui/')) {
    return true;
  }
  if (uri.startsWith('package:flutter/')) {
    return uri != 'package:flutter/material.dart' &&
        uri != 'package:flutter/cupertino.dart';
  }

  final parsedUri = Uri.tryParse(uri);
  if (parsedUri == null || parsedUri.hasScheme) {
    return false;
  }

  final resolvedPath = File.fromUri(from.parent.uri.resolveUri(parsedUri))
      .absolute
      .path;
  final rootPath = libraryRoot.path.endsWith(Platform.pathSeparator)
      ? libraryRoot.path
      : '${libraryRoot.path}${Platform.pathSeparator}';
  return resolvedPath.startsWith(rootPath);
}
