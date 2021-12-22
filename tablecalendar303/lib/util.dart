import 'dart:collection';
import 'package:flutter/services.dart';
import 'package:table_calendar/table_calendar.dart';

/// Example Event Class
class Event {
  final String title;
  const Event(this.title);
  @override
  String toString() => title;
}

/// Example events
///
/// マップを使用する場合は、[LinkedHashMap]を使用することが強く推奨されます。
final kEvents = LinkedHashMap<DateTime,List<Event>> (
  equals: isSameDay,
  hashCode: getHashCode,
)..addAll(_kEventSource);

final _kEventSource = Map.fromIterable(List.generate(50, (index) => index),
    key: (item) => DateTime.utc(kFirstDay.year, kFirstDay.month, item * 5),
    value: (item) => List.generate(
        item % 4 + 1, (index) => Event('Event $item | ${index + 1}')))
  ..addAll({
    kToday: [
      Event('Today\'s Event 1'),
      Event('Today\'s Event 2'),
    ],
  });

int getHashCode(DateTime key) {
  return key.day * 1000000 + key.month * 10000 + key.year;
}


// [DateTime]オブジェクトのリストを[first]から[last]まで、包括的に返します。
List<DateTime> daysInRange(DateTime first, DateTime last) {
  final dayCount = last.difference(first).inDays + 1;
  return List.generate(dayCount, (index) => DateTime.utc(first.year,first.month,first.day + index),
  );
}

// Calendarの初期値で使う。
final kToday = DateTime.now();
final kFirstDay = DateTime(kToday.year, kToday.month - 3, kToday.day);
final kLastDay = DateTime(kToday.year, kToday.month + 3, kToday.day);