import 'package:flutter/widgets.dart';

import '../foundation/theme.dart';
import 'actions.dart';
import 'icons.dart';

/// A titled group of related settings or controls.
final class RudiSettingsSection extends StatelessWidget {
  /// Creates a settings section.
  const RudiSettingsSection({
    required this.children,
    this.title,
    this.description,
    super.key,
  });

  /// Optional section title.
  final String? title;

  /// Optional supporting description.
  final String? description;

  /// Section rows.
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = context.rudiTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (title case final text?) Text(text, style: theme.text.title),
        if (description case final text?) ...[
          SizedBox(height: theme.spacing.xs),
          Text(
            text,
            style: theme.text.body.copyWith(
              color: theme.colors.mutedForeground,
            ),
          ),
        ],
        SizedBox(height: theme.spacing.sm),
        Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: theme.colors.surfaceContainer,
            borderRadius: BorderRadius.circular(theme.radii.xl),
            border: Border.all(color: theme.colors.outline),
          ),
          child: Column(
            children: [
              for (var index = 0; index < children.length; index++) ...[
                children[index],
                if (index < children.length - 1)
                  Container(height: 1, color: theme.colors.outline),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// A generic setting or preference row.
final class RudiSettingsTile extends StatelessWidget {
  /// Creates a settings row.
  const RudiSettingsTile({
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onPressed,
    this.selected = false,
    super.key,
  });

  /// Primary row label.
  final String title;

  /// Optional supporting text.
  final String? subtitle;

  /// Optional leading widget.
  final Widget? leading;

  /// Optional trailing widget.
  final Widget? trailing;

  /// Called when the row is activated.
  final VoidCallback? onPressed;

  /// Whether the row is currently selected.
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final theme = context.rudiTheme;
    return Semantics(
      selected: selected,
      child: RudiPressable(
        onPressed: onPressed,
        builder: (context, state) => AnimatedContainer(
          duration: MediaQuery.disableAnimationsOf(context)
              ? Duration.zero
              : theme.motion.fast,
          constraints: const BoxConstraints(minHeight: 64),
          padding: EdgeInsets.all(theme.spacing.md),
          color: selected || state.hovered
              ? theme.colors.surface
              : const Color(0x00000000),
          child: Row(
            children: [
              if (leading != null) ...[
                IconTheme(
                  data: IconThemeData(
                    color: selected
                        ? theme.colors.accent
                        : theme.colors.foreground,
                  ),
                  child: leading!,
                ),
                SizedBox(width: theme.spacing.md),
              ],
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: theme.text.label),
                    if (subtitle case final text?) ...[
                      SizedBox(height: theme.spacing.xs),
                      Text(
                        text,
                        style: theme.text.caption.copyWith(
                          color: theme.colors.mutedForeground,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(width: theme.spacing.sm),
              trailing ??
                  (onPressed == null
                      ? const SizedBox.shrink()
                      : RudiGlyph(
                          RudiGlyphType.chevron,
                          color: theme.colors.mutedForeground,
                        )),
            ],
          ),
        ),
      ),
    );
  }
}

/// A selectable option row.
final class RudiOptionTile<T> extends StatelessWidget {
  /// Creates an option row.
  const RudiOptionTile({
    required this.value,
    required this.groupValue,
    required this.label,
    required this.onSelected,
    this.description,
    this.leading,
    super.key,
  });

  /// Value represented by the row.
  final T value;

  /// Currently selected group value.
  final T? groupValue;

  /// Visible option label.
  final String label;

  /// Optional supporting text.
  final String? description;

  /// Optional leading content.
  final Widget? leading;

  /// Called when this option is selected.
  final ValueChanged<T>? onSelected;

  @override
  Widget build(BuildContext context) {
    final selected = value == groupValue;
    return RudiSettingsTile(
      title: label,
      subtitle: description,
      leading: leading,
      selected: selected,
      onPressed: onSelected == null ? null : () => onSelected!(value),
      trailing: selected
          ? const RudiGlyph(RudiGlyphType.check)
          : const SizedBox.square(dimension: 24),
    );
  }
}

/// A control that reveals additional content inline.
final class RudiExpandableControl extends StatefulWidget {
  /// Creates an expandable control.
  const RudiExpandableControl({
    required this.header,
    required this.child,
    this.initiallyExpanded = false,
    this.onExpandedChanged,
    super.key,
  });

  /// Always-visible header.
  final Widget header;

  /// Content revealed while expanded.
  final Widget child;

  /// Initial expanded state.
  final bool initiallyExpanded;

  /// Called when expanded state changes.
  final ValueChanged<bool>? onExpandedChanged;

  @override
  State<RudiExpandableControl> createState() => _RudiExpandableControlState();
}

final class _RudiExpandableControlState extends State<RudiExpandableControl>
    with SingleTickerProviderStateMixin {
  late bool _expanded = widget.initiallyExpanded;
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 220),
    value: _expanded ? 1 : 0,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _expanded = !_expanded);
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.value = _expanded ? 1 : 0;
    } else if (_expanded) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
    widget.onExpandedChanged?.call(_expanded);
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.rudiTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        RudiPressable(
          onPressed: _toggle,
          builder: (context, state) => Padding(
            padding: EdgeInsets.all(theme.spacing.md),
            child: Row(
              children: [
                Expanded(child: widget.header),
                RotationTransition(
                  turns: Tween<double>(
                    begin: 0,
                    end: 0.25,
                  ).animate(_controller),
                  child: const RudiGlyph(RudiGlyphType.chevron),
                ),
              ],
            ),
          ),
        ),
        SizeTransition(
          sizeFactor: CurvedAnimation(
            parent: _controller,
            curve: theme.motion.standardCurve,
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              theme.spacing.md,
              0,
              theme.spacing.md,
              theme.spacing.md,
            ),
            child: widget.child,
          ),
        ),
      ],
    );
  }
}
