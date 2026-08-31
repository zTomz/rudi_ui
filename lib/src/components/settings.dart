import 'dart:async';

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
        ink: true,
        builder: (context, state) => AnimatedContainer(
          duration: MediaQuery.disableAnimationsOf(context)
              ? Duration.zero
              : theme.motion.fast,
          constraints: const BoxConstraints(minHeight: 60),
          padding: EdgeInsets.symmetric(
            horizontal: theme.spacing.md,
            vertical: 12,
          ),
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
      unawaited(_controller.forward());
    } else {
      unawaited(_controller.reverse());
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

/// Loop's separated rows, grouped outer corners, accent label and bold titles.
final class const RudiSettingsGroup({
  final String? title,
  required final List<Widget> children,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = context.rudiTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (title != null)
          Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 12),
            child: Text(
              title!,
              style: theme.text.label.copyWith(
                color: theme.colors.accent,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        for (final (index, child) in children.indexed) ...[
          ClipRRect(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(index == 0 ? 28 : 5),
              bottom: Radius.circular(index == children.length - 1 ? 28 : 5),
            ),
            child: ColoredBox(
              color: theme.colors.surface,
              child: RudiTheme(
                data: theme.copyWith(
                  text: RudiTextTheme(
                    display: theme.text.display,
                    headline: theme.text.headline,
                    title: theme.text.title,
                    body: theme.text.body,
                    label: theme.text.label.copyWith(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                    caption: theme.text.caption,
                  ),
                ),
                child: child,
              ),
            ),
          ),
          if (index < children.length - 1) const SizedBox(height: 3),
        ],
      ],
    );
  }
}

final class const _RudiSwitchIndicator(final bool value)
    extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = context.rudiTheme,
        reduced = MediaQuery.disableAnimationsOf(context);
    return AnimatedContainer(
      duration: reduced ? Duration.zero : theme.motion.normal,
      curve: theme.motion.standardCurve,
      width: 50,
      height: 30,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: value ? theme.colors.foreground : theme.colors.outline,
      ),
      child: AnimatedAlign(
        alignment: value ? Alignment.centerRight : Alignment.centerLeft,
        duration: reduced ? Duration.zero : theme.motion.normal,
        curve: Curves.easeOutQuart,
        child: Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: theme.colors.background,
          ),
        ),
      ),
    );
  }
}

/// A setting row with a single accessible toggle target and animated indicator.
final class const RudiSwitchTile({
  required final String title,
  required final bool value,
  required final ValueChanged<bool>? onChanged,
  final String? subtitle,
  final Widget? leading,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Semantics(
    toggled: value,
    child: RudiSettingsTile(
      title: title,
      subtitle: subtitle,
      leading: leading,
      onPressed: onChanged == null ? null : () => onChanged!(!value),
      trailing: _RudiSwitchIndicator(value),
    ),
  );
}
