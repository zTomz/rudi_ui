import 'dart:async';

import 'package:flutter/widgets.dart';

import '../foundation/theme.dart';
import 'actions.dart';
import 'icons.dart';

/// Visual state of a day in a [RudiCalendar].
enum RudiCalendarDayState {
  /// The day can be selected and has no saved activity.
  available,

  /// The day can be selected and has unfinished activity.
  inProgress,

  /// The day can be selected and its activity is complete.
  completed,

  /// The day is visible but cannot be selected.
  unavailable,
}

/// Builds a localized label for a calendar month.
typedef RudiCalendarMonthLabelBuilder = String Function(DateTime month);

/// Resolves the visual and interactive state of a calendar day.
typedef RudiCalendarDayStateBuilder = RudiCalendarDayState Function(
  DateTime day,
);

/// Builds the full semantic label for a calendar day.
typedef RudiCalendarDaySemanticLabelBuilder = String Function(
  DateTime day,
  RudiCalendarDayState state,
);

/// An accessible, swipeable month calendar without Material dependencies.
///
/// Formatting remains with the caller so month, weekday and accessibility
/// labels can follow the app's localization setup without adding a dependency.
final class RudiCalendar extends StatefulWidget {
  /// Creates a calendar constrained to the inclusive month range.
  const RudiCalendar({
    required this.initialMonth,
    required this.firstMonth,
    required this.lastMonth,
    required this.today,
    required this.weekdayLabels,
    required this.monthLabelBuilder,
    required this.dayStateBuilder,
    required this.daySemanticLabelBuilder,
    required this.previousMonthSemanticLabel,
    required this.nextMonthSemanticLabel,
    this.onDayPressed,
    this.onMonthChanged,
    this.gridHeight = 318,
    super.key,
  }) : assert(weekdayLabels.length == 7),
       assert(gridHeight > 0);

  /// Month displayed when the widget is first mounted.
  final DateTime initialMonth;

  /// Earliest month that can be reached.
  final DateTime firstMonth;

  /// Latest month that can be reached.
  final DateTime lastMonth;

  /// Current calendar day, highlighted with accent-colored day text.
  final DateTime today;

  /// Seven localized weekday labels, starting with Monday.
  final List<String> weekdayLabels;

  /// Localized month and year formatter.
  final RudiCalendarMonthLabelBuilder monthLabelBuilder;

  /// Resolves availability and progress for each visible day.
  final RudiCalendarDayStateBuilder dayStateBuilder;

  /// Builds an accessible label including the day's status.
  final RudiCalendarDaySemanticLabelBuilder daySemanticLabelBuilder;

  /// Accessible label for the previous-month control.
  final String previousMonthSemanticLabel;

  /// Accessible label for the next-month control.
  final String nextMonthSemanticLabel;

  /// Called for an enabled day.
  final ValueChanged<DateTime>? onDayPressed;

  /// Called after the visible month settles.
  final ValueChanged<DateTime>? onMonthChanged;

  /// Height of the six-row day grid.
  final double gridHeight;

  @override
  State<RudiCalendar> createState() => _RudiCalendarState();
}

final class _RudiCalendarState extends State<RudiCalendar> {
  late PageController _controller;
  late int _page;

  int get _lastPage => _monthDistance(widget.firstMonth, widget.lastMonth);

  @override
  void initState() {
    super.initState();
    _validateRange();
    _page = _pageFor(widget.initialMonth);
    _controller = PageController(initialPage: _page);
  }

  @override
  void didUpdateWidget(RudiCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);
    final rangeChanged =
        !_sameMonth(oldWidget.firstMonth, widget.firstMonth) ||
        !_sameMonth(oldWidget.lastMonth, widget.lastMonth);
    if (!rangeChanged) return;
    _validateRange();
    final month = _monthFor(_page.clamp(0, _lastPage));
    _controller.dispose();
    _page = _pageFor(month).clamp(0, _lastPage);
    _controller = PageController(initialPage: _page);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _validateRange() {
    assert(
      _monthDistance(widget.firstMonth, widget.lastMonth) >= 0,
      'lastMonth must not be before firstMonth.',
    );
    assert(
      _monthDistance(widget.firstMonth, widget.initialMonth) >= 0 &&
          _monthDistance(widget.initialMonth, widget.lastMonth) >= 0,
      'initialMonth must be inside the calendar range.',
    );
  }

  int _pageFor(DateTime month) => _monthDistance(widget.firstMonth, month);

  DateTime _monthFor(int page) =>
      DateTime(widget.firstMonth.year, widget.firstMonth.month + page);

  void _showPage(int page) {
    if (page < 0 || page > _lastPage || page == _page) return;
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.jumpToPage(page);
      return;
    }
    unawaited(
      _controller.animateToPage(
        page,
        duration: context.rudiTheme.motion.slow,
        curve: context.rudiTheme.motion.standardCurve,
      ),
    );
  }

  void _handlePageChanged(int page) {
    setState(() => _page = page);
    widget.onMonthChanged?.call(_monthFor(page));
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.rudiTheme;
    final month = _monthFor(_page);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colors.surfaceContainer,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: theme.colors.outline.withValues(alpha: .38)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
        child: Column(
          children: [
            Row(
              children: [
                RudiIconButton(
                  icon: const RotatedBox(
                    quarterTurns: 2,
                    child: RudiGlyph(RudiGlyphType.chevron),
                  ),
                  semanticLabel: widget.previousMonthSemanticLabel,
                  onPressed: _page > 0 ? () => _showPage(_page - 1) : null,
                ),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: MediaQuery.disableAnimationsOf(context)
                        ? Duration.zero
                        : theme.motion.normal,
                    switchInCurve: theme.motion.standardCurve,
                    switchOutCurve: theme.motion.standardCurve,
                    child: Text(
                      widget.monthLabelBuilder(month),
                      key: ValueKey(
                        'rudi-calendar-month-${month.year}-${month.month}',
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.fade,
                      softWrap: false,
                      style: theme.text.title.copyWith(letterSpacing: -.35),
                    ),
                  ),
                ),
                RudiIconButton(
                  icon: const RudiGlyph(RudiGlyphType.chevron),
                  semanticLabel: widget.nextMonthSemanticLabel,
                  onPressed: _page < _lastPage
                      ? () => _showPage(_page + 1)
                      : null,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                for (final label in widget.weekdayLabels)
                  Expanded(
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.fade,
                      style: theme.text.caption.copyWith(
                        color: theme.colors.mutedForeground,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              key: const ValueKey('rudi-calendar-pages'),
              height: widget.gridHeight,
              child: PageView.builder(
                controller: _controller,
                itemCount: _lastPage + 1,
                onPageChanged: _handlePageChanged,
                itemBuilder: (context, index) => _RudiCalendarMonth(
                  month: _monthFor(index),
                  today: widget.today,
                  stateBuilder: widget.dayStateBuilder,
                  semanticLabelBuilder: widget.daySemanticLabelBuilder,
                  onDayPressed: widget.onDayPressed,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

final class _RudiCalendarMonth extends StatelessWidget {
  const _RudiCalendarMonth({
    required this.month,
    required this.today,
    required this.stateBuilder,
    required this.semanticLabelBuilder,
    required this.onDayPressed,
  });

  final DateTime month;
  final DateTime today;
  final RudiCalendarDayStateBuilder stateBuilder;
  final RudiCalendarDaySemanticLabelBuilder semanticLabelBuilder;
  final ValueChanged<DateTime>? onDayPressed;

  @override
  Widget build(BuildContext context) {
    final first = _monthOnly(month);
    final days = DateTime(month.year, month.month + 1, 0).day;
    final offset = first.weekday - 1;
    return Column(
      key: ValueKey('rudi-calendar-grid-${month.year}-${month.month}'),
      children: [
        for (var week = 0; week < 6; week++)
          Expanded(
            child: Row(
              children: [
                for (var weekday = 0; weekday < 7; weekday++)
                  Expanded(
                    child: Builder(
                      builder: (context) {
                        final day = week * 7 + weekday - offset + 1;
                        if (day < 1 || day > days) {
                          return const SizedBox.expand();
                        }
                        final date = DateTime(month.year, month.month, day);
                        return Padding(
                          padding: const EdgeInsets.all(2),
                          child: _RudiCalendarDay(
                            date: date,
                            today: today,
                            state: stateBuilder(date),
                            semanticLabelBuilder: semanticLabelBuilder,
                            onDayPressed: onDayPressed,
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

final class _RudiCalendarDay extends StatelessWidget {
  const _RudiCalendarDay({
    required this.date,
    required this.today,
    required this.state,
    required this.semanticLabelBuilder,
    required this.onDayPressed,
  });

  final DateTime date;
  final DateTime today;
  final RudiCalendarDayState state;
  final RudiCalendarDaySemanticLabelBuilder semanticLabelBuilder;
  final ValueChanged<DateTime>? onDayPressed;

  @override
  Widget build(BuildContext context) {
    final theme = context.rudiTheme;
    final complete = state == RudiCalendarDayState.completed;
    final inProgress = state == RudiCalendarDayState.inProgress;
    final unavailable = state == RudiCalendarDayState.unavailable;
    final isToday = _sameDay(date, today);
    return RudiPressable(
      key: ValueKey('rudi-calendar-day-${date.year}-${date.month}-${date.day}'),
      semanticLabel: semanticLabelBuilder(date, state),
      onPressed: unavailable || onDayPressed == null
          ? null
          : () => onDayPressed!(date),
      builder: (context, interaction) {
        final background = interaction.hovered || interaction.pressed
            ? theme.colors.surface
            : const Color(0x00000000);
        final foreground = isToday
            ? theme.colors.accent
            : unavailable
            ? theme.colors.mutedForeground.withValues(alpha: .48)
            : theme.colors.foreground;
        return AnimatedScale(
          scale: interaction.pressed ? .92 : 1,
          duration: MediaQuery.disableAnimationsOf(context)
              ? Duration.zero
              : theme.motion.fast,
          curve: theme.motion.standardCurve,
          child: AnimatedContainer(
            width: double.infinity,
            height: double.infinity,
            duration: MediaQuery.disableAnimationsOf(context)
                ? Duration.zero
                : theme.motion.fast,
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(14),
              border: interaction.focused
                  ? Border.all(color: theme.colors.focus, width: 2)
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                MediaQuery.withClampedTextScaling(
                  maxScaleFactor: 1,
                  child: Text(
                    '${date.day}',
                    style: theme.text.label.copyWith(
                      color: foreground,
                      fontWeight: isToday ? FontWeight.w700 : null,
                    ),
                  ),
                ),
                const SizedBox(height: 1),
                SizedBox(
                  height: 4,
                  child: complete || inProgress
                      ? DecoratedBox(
                          decoration: BoxDecoration(
                            color: theme.colors.accent,
                            shape: BoxShape.circle,
                          ),
                          child: const SizedBox.square(dimension: 4),
                        )
                      : null,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

int _monthDistance(DateTime first, DateTime second) =>
    (second.year - first.year) * 12 + second.month - first.month;

DateTime _monthOnly(DateTime date) => DateTime(date.year, date.month);

bool _sameMonth(DateTime first, DateTime second) =>
    first.year == second.year && first.month == second.month;

bool _sameDay(DateTime first, DateTime second) =>
    _sameMonth(first, second) && first.day == second.day;
