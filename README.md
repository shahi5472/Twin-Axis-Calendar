# Twin Axis Calendar

A customizable twin calendar widget for Flutter that displays a **horizontal date selector** synced
with a **vertical, scrollable list of events**.

---

## ✨ Features

- **Synced Scrolling**: Horizontal date list and vertical event list stay in sync.
- **Highly Customizable**: Use builder functions to create your own UI for dates, events, headers,
  and empty states.
- **Date Range Control**: Configure how many days to show in the past and future.
- **Smooth Animations**: Built-in animations for scrolling to dates.

---

## 🚀 Getting Started

### Installation

Add this to your package's `pubspec.yaml`:

```yaml
dependencies:
  twin_axis_calendar: ^0.0.1 # Replace with the latest version
```

Then, install it by running:
```yaml
flutter pub get
```

## Import it
Now in your Dart code, you can use:
```dart
import 'package:twin_axis_calendar/twin_axis_calendar.dart';
```

Basic Usage
```dart

class MyCalendarPage extends StatelessWidget {
  // Sample event data
  final Map<DateTime, List<String>> _events = {
    DateTime.now().add(const Duration(days: 1)): ['Meeting with team', 'Lunch'],
    DateTime.now(): ['Project Deadline'],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Twin Axis Calendar Example')),
      body: TwinCalendarMain<String>(
        selectedDate: DateTime.now(),
        items: (date) {
          // Return events for the given date
          final dateOnly = DateTime(date.year, date.month, date.day);
          return _events[dateOnly] ?? [];
        },
        horizontalCalendarItemBuilder: (context, date, isSelected) {
          return Container(
            width: 80,
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isSelected ? Colors.blue : Colors.grey,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${date.day}',
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  // Use intl package for better formatting
                  ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][date.weekday - 1],
                  style: TextStyle(
                    color: isSelected ? Colors.white70 : Colors.grey,
                  ),
                ),
              ],
            ),
          );
        },
        stickyHeaderBuilder: (date) {
          return Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            padding: const EdgeInsets.all(12),
            child: Text(
              // Use intl package for better formatting
              '${date.year}-${date.month}-${date.day}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          );
        },
        onEventBuilder: (date, event) {
          return ListTile(
            title: Text(event),
            subtitle: Text('Event on $date'),
          );
        },
        onEmptyBuilder: () {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Text('No events for this day.'),
            ),
          );
        },
      ),
    );
  }
}

```

🎨 Customization

You can customize the calendar’s behavior and appearance with these properties:

| Property                        | Description                                                                      |
| ------------------------------- | -------------------------------------------------------------------------------- |
| `selectedDate`                  | The initially selected date.                                                     |
| `items`                         | Function that provides the list of events for a given date.                      |
| `horizontalCalendarItemBuilder` | Builder for the horizontal date items.                                           |
| `onEventBuilder`                | Builder for each event widget in the vertical list.                              |
| `stickyHeaderBuilder`           | Builder for sticky date headers in the vertical list.                            |
| `onEmptyBuilder`                | Builder for the widget shown when a day has no events.                           |
| `daysInPast`                    | Number of days to display before the initial date (default: 365).                |
| `daysInFuture`                  | Number of days to display after the initial date (default: 365).                 |
| `scrollDuration`                | Animation duration when scrolling between dates.                                 |
| `scrollCurve`                   | Animation curve for scrolling.                                                   |
| `horizontalScrollAlignment`     | Alignment of the selected item in the horizontal list (0.0 = left, 1.0 = right). |


🤝 Contributing

Contributions are welcome!
Please open an issue or submit a pull request if you’d like to improve the package.


**`LICENSE`**

Create a `LICENSE` file and add the text of a license like the [MIT License](https://opensource.org/licenses/MIT).