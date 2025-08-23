import 'package:flutter/material.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class HorizontalCalendarView extends StatelessWidget {
  const HorizontalCalendarView({
    super.key,
    required this.calendarItemHeight,
    required this.itemCount,
    required this.initialScrollIndex,
    required this.itemScrollController,
    required this.itemPositionsListener,
    required this.itemBuilder,
  });

  final double calendarItemHeight;
  final int itemCount;
  final int initialScrollIndex;
  final ItemScrollController itemScrollController;
  final ItemPositionsListener itemPositionsListener;
  final Widget Function(BuildContext, int) itemBuilder;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: calendarItemHeight,
      child: ScrollablePositionedList.separated(
        itemCount: itemCount,
        initialScrollIndex: initialScrollIndex,
        scrollDirection: Axis.horizontal,
        itemScrollController: itemScrollController,
        itemPositionsListener: itemPositionsListener,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        padding: EdgeInsets.symmetric(horizontal: 16),
        itemBuilder: itemBuilder,
      ),
    );
  }
}
