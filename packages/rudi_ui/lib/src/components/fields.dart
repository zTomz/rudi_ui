import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../foundation/theme.dart';
import 'actions.dart';

/// A full-featured, widgets-only text input with Rudi styling.
final class RudiTextField extends StatefulWidget {
  /// Creates a text field.
  const RudiTextField({
    this.controller,
    this.focusNode,
    this.label,
    this.hint,
    this.errorText,
    this.leading,
    this.trailing,
    this.onChanged,
    this.onSubmitted,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
    this.minLines,
    this.maxLines = 1,
    this.maxLength,
    this.obscureText = false,
    this.readOnly = false,
    this.enabled = true,
    this.autofocus = false,
    this.autocorrect = true,
    this.enableSuggestions = true,
    this.contextMenuBuilder,
    super.key,
  });

  /// External text controller, or null to let the field own one.
  final TextEditingController? controller;

  /// External focus node, or null to let the field own one.
  final FocusNode? focusNode;

  /// Optional label above the field.
  final String? label;

  /// Placeholder shown while empty and unfocused.
  final String? hint;

  /// Validation message below the field.
  final String? errorText;

  /// Optional leading content.
  final Widget? leading;

  /// Optional trailing content.
  final Widget? trailing;

  /// Called when the text changes.
  final ValueChanged<String>? onChanged;

  /// Called when the platform submits the field.
  final ValueChanged<String>? onSubmitted;

  /// Requested software keyboard type.
  final TextInputType? keyboardType;

  /// Requested keyboard action.
  final TextInputAction? textInputAction;

  /// Automatic capitalization behavior.
  final TextCapitalization textCapitalization;

  /// Formatters applied to edits.
  final List<TextInputFormatter>? inputFormatters;

  /// Minimum visible line count.
  final int? minLines;

  /// Maximum visible line count.
  final int? maxLines;

  /// Optional character limit.
  final int? maxLength;

  /// Whether input is obscured.
  final bool obscureText;

  /// Whether content can be selected but not changed.
  final bool readOnly;

  /// Whether the field accepts interaction.
  final bool enabled;

  /// Whether the field requests focus initially.
  final bool autofocus;

  /// Whether autocorrection is enabled.
  final bool autocorrect;

  /// Whether keyboard suggestions are enabled.
  final bool enableSuggestions;

  /// Optional replacement for Rudi UI's default context menu.
  final EditableTextContextMenuBuilder? contextMenuBuilder;

  @override
  State<RudiTextField> createState() => _RudiTextFieldState();
}

final class _RudiTextFieldState extends State<RudiTextField> {
  TextEditingController? _internalController;
  FocusNode? _internalFocusNode;

  TextEditingController get _controller =>
      widget.controller ?? (_internalController ??= TextEditingController());

  FocusNode get _focusNode =>
      widget.focusNode ?? (_internalFocusNode ??= FocusNode());

  @override
  void dispose() {
    _internalController?.dispose();
    _internalFocusNode?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.rudiTheme;
    return ListenableBuilder(
      listenable: _focusNode,
      builder: (context, child) {
        final focused = _focusNode.hasFocus;
        final borderColor = widget.errorText != null
            ? theme.colors.error
            : focused
            ? theme.colors.focus
            : theme.colors.outline;
        return Semantics(
          textField: true,
          enabled: widget.enabled,
          readOnly: widget.readOnly,
          label: widget.label,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (widget.label case final label?) ...[
                Text(label, style: theme.text.label),
                SizedBox(height: theme.spacing.xs),
              ],
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: widget.enabled ? _focusNode.requestFocus : null,
                child: AnimatedContainer(
                  duration: MediaQuery.disableAnimationsOf(context)
                      ? Duration.zero
                      : theme.motion.fast,
                  constraints: const BoxConstraints(minHeight: 56),
                  padding: EdgeInsets.symmetric(
                    horizontal: theme.spacing.md,
                    vertical: theme.spacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colors.surface,
                    borderRadius: BorderRadius.circular(theme.radii.lg),
                    border: Border.all(
                      color: borderColor,
                      width: focused || widget.errorText != null ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (widget.leading != null) ...[
                        IconTheme(
                          data: IconThemeData(
                            color: theme.colors.mutedForeground,
                            size: 22,
                          ),
                          child: widget.leading!,
                        ),
                        SizedBox(width: theme.spacing.sm),
                      ],
                      Expanded(
                        child: Stack(
                          alignment: AlignmentDirectional.centerStart,
                          children: [
                            if (_controller.text.isEmpty && widget.hint != null)
                              IgnorePointer(
                                child: Text(
                                  widget.hint!,
                                  maxLines: widget.maxLines,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.text.body.copyWith(
                                    color: theme.colors.mutedForeground,
                                  ),
                                ),
                              ),
                            EditableText(
                              controller: _controller,
                              focusNode: _focusNode,
                              readOnly: widget.readOnly || !widget.enabled,
                              obscureText: widget.obscureText,
                              autocorrect: widget.autocorrect,
                              enableSuggestions: widget.enableSuggestions,
                              style: theme.text.body.copyWith(
                                color: widget.enabled
                                    ? theme.colors.foreground
                                    : theme.colors.mutedForeground,
                              ),
                              cursorColor: theme.colors.accent,
                              backgroundCursorColor: theme.colors.background,
                              selectionColor: theme.colors.accent.withValues(
                                alpha: 0.3,
                              ),
                              keyboardAppearance: theme.brightness,
                              keyboardType: widget.keyboardType,
                              textInputAction: widget.textInputAction,
                              textCapitalization: widget.textCapitalization,
                              inputFormatters: <TextInputFormatter>[
                                if (widget.maxLength case final length?)
                                  LengthLimitingTextInputFormatter(length),
                                ...?widget.inputFormatters,
                              ],
                              minLines: widget.minLines,
                              maxLines: widget.maxLines,
                              autofocus: widget.autofocus,
                              onChanged: (value) {
                                setState(() {});
                                widget.onChanged?.call(value);
                              },
                              onSubmitted: widget.onSubmitted,
                              onTapOutside: (_) => _focusNode.unfocus(),
                              contextMenuBuilder:
                                  widget.contextMenuBuilder ??
                                  _rudiTextContextMenu,
                            ),
                          ],
                        ),
                      ),
                      if (widget.trailing != null) ...[
                        SizedBox(width: theme.spacing.sm),
                        widget.trailing!,
                      ],
                    ],
                  ),
                ),
              ),
              if (widget.errorText case final error?) ...[
                SizedBox(height: theme.spacing.xs),
                Text(
                  error,
                  style: theme.text.caption.copyWith(color: theme.colors.error),
                ),
              ] else if (widget.maxLength case final maxLength?) ...[
                SizedBox(height: theme.spacing.xs),
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: Text(
                    '${_controller.text.characters.length}/$maxLength',
                    style: theme.text.caption.copyWith(
                      color: theme.colors.mutedForeground,
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

/// A [Form] participant that renders a [RudiTextField].
final class RudiTextFormField extends FormField<String> {
  /// Creates a form-integrated text field.
  RudiTextFormField({
    TextEditingController? controller,
    FocusNode? focusNode,
    String? initialValue,
    String? label,
    String? hint,
    super.validator,
    super.onSaved,
    ValueChanged<String>? onChanged,
    super.enabled = true,
    bool obscureText = false,
    int? maxLines = 1,
    super.autovalidateMode,
    super.key,
  }) : assert(controller == null || initialValue == null),
       super(
         initialValue: controller?.text ?? initialValue ?? '',
         builder: (state) {
           return RudiTextField(
             controller: controller,
             focusNode: focusNode,
             label: label,
             hint: hint,
             errorText: state.errorText,
             enabled: enabled,
             obscureText: obscureText,
             maxLines: maxLines,
             onChanged: (value) {
               state.didChange(value);
               onChanged?.call(value);
             },
           );
         },
       );
}

/// A bounded numeric stepper.
final class RudiNumberInput extends StatelessWidget {
  /// Creates a numeric input.
  const RudiNumberInput({
    required this.value,
    required this.onChanged,
    required this.decreaseSemanticLabel,
    required this.increaseSemanticLabel,
    this.min,
    this.max,
    this.step = 1,
    this.label,
    super.key,
  });

  /// Current numeric value.
  final num value;

  /// Called with a clamped stepped value.
  final ValueChanged<num>? onChanged;

  /// Localized accessibility label for the decrement action.
  final String decreaseSemanticLabel;

  /// Localized accessibility label for the increment action.
  final String increaseSemanticLabel;

  /// Optional minimum value.
  final num? min;

  /// Optional maximum value.
  final num? max;

  /// Step amount.
  final num step;

  /// Optional accessibility and visible label.
  final String? label;

  num _clamp(num next) {
    if (min != null && next < min!) {
      return min!;
    }
    if (max != null && next > max!) {
      return max!;
    }
    return next;
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.rudiTheme;
    final canDecrease = onChanged != null && (min == null || value > min!);
    final canIncrease = onChanged != null && (max == null || value < max!);
    return Semantics(
      label: label,
      value: '$value',
      increasedValue: '${_clamp(value + step)}',
      decreasedValue: '${_clamp(value - step)}',
      onIncrease: canIncrease ? () => onChanged!(_clamp(value + step)) : null,
      onDecrease: canDecrease ? () => onChanged!(_clamp(value - step)) : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (label case final text?) ...[
            Text(text, style: theme.text.label),
            SizedBox(height: theme.spacing.xs),
          ],
          Container(
            constraints: const BoxConstraints(minHeight: 56),
            decoration: BoxDecoration(
              color: theme.colors.surface,
              borderRadius: BorderRadius.circular(theme.radii.lg),
              border: Border.all(color: theme.colors.outline),
            ),
            child: Row(
              children: [
                RudiIconButton(
                  semanticLabel: decreaseSemanticLabel,
                  onPressed: canDecrease
                      ? () => onChanged!(_clamp(value - step))
                      : null,
                  icon: Text('−', style: theme.text.title),
                ),
                Expanded(
                  child: Text(
                    '$value',
                    textAlign: TextAlign.center,
                    style: theme.text.title,
                  ),
                ),
                RudiIconButton(
                  semanticLabel: increaseSemanticLabel,
                  onPressed: canIncrease
                      ? () => onChanged!(_clamp(value + step))
                      : null,
                  icon: Text('+', style: theme.text.title),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Widget _rudiTextContextMenu(
  BuildContext context,
  EditableTextState editableTextState,
) {
  final anchors = editableTextState.contextMenuAnchors;
  final items = editableTextState.contextMenuButtonItems;
  return CustomSingleChildLayout(
    delegate: TextSelectionToolbarLayoutDelegate(
      anchorAbove: anchors.primaryAnchor,
      anchorBelow: anchors.secondaryAnchor ?? anchors.primaryAnchor,
    ),
    child: _RudiTextMenu(items: items),
  );
}

final class _RudiTextMenu extends StatelessWidget {
  const _RudiTextMenu({required this.items});

  final List<ContextMenuButtonItem> items;

  @override
  Widget build(BuildContext context) {
    final theme = context.rudiTheme;
    final localizations = WidgetsLocalizations.of(context);
    String labelFor(ContextMenuButtonItem item) {
      if (item.label case final label?) {
        return label;
      }
      return switch (item.type) {
        ContextMenuButtonType.cut => localizations.cutButtonLabel,
        ContextMenuButtonType.copy => localizations.copyButtonLabel,
        ContextMenuButtonType.paste => localizations.pasteButtonLabel,
        ContextMenuButtonType.selectAll => localizations.selectAllButtonLabel,
        ContextMenuButtonType.lookUp => localizations.lookUpButtonLabel,
        ContextMenuButtonType.searchWeb => localizations.searchWebButtonLabel,
        ContextMenuButtonType.share => localizations.shareButtonLabel,
        ContextMenuButtonType.delete => 'Delete',
        ContextMenuButtonType.liveTextInput => 'Scan text',
        ContextMenuButtonType.custom => '',
      };
    }

    return Container(
      constraints: const BoxConstraints(maxWidth: 360),
      padding: EdgeInsets.all(theme.spacing.xs),
      decoration: BoxDecoration(
        color: theme.colors.primary,
        borderRadius: BorderRadius.circular(theme.radii.md),
      ),
      child: Wrap(
        children: items
            .map(
              (item) => RudiPressable(
                onPressed: item.onPressed,
                builder: (context, state) => Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: theme.spacing.sm,
                    vertical: theme.spacing.sm,
                  ),
                  child: Text(
                    labelFor(item),
                    style: theme.text.label.copyWith(
                      color: theme.colors.onPrimary,
                    ),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
