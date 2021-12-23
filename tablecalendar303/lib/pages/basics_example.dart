import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../utils.dart';

class TableBasicsExample extends StatefulWidget {
  @override
  _TableBasicsExampleState createState() => _TableBasicsExampleState();
}

class _TableBasicsExampleState extends State<TableBasicsExample> {

  // カレンダーが表示可能な形式。
  // enum CalendarFormat { month, twoWeeks, week }
  CalendarFormat _calendarFormat = CalendarFormat.month;
  // _focusedDay：選択した日付、今アクティブな日付
  DateTime _focusedDay = DateTime.now();
  // ユーザーが選択した日付
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('TableCalendar - Basics'),
        ),
        body: TableCalendar(
            firstDay: kFirstDay,
            lastDay: kLastDay,
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) {
              // selectedDayPredicateを使用して、現在どの日が選択されているかを判断します。
              // もしこれが真を返したら、 `day` が選択されたものとしてマークされる。
              // isSameDayを使用することは、以下のことを無視するために推奨されます。
              // 比較されたDateTimeオブジェクトの時間部分。

              /// isSameDayは、2つのDateTimeオブジェクトが同じ日であるかどうかをチェックします。
              /// どちらかが NULL の場合、`false` を返します。
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focuseDay) {
              // カレンダーウィジェットに次のコードを追加すると、ユーザーのタップに応答して、タップされた日を選択済みとしてマークできます。
              // 1日をタップして選択されるイベント
              //
              if (!isSameDay(_selectedDay, selectedDay)) {
                // 選択された日を更新するときに `setState()` を呼び出します。
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focuseDay;
                });
              }
            },
          onFormatChanged: (format) {
              // calendarFormat: に初期のフォーマットを指定しておく
              // 表示されているカレンダー形式を動的に更新するには、これらの行をウィジェットに追加します。
              // カレンダーの右上の形式変更ボタンでイベント発生
              if (_calendarFormat != format) {
                // カレンダーのフォーマットを更新する際に `setState()` を呼び出す。
                setState(() {
                  _calendarFormat = format;
                });
              }
          },
          onPageChanged: (focusedDay) {
            // onPageChangedでページが更新されるイベント
            // ページが更新されると、選択済みの日付（focusedDay）も初期化される。
            // なので、今のfocusedDayを_focusedDay（ローカル変数）に記憶しておく。
            // この_focusedDayは、ウィジェットのBody更新時に再設定「focusedDay: _focusedDay,」される。
            // ここでは `setState()` を呼び出す必要はありません。
            _focusedDay = focusedDay;
          },
        )
    );
  }
}
