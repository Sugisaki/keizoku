import 'package:flutter/material.dart';
import 'dart:collection';
import '../models/calendar_item.dart';
import '../models/calendar_records.dart';
import '../models/calendar_settings.dart';
import 'week_row_widget.dart';

// カレンダー全体を管理・表示するメインのウィジェット
class CalendarWidget extends StatefulWidget {
  final CalendarSettings settings;
  final List<CalendarItem> items;
  final CalendarRecords records;
  final Function(DateTime) onVisibleMonthChanged;
  final DateTime displayMonth; // 追加

  const CalendarWidget({
    super.key,
    required this.settings,
    required this.items,
    required this.records,
    required this.onVisibleMonthChanged,
    required this.displayMonth, // 追加
  });

  @override
  State<CalendarWidget> createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  final ScrollController _scrollController = ScrollController();
  final List<List<DateTime>> _weeks = [];
  bool _isScrolling = false;

  @override
  void initState() {
    super.initState();
    _generateAllWeeks();
    _scrollController.addListener(_scrollListener);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      print("[DEBUG] addPostFrameCallback triggered.");
      if (_scrollController.hasClients && _weeks.isNotEmpty) {
        // 初期表示の年月を、一番下の週の最初の日に合わせる
        widget.onVisibleMonthChanged(_weeks.last.first);
        final maxScroll = _scrollController.position.maxScrollExtent;
        print("[DEBUG] Jumping to maxScrollExtent: $maxScroll");
        _scrollController.jumpTo(maxScroll);
        print("[DEBUG] Jumped to bottom.");
      } else {
        print("[DEBUG] ScrollController not attached or weeks empty in addPostFrameCallback.");
      }
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    print("[DEBUG] Scroll listener: Pixels: ${_scrollController.position.pixels}, Min: ${_scrollController.position.minScrollExtent}, Max: ${_scrollController.position.maxScrollExtent}");
    if (_scrollController.hasClients) {
      // アイテムの高さ（概算）に基づいてインデックスを計算
      final itemHeight = _scrollController.position.maxScrollExtent / (_weeks.length - 1);
      if (itemHeight > 0) {
        final topWeekIndex = (_scrollController.offset / itemHeight).floor();
        if (topWeekIndex >= 0 && topWeekIndex < _weeks.length) {
          widget.onVisibleMonthChanged(_weeks[topWeekIndex].first);
        }
      }
    }
  }

  void _generateAllWeeks() {
    print("[DEBUG] Generating all weeks...");
    _weeks.clear();

    DateTime? oldestRecordDate;
    if (widget.records.records.isNotEmpty) {
      final sortedDates = widget.records.records.keys.toList()..sort();
      oldestRecordDate = sortedDates.first;
    }

    DateTime calendarStart;
    if (oldestRecordDate != null) {
      int daysToSubtract = oldestRecordDate.weekday % 7 - widget.settings.startOfWeek % 7;
      if (daysToSubtract < 0) daysToSubtract += 7;
      calendarStart = oldestRecordDate.subtract(Duration(days: daysToSubtract));
    } else {
      final now = DateTime.now();
      final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);
      int daysToSubtract = lastDayOfMonth.weekday % 7 - widget.settings.startOfWeek % 7;
      if (daysToSubtract < 0) daysToSubtract += 7;
      DateTime currentWeekStart = lastDayOfMonth.subtract(Duration(days: daysToSubtract));
      calendarStart = currentWeekStart.subtract(const Duration(days: 5 * 7));
    }

    final now = DateTime.now();
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);
    int daysToAdd = (widget.settings.startOfWeek % 7 + 6) - lastDayOfMonth.weekday % 7;
    if (daysToAdd < 0) daysToAdd += 7;
    DateTime calendarEnd = lastDayOfMonth.add(Duration(days: daysToAdd));

    int weeksBetween = (calendarEnd.difference(calendarStart).inDays / 7).ceil();
    if (weeksBetween < 6) {
      calendarStart = calendarStart.subtract(Duration(days: (6 - weeksBetween) * 7));
    }

    print("[DEBUG] Calendar Range: $calendarStart to $calendarEnd");

    DateTime currentDate = calendarStart;
    while (currentDate.isBefore(calendarEnd)) {
      List<DateTime> week = [];
      for (int i = 0; i < 7; i++) {
        week.add(currentDate.add(Duration(days: i)));
      }
      _weeks.add(week);
      currentDate = currentDate.add(const Duration(days: 7));
    }
    print("[DEBUG] All weeks generated. Total weeks: ${_weeks.length}");
  }

  Widget _buildDayHeaders() {
      final dayNames = ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'];
      if (widget.settings.startOfWeek == DateTime.monday) {
          dayNames.add(dayNames.removeAt(0));
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
    return NotificationListener<ScrollNotification>(
      onNotification: (scrollNotification) {
        if (scrollNotification is ScrollStartNotification) {
          setState(() { _isScrolling = true; });
        } else if (scrollNotification is ScrollEndNotification) {
          setState(() { _isScrolling = false; });
        }
        return true;
      },
      child: Column(
        children: [
          _buildDayHeaders(),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              physics: const ClampingScrollPhysics(),
              itemCount: _weeks.length,
              itemBuilder: (context, index) {
                final week = _weeks[index];
                return WeekRowWidget(
                  weekDates: week,
                  displayMonth: _isScrolling ? week.first : widget.displayMonth, // 修正
                  items: widget.items,
                  records: widget.records,
                  settings: widget.settings,
                  isScrolling: _isScrolling,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
