import 'package:flutter/widgets.dart';
import 'package:rudi_ui/rudi_ui.dart';
import 'package:solar_icons/solar_icons.dart';

import '../shared/catalog_page.dart';

final class NavigationPage extends StatefulWidget {
  const NavigationPage({super.key});

  @override
  State<NavigationPage> createState() => _NavigationPageState();
}

final class _NavigationPageState extends State<NavigationPage> {
  int _selected = 0;

  List<RudiNavigationDestination> _destinations(BuildContext context) => [
    RudiNavigationDestination(
      icon: const Icon(SolarIconsOutline.home),
      selectedIcon: const Icon(SolarIconsBold.home),
      label: 'Home',
      action: RudiNavigationAction(
        icon: const Icon(SolarIconsOutline.addCircle),
        label: 'Create item',
        onPressed: () =>
            RudiMessenger.of(context)
                .show(const RudiSnack(message: 'Create action selected.')),
      ),
    ),
    const RudiNavigationDestination(
      icon: Icon(SolarIconsOutline.widget),
      selectedIcon: Icon(SolarIconsBold.widget),
      label: 'Library',
    ),
    const RudiNavigationDestination(
      icon: Icon(SolarIconsOutline.user),
      selectedIcon: Icon(SolarIconsBold.user),
      label: 'Profile',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return CatalogPage(
      children: [
        const SectionHeading(
          eyebrow: 'Components',
          title: 'Navigation',
          description: 'A compact destination model, animated selection, and optional action that belongs to the active destination.',
        ),
        const SizedBox(height: 48),
        Specimen(
          title: 'Floating navigation bar',
          description: 'Select a destination to see the indicator and contextual action move.',
          child: LayoutBuilder(
            builder: (context, constraints) {
              final destinations = _destinations(context);
              final visible = constraints.maxWidth < 360
                  ? destinations.take(2).toList()
                  : destinations;
              return RudiFloatingNavigationBar(
                selectedIndex: _selected.clamp(0, visible.length - 1),
                onDestinationSelected: (value) =>
                    setState(() => _selected = value),
                destinations: visible,
              );
            },
          ),
        ),
        const SizedBox(height: 56),
        Specimen(
          title: 'Compact placement',
          description: 'Reduced outer spacing lets the same control sit inside constrained surfaces.',
          child: LayoutBuilder(
            builder: (context, constraints) {
              final destinations = _destinations(context);
              final visible = constraints.maxWidth < 360
                  ? destinations.take(2).toList()
                  : destinations;
              return RudiFloatingNavigationBar(
                compact: true,
                selectedIndex: _selected.clamp(0, visible.length - 1),
                onDestinationSelected: (value) =>
                    setState(() => _selected = value),
                destinations: visible,
              );
            },
          ),
        ),
      ],
    );
  }
}
