import 'package:flutter/widgets.dart';
import 'package:rudi_ui/rudi_ui.dart';
import 'package:solar_icons/solar_icons.dart';

import '../shared/catalog_page.dart';

enum _Density { comfortable, compact }

final class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

final class _SettingsPageState extends State<SettingsPage> {
  bool _quietMode = true;
  bool _motion = true;
  _Density _density = _Density.comfortable;

  @override
  Widget build(BuildContext context) {
    return CatalogPage(
      children: [
        const SectionHeading(
          eyebrow: 'Components',
          title: 'Settings',
          description: 'Composable rows for preferences, selection, toggles, grouped surfaces, and progressive disclosure.',
        ),
        const SizedBox(height: 48),
        Specimen(
          title: 'Settings group',
          description: 'Icon-first rows can navigate, toggle state, or communicate a selected destination.',
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: RudiSettingsGroup(
              title: 'WORKSPACE',
              children: [
                RudiSettingsTile.icon(
                  icon: SolarIconsOutline.user,
                  label: 'Profile',
                  subtitle: 'Typography and account preferences',
                  onTap: () => _notify(context, 'Profile selected.'),
                ),
                RudiSettingsTile.switchTile(
                  icon: SolarIconsOutline.bellOff,
                  label: 'Quiet mode',
                  value: _quietMode,
                  onChanged: (value) => setState(() => _quietMode = value),
                ),
                RudiSettingsTile(
                  title: 'Appearance',
                  subtitle: 'Uses your current system preference',
                  leading: const RudiGlyph(RudiGlyphType.info),
                  selected: true,
                  onPressed: () => _notify(context, 'Appearance selected.'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 56),
        Specimen(
          title: 'Switch tile',
          description: 'The entire row toggles while its switch also supports direct dragging.',
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: RudiSettingsSection(
              title: 'Interaction',
              description:
                  'Preferences stay understandable with supporting copy.',
              children: [
                RudiSwitchTile(
                  title: 'Comfortable motion',
                  subtitle: 'Use softer component transitions',
                  leading: const RudiGlyph(RudiGlyphType.info),
                  supporting: const RudiInfoTooltip(
                    semanticLabel: 'Explain comfortable motion',
                    message: 'System reduced-motion preferences always take priority.',
                  ),
                  value: _motion,
                  onChanged: (value) => setState(() => _motion = value),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 56),
        Specimen(
          title: 'Option tile',
          description: 'Mutually exclusive options expose selection without requiring a separate radio widget.',
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: RudiSettingsSection(
              children: [
                for (final density in _Density.values)
                  RudiOptionTile<_Density>(
                    value: density,
                    groupValue: _density,
                    label: switch (density) {
                      _Density.comfortable => 'Comfortable',
                      _Density.compact => 'Compact',
                    },
                    description: switch (density) {
                      _Density.comfortable =>
                        'More breathing room between controls',
                      _Density.compact => 'Fit more information on screen',
                    },
                    onSelected: (value) => setState(() => _density = value),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 56),
        Specimen(
          title: 'Expandable control',
          description: 'Secondary information can remain available without dominating the page.',
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: RudiSettingsSection(
              children: [
                RudiExpandableControl(
                  header: Text(
                    'Implementation details',
                    style: context.rudiTheme.text.label,
                  ),
                  child: Text(
                    'Expansion is keyboard accessible and automatically follows the active reduced-motion policy.',
                    style: context.rudiTheme.text.body.copyWith(
                      color: context.rudiTheme.colors.mutedForeground,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _notify(BuildContext context, String message) {
    RudiMessenger.of(context).show(RudiSnack(message: message));
  }
}
