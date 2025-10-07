import 'package:flutter/material.dart';
import '../models/calendar_item.dart';
import '../models/calendar_records.dart';
import '../models/calendar_settings.dart';
import 'week_row_widget.dart';

// カレンダー全体を管理・表示するメインのウィジェット
class CalendarWidget extends StatefulWidget {
  final CalendarSettings settings;
  final List<CalendarItem> items;
  final CalendarRecords records;
  final DateTime? startDate;
  final DateTime? endDate;

  const CalendarWidget({
    super.key,
    required this.settings,
    required this.items,
    required this.records,
    this.startDate,
    this.endDate,
  });

  @override
  State<CalendarWidget> createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  late List<List<DateTime>> _weeks;
  late DateTime _displayMonth;

  @override
  void initState() {
    super.initState();
    _calculateCalendar();
  }

  // ウィジェットのパラメータが変更されたときにカレンダーを再計算する
  @override
  void didUpdateWidget(covariant CalendarWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.startDate != oldWidget.startDate ||
        widget.endDate != oldWidget.endDate ||
        widget.settings.startOfWeek != oldWidget.settings.startOfWeek) {
      _calculateCalendar();
    }
  }

  // 表示するべき週のリストを計算する
  void _calculateCalendar() {
    final now = DateTime.now();
    // 開始日と終了日のデフォルト値を設定
    final firstDay = widget.startDate ?? DateTime(now.year, now.month, 1);
    final lastDay = widget.endDate ?? DateTime(now.year, now.month + 1, 1);

    // どの月を基準に表示するか（日付セルの色分けに使用）
    _displayMonth = firstDay;

    // カレンダーの開始日（firstDayを含む週の最初の日）を計算
    int daysToSubtract = firstDay.weekday % 7 - widget.settings.startOfWeek % 7;
    if (daysToSubtract < 0) {
      daysToSubtract += 7;
    }
    DateTime calendarStart = firstDay.subtract(Duration(days: daysToSubtract));

    // カレンダーの終了日（lastDayを含む週の最後の日）を計算
    int daysToAdd = (widget.settings.startOfWeek % 7 + 6) - lastDay.weekday % 7;
    if (daysToAdd < 0) {
      daysToAdd += 7;
    }
    DateTime calendarEnd = lastDay.add(Duration(days: daysToAdd));

    // 週ごとの日付リストを生成
    _weeks = [];
    DateTime currentDate = calendarStart;
    while (currentDate.isBefore(calendarEnd) || currentDate.isAtSameMomentAs(calendarEnd)) {
      List<DateTime> week = [];
      for (int i = 0; i < 7; i++) {
        week.add(currentDate.add(Duration(days: i)));
      }
      _weeks.add(week);
      currentDate = currentDate.add(const Duration(days: 7));
    }
  }

  // 曜日のヘッダーを構築する
  Widget _buildDayHeaders() {
      // 英語の曜日名をリストで定義
      final dayNames = ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'];

      // 週の開始曜日に合わせてリストを回転
      if (widget.settings.startOfWeek == DateTime.monday) {
          dayNames.add(dayNames.removeAt(0)); // 日曜日をリストの最後に移動
      }

      return Row(
          children: dayNames.map((day) => Expanded(
              child: Center(
                  child: Text(day, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))
              )
          )).toList(),
      );
  }

  @override
  Widget build(BuildContext context) {
    if (_weeks.isEmpty) {
      return const Center(child: Text("No dates to display."));
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildDayHeaders(),
        const SizedBox(height: 8),
        ..._weeks.map((week) => WeekRowWidget(
          weekDates: week,
          displayMonth: _displayMonth,
          items: widget.items,
          records: widget.records,
          settings: widget.settings,
        )).toList(),
      ],
    );
  }
}
