import 'package:flutter/widgets.dart';
import 'package:rudi_ui/rudi_ui.dart';
import 'package:solar_icons/solar_icons.dart';

import '../shared/catalog_page.dart';

final class OverlaysPage extends StatelessWidget {
  const OverlaysPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CatalogPage(
      children: [
        const SectionHeading(
          eyebrow: 'Components',
          title: 'Overlays',
          description: 'Anchored help, blocking decisions, and mobile-friendly secondary routes with deliberate focus behavior.',
        ),
        const SizedBox(height: 48),
        Specimen(
          title: 'Tooltip',
          description: 'Hover, focus, or long-press the trigger. Activating the underlying button still works.',
          child: RudiTooltip(
            message: 'Add this component to your workspace',
            waitDuration: const Duration(milliseconds: 180),
            child: RudiIconButton(
              icon: const Icon(SolarIconsOutline.addCircle),
              semanticLabel: 'Add component',
              onPressed: () =>
                  RudiMessenger.of(context)
                      .show(const RudiSnack(message: 'Component added.')),
            ),
          ),
        ),
        const SizedBox(height: 56),
        const Specimen(
          title: 'Info tooltip',
          description: 'A compact disclosure trigger for explanations that should also work on touch screens.',
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Reduced motion'),
              SizedBox(width: 8),
              RudiInfoTooltip(
                semanticLabel: 'Explain reduced motion',
                message: 'Transitions follow the operating system preference automatically.',
              ),
            ],
          ),
        ),
        const SizedBox(height: 56),
        Specimen(
          title: 'Dialog',
          description: 'A focused decision surface with trapped focus and Escape dismissal.',
          child: RudiButton(
            label: 'Open dialog',
            expand: false,
            onPressed: () => _showDialog(context),
          ),
        ),
        const SizedBox(height: 56),
        Specimen(
          title: 'Bottom sheet',
          description: 'A draggable route for secondary tasks that adapts to available height.',
          child: RudiButton(
            label: 'Open sheet',
            expand: false,
            variant: RudiButtonVariant.subtle,
            onPressed: () => _showSheet(context),
          ),
        ),
      ],
    );
  }

  void _showDialog(BuildContext context) {
    showRudiDialog<void>(
      context: context,
      barrierLabel: 'Dismiss dialog',
      builder: (dialogContext) => RudiDialog(
        title: const Text('Publish component changes?'),
        content: const Text(
          'The updated component will become available to every application using this package.',
        ),
        actions: [
          RudiButton(
            label: 'Cancel',
            variant: RudiButtonVariant.subtle,
            onPressed: () => Navigator.pop(dialogContext),
          ),
          RudiButton(
            label: 'Publish',
            onPressed: () => Navigator.pop(dialogContext),
          ),
        ],
      ),
    );
  }

  void _showSheet(BuildContext context) {
    showRudiBottomSheet<void>(
      context: context,
      barrierLabel: 'Dismiss bottom sheet',
      builder: (sheetContext) => RudiBottomSheet(
        title: const Text('Preview options'),
        trailing: const RudiBottomSheetCloseButton(
          semanticLabel: 'Dismiss bottom sheet',
        ),
        children: [
          Text(
            'Sheets remain keyboard accessible and can be dismissed by dragging, tapping the barrier, or pressing Escape.',
            style: sheetContext.rudiTheme.text.body,
          ),
        ],
        actions: [
          RudiButton(
            label: 'Done',
            onPressed: () => Navigator.pop(sheetContext),
          ),
        ],
      ),
    );
  }
}
