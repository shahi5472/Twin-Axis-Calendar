import 'package:flutter/material.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:sticky_headers/sticky_headers.dart';
import 'package:twin_axis_calendar/src/calendar_event_view.dart';
import 'package:twin_axis_calendar/src/horizontal_calendar_view.dart';

/// A customizable twin calendar widget that displays a horizontal date selector
/// and a vertical list of events for the selected date.
///
/// The [TwinCalendarMain] widget is designed to be flexible and allows for
/// extensive customization of its appearance and behavior.
class TwinCalendarMain<T> extends StatefulWidget {
  const TwinCalendarMain({
    super.key,
    required this.items,
    required this.onEventBuilder,
    required this.horizontalCalendarItemBuilder,
    this.onEmptyBuilder,
    this.selectedDate,
    this.stickyHeaderBuilder,
    this.daysInPast = 365,
    this.daysInFuture = 365,
    this.horizontalScrollAlignment = 0.4,
    this.calendarItemHeight = 95,
    this.scrollDuration = const Duration(milliseconds: 350),
    this.scrollCurve = Curves.ease,
    this.disableOnCalendarTap = false,
  });

  /// The initially selected date. If not provided, the current date is used.
  final DateTime? selectedDate;

  /// A builder function for creating a sticky header for each date in the vertical event list.
  final Widget Function(DateTime date)? stickyHeaderBuilder;

  /// A function that returns a list of items (events) for a given date.
  final List<T> Function(DateTime date) items;

  /// A builder function for creating a widget to display when there are no events for a selected date.
  final Widget Function()? onEmptyBuilder;

  /// A builder function for creating a widget for each event in the vertical list.
  final Widget Function(DateTime date, T item) onEventBuilder;

  /// A builder function for creating the items in the horizontal date selector.
  /// It provides the `BuildContext`, the `date`, and a boolean `isSelected`.
  final Widget Function(BuildContext context, DateTime date, bool isSelected) horizontalCalendarItemBuilder;

  /// The number of days to show in the past from the initial date.
  final int daysInPast;

  /// The number of days to show in the future from the initial date.
  final int daysInFuture;

  /// The alignment of the selected date in the horizontal calendar view.
  /// 0.0 is the left, 0.5 is the center, 1.0 is the right.
  final double horizontalScrollAlignment;

  /// The height of horizontal calendar view.
  final double calendarItemHeight;

  /// The duration of the scroll animation when a date is selected.
  final Duration scrollDuration;

  /// The curve of the scroll animation when a date is selected.
  final Curve scrollCurve;

  /// Determines whether tapping on a horizontal calendar item is enabled.
  ///
  /// If set to `true`, taps on calendar items will be disabled.
  /// If set to `false`, users can interact with and select calendar items.
  final bool disableOnCalendarTap;

  @override
  State<TwinCalendarMain<T>> createState() => _TwinCalendarMainState<T>();
}

class _TwinCalendarMainState<T> extends State<TwinCalendarMain<T>> with AutomaticKeepAliveClientMixin {
  // ### CONTROLLERS ###
  final ItemScrollController _horizontalScrollController = ItemScrollController();
  final ItemPositionsListener _horizontalItemPositionsListener = ItemPositionsListener.create();
  final ItemScrollController _verticalScrollController = ItemScrollController();
  final ItemPositionsListener _verticalItemPositionsListener = ItemPositionsListener.create();

  // ### STATE ###
  late DateTime _selectedDate;
  final List<DateTime> _dateList = [];
  final Map<DateTime, int> _dateToIndexMap = {};

  bool _isProgrammaticScroll = false;
  late int _initialDateIndex;

  @override
  void initState() {
    super.initState();
    _initializeDates();
    _verticalItemPositionsListener.itemPositions.addListener(_onVerticalScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _jumpToDate(_initialDateIndex, isInitial: true);
      }
    });
  }

  @override
  void didUpdateWidget(covariant TwinCalendarMain<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedDate != oldWidget.selectedDate && widget.selectedDate != null) {
      final dateOnly = DateTime(widget.selectedDate!.year, widget.selectedDate!.month, widget.selectedDate!.day);
      if (dateOnly == _selectedDate) return;

      final index = _dateToIndexMap[dateOnly];
      if (index != null) {
        setState(() {
          _selectedDate = dateOnly;
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _jumpToDate(index);
          }
        });
      }
    }
  }

  void _initializeDates() {
    final DateTime initialDate = widget.selectedDate ?? DateTime.now();
    final DateTime startDate = initialDate.subtract(Duration(days: widget.daysInPast));
    final DateTime endDate = initialDate.add(Duration(days: widget.daysInFuture));

    DateTime currentDate = startDate;
    int index = 0;

    while (!currentDate.isAfter(endDate)) {
      final dateOnly = DateTime(currentDate.year, currentDate.month, currentDate.day);
      _dateList.add(dateOnly);
      _dateToIndexMap[dateOnly] = index;
      if (dateOnly.isAtSameMomentAs(DateTime(initialDate.year, initialDate.month, initialDate.day))) {
        _initialDateIndex = index;
        _selectedDate = dateOnly;
      }
      currentDate = currentDate.add(const Duration(days: 1));
      index++;
    }
  }

  @override
  void dispose() {
    _verticalItemPositionsListener.itemPositions.removeListener(_onVerticalScroll);
    super.dispose();
  }

  Future<void> _jumpToDate(int index, {bool isInitial = false}) async {
    if (isInitial) {
      await Future.delayed(const Duration(milliseconds: 100));
    }

    if (!mounted) return;

    _isProgrammaticScroll = true;
    final duration = isInitial ? const Duration(milliseconds: 100) : widget.scrollDuration;
    final curve = isInitial ? Curves.linear : widget.scrollCurve;

    _horizontalScrollController.scrollTo(
      index: index,
      duration: duration,
      curve: curve,
      alignment: widget.horizontalScrollAlignment,
    );
    _verticalScrollController.scrollTo(
      index: index,
      duration: duration,
      curve: curve,
    );

    Future.delayed(duration + const Duration(milliseconds: 100), () {
      if (mounted) {
        _isProgrammaticScroll = false;
      }
    });
  }

  void _onDateTapped(int index) {
    if (_dateList[index] == _selectedDate) return;
    setState(() {
      _selectedDate = _dateList[index];
    });
    _jumpToDate(index);
  }

  void _onVerticalScroll() {
    if (_isProgrammaticScroll) return;

    final positions = _verticalItemPositionsListener.itemPositions.value;
    if (positions.isEmpty) return;

    final topItem = positions.where((position) => position.itemLeadingEdge < 0.1).reduce((max, position) => position.itemLeadingEdge > max.itemLeadingEdge ? position : max);

    final newDate = _dateList[topItem.index];
    if (_selectedDate != newDate) {
      setState(() {
        _selectedDate = newDate;
      });
      _horizontalScrollController.scrollTo(
        index: topItem.index,
        duration: const Duration(milliseconds: 500),
        curve: Curves.ease,
        alignment: widget.horizontalScrollAlignment,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
      children: [
        HorizontalCalendarView(
          calendarItemHeight: widget.calendarItemHeight,
          itemCount: _dateList.length,
          initialScrollIndex: _initialDateIndex,
          itemScrollController: _horizontalScrollController,
          itemPositionsListener: _horizontalItemPositionsListener,
          itemBuilder: (context, index) {
            final date = _dateList[index];
            final isSelected = date.isAtSameMomentAs(_selectedDate);
            return InkWell(
              onTap: widget.disableOnCalendarTap ? null : () => _onDateTapped(index),
              child: widget.horizontalCalendarItemBuilder.call(context, date, isSelected),
            );
          },
        ),
        CalendarEventView(
          itemCount: _dateList.length,
          initialScrollIndex: _initialDateIndex,
          itemScrollController: _verticalScrollController,
          itemPositionsListener: _verticalItemPositionsListener,
          itemBuilder: (context, index) {
            final date = _dateList[index];
            final events = widget.items(date);

            return StickyHeader(
              header: widget.stickyHeaderBuilder?.call(date) ?? const SizedBox(),
              content: events.isEmpty
                  ? widget.onEmptyBuilder?.call() ?? const Center(child: Text('No events'))
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: events.map((event) => widget.onEventBuilder(date, event)).toList(),
                    ),
            );
          },
        ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
