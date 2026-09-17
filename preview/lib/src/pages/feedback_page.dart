import 'package:flutter/widgets.dart';
import 'package:rudi_ui/rudi_ui.dart';

import '../shared/catalog_page.dart';

final class FeedbackPage extends StatelessWidget {
  const FeedbackPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CatalogPage(
      children: [
        const SectionHeading(
          eyebrow: 'Components',
          title: 'Feedback',
          description: 'Progress, loading, empty, error, and transient message states that keep outcomes understandable.',
        ),
        const SizedBox(height: 48),
        Specimen(
          title: 'Progress',
          description: 'Linear, ring, and tick presentations can represent the same semantic value.',
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: const Column(
              children: [
                RudiLinearProgress(
                  value: .68,
                  semanticLabel: '68 percent complete',
                ),
                SizedBox(height: 36),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    RudiProgressRing(value: .68, size: 108),
                    RudiTickProgress(value: .68, size: 108),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 56),
        const Specimen(
          title: 'Loading view',
          description: 'Indeterminate work remains announced without inventing false progress.',
          child: SizedBox(
            height: 130,
            child: RudiLoadingView(label: 'Loading a fresh component state…'),
          ),
        ),
        const SizedBox(height: 56),
        Specimen(
          title: 'Empty view',
          description: 'A neutral state explains what is missing and offers one useful next action.',
          child: RudiEmptyView(
            title: 'Nothing to review',
            message: 'New work will appear here when it is ready.',
            action: RudiButton(
              label: 'Create item',
              expand: false,
              onPressed: () => _notify(context, 'New item created.'),
            ),
          ),
        ),
        const SizedBox(height: 56),
        Specimen(
          title: 'Error view',
          description: 'Recovery comes first while technical detail stays available on demand.',
          child: RudiErrorView(
            title: 'Connection interrupted',
            message: 'Your work is safe. Try again when you are ready.',
            details: 'Preview error: request timed out after 8 seconds.',
            showDetailsLabel: 'Show details',
            hideDetailsLabel: 'Hide details',
            primaryAction: RudiButton(
              label: 'Try again',
              expand: false,
              onPressed: () => _notify(context, 'Trying again…'),
            ),
          ),
        ),
        const SizedBox(height: 56),
        Specimen(
          title: 'Snack message',
          description: 'Up to four transient messages form a compact stack. Unexpired messages wait behind it and appear after a downward swipe.',
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 12,
            runSpacing: 12,
            children: [
              RudiButton(
                label: 'Standard',
                expand: false,
                onPressed: () =>
                    RudiMessenger.of(context)
                        .show(const RudiSnack(message: 'Saved locally.')),
              ),
              RudiButton(
                label: 'Info',
                expand: false,
                variant: RudiButtonVariant.subtle,
                onPressed: () => RudiMessenger.of(context).show(
                  const RudiSnack.info(message: 'Sync starts in one minute.'),
                ),
              ),
              RudiButton(
                label: 'Error',
                expand: false,
                variant: RudiButtonVariant.destructive,
                onPressed: () => RudiMessenger.of(context).show(
                  const RudiSnack.error(message: 'Could not save changes.'),
                ),
              ),
              RudiButton(
                label: 'Debug',
                expand: false,
                variant: RudiButtonVariant.subtle,
                onPressed: () => RudiMessenger.of(context).show(
                  const RudiSnack.debug(message: 'Cache refreshed in 42 ms.'),
                ),
              ),
              RudiButton(
                label: 'Stack',
                expand: false,
                variant: RudiButtonVariant.subtle,
                onPressed: () {
                  final messenger = RudiMessenger.of(context);
                  messenger
                    ..show(const RudiSnack.info(message: 'Preparing backup…'))
                    ..show(const RudiSnack(message: 'Uploading changes…'))
                    ..show(
                      const RudiSnack.error(
                        message: 'One file could not be uploaded.',
                      ),
                    );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _notify(BuildContext context, String message) {
    RudiMessenger.of(context).show(RudiSnack(message: message));
  }
}
