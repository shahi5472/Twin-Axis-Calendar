import 'package:flutter/material.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class CalendarEventView extends StatelessWidget {
  const CalendarEventView({
    super.key,
    required this.itemCount,
    required this.initialScrollIndex,
    required this.itemScrollController,
    required this.itemPositionsListener,
    required this.itemBuilder,
  });

  final int itemCount;
  final int initialScrollIndex;
  final ItemScrollController itemScrollController;
  final ItemPositionsListener itemPositionsListener;
  final Widget Function(BuildContext, int) itemBuilder;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ScrollablePositionedList.builder(
        itemCount: itemCount,
        initialScrollIndex: initialScrollIndex,
        itemScrollController: itemScrollController,
        itemPositionsListener: itemPositionsListener,
        itemBuilder: itemBuilder,
      ),
    );
  }
}
