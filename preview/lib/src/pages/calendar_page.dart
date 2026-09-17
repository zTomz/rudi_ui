import 'package:flutter/widgets.dart';
import 'package:rudi_ui/rudi_ui.dart';

import '../shared/catalog_page.dart';

final class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

final class _CalendarPageState extends State<CalendarPage> {
  static final _today = DateTime(2026, 9, 20);
  static const _months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  final Set<String> _completed = {'2026-09-02', '2026-09-08', '2026-09-17'};
  final Set<String> _inProgress = {'2026-09-14'};

  String _key(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  RudiCalendarDayState _stateFor(DateTime date) {
    final key = _key(date);
    if (date.isAfter(_today)) return RudiCalendarDayState.unavailable;
    if (_completed.contains(key)) return RudiCalendarDayState.completed;
    if (_inProgress.contains(key)) return RudiCalendarDayState.inProgress;
    return RudiCalendarDayState.available;
  }

  void _toggle(DateTime date) {
    final key = _key(date);
    setState(() {
      _inProgress.remove(key);
      if (!_completed.remove(key)) _completed.add(key);
    });
  }

  @override
  Widget build(BuildContext context) {
    return CatalogPage(
      children: [
        const SectionHeading(
          eyebrow: 'Components',
          title: 'Calendar',
          description: 'A swipeable month view with application-owned labels and explicit state for every day.',
        ),
        const SizedBox(height: 48),
        Specimen(
          title: 'Interactive month',
          description: 'Select an available day to toggle completion, or swipe back through the available range.',
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: RudiCalendar(
              initialMonth: DateTime(2026, 9),
              firstMonth: DateTime(2026, 7),
              lastMonth: DateTime(2026, 9),
              today: _today,
              weekdayLabels: const [
                'Mon',
                'Tue',
                'Wed',
                'Thu',
                'Fri',
                'Sat',
                'Sun',
              ],
              monthLabelBuilder: (month) =>
                  '${_months[month.month - 1]} ${month.year}',
              dayStateBuilder: _stateFor,
              daySemanticLabelBuilder: (day, state) =>
                  '${_months[day.month - 1]} ${day.day}, ${state.name}',
              previousMonthSemanticLabel: 'Previous month',
              nextMonthSemanticLabel: 'Next month',
              onDayPressed: _toggle,
              gridHeight: 288,
            ),
          ),
        ),
        const SizedBox(height: 32),
        Wrap(
          spacing: 18,
          runSpacing: 10,
          children: const [
            _Legend(label: 'Available', state: RudiCalendarDayState.available),
            _Legend(
              label: 'In progress',
              state: RudiCalendarDayState.inProgress,
            ),
            _Legend(label: 'Completed', state: RudiCalendarDayState.completed),
            _Legend(
              label: 'Unavailable',
              state: RudiCalendarDayState.unavailable,
            ),
          ],
        ),
      ],
    );
  }
}

final class _Legend extends StatelessWidget {
  const _Legend({required this.label, required this.state});

  final String label;
  final RudiCalendarDayState state;

  @override
  Widget build(BuildContext context) {
    final theme = context.rudiTheme;
    final color = switch (state) {
      RudiCalendarDayState.available => theme.colors.outline,
      RudiCalendarDayState.inProgress => theme.colors.accent,
      RudiCalendarDayState.completed => theme.colors.foreground,
      RudiCalendarDayState.unavailable =>
        theme.colors.mutedForeground.withValues(alpha: .35),
    };
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 7),
        Text(label, style: theme.text.caption),
      ],
    );
  }
}
