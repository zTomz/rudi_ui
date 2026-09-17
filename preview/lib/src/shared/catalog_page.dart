import 'package:flutter/widgets.dart';
import 'package:rudi_ui/rudi_ui.dart';

final class CatalogPage extends StatelessWidget {
  const CatalogPage({required this.children, super.key});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: const ValueKey('component-catalog-scroll'),
      padding: EdgeInsets.zero,
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1120),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 44, 24, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: children,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

final class SectionHeading extends StatelessWidget {
  const SectionHeading({
    required this.eyebrow,
    required this.title,
    required this.description,
    super.key,
  });

  final String eyebrow;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final theme = context.rudiTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          eyebrow.toUpperCase(),
          style: theme.text.caption.copyWith(
            color: theme.colors.accent,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 10),
        Text(title, style: theme.text.headline),
        const SizedBox(height: 12),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: Text(
            description,
            style: theme.text.body.copyWith(
              color: theme.colors.mutedForeground,
            ),
          ),
        ),
      ],
    );
  }
}

final class Specimen extends StatelessWidget {
  const Specimen({
    required this.title,
    required this.description,
    required this.child,
    this.footer,
    super.key,
  });

  final String title;
  final String description;
  final Widget child;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final theme = context.rudiTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: theme.text.title),
        const SizedBox(height: 8),
        Text(
          description,
          style: theme.text.body.copyWith(color: theme.colors.mutedForeground),
        ),
        const SizedBox(height: 20),
        Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 180),
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: theme.colors.surfaceContainer,
            border: Border.all(color: theme.colors.outline),
            borderRadius: BorderRadius.circular(theme.radii.lg),
          ),
          child: Center(child: child),
        ),
        if (footer case final footer?) ...[const SizedBox(height: 16), footer],
      ],
    );
  }
}
