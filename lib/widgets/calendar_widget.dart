import 'package:flutter/material.dart';
import 'dart:collection';
import '../models/calendar_item.dart';
import '../models/calendar_records.dart';
import '../models/calendar_settings.dart';
import 'week_row_widget.dart';

class CalendarWidget extends StatefulWidget {
  final CalendarSettings settings;
  final List<CalendarItem> items;
  final CalendarRecords records;
  final Function(DateTime) onVisibleMonthChanged;
  final DateTime displayMonth;
  final int maxRows;

  const CalendarWidget({
    super.key,
    required this.settings,
    required this.items,
    required this.records,
    required this.onVisibleMonthChanged,
    required this.displayMonth,
    required this.maxRows,
  });

  @override
  State<CalendarWidget> createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  final ScrollController _scrollController = ScrollController();
  final List<List<DateTime>> _weeks = [];
  bool _isScrolling = false;
  bool _initialScrollCompleted = false;

  @override
  void initState() {
    super.initState();
    _generateAllWeeks();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant CalendarWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.records != oldWidget.records || widget.settings != oldWidget.settings) {
      print("[DEBUG] Records or settings updated. Regenerating weeks.");
      setState(() {
        _generateAllWeeks();
        _initialScrollCompleted = false;
      });
    }
  }

  void _generateAllWeeks() {
    print("[DEBUG] Generating all weeks...");
    _weeks.clear();

    const int weeksToGenerate = 26; // 過去6ヶ月分 (約26週)

    final now = DateTime.now();
    // 「今日を含む週」の最終日を計算
    int daysToAdd = (widget.settings.startOfWeek % 7 + 6) - now.weekday % 7;
    if (daysToAdd < 0) daysToAdd += 7;
    DateTime calendarEnd = now.add(Duration(days: daysToAdd));

    // カレンダーの開始日を計算 (終了日から遡る)
    DateTime calendarStart = calendarEnd.subtract(Duration(days: (weeksToGenerate * 7) - 1));
    // 週の開始曜日に合わせる
    int startDaysToSubtract = calendarStart.weekday % 7 - widget.settings.startOfWeek % 7;
    if (startDaysToSubtract < 0) startDaysToSubtract += 7;
    calendarStart = calendarStart.subtract(Duration(days: startDaysToSubtract));

    print("[DEBUG] Calendar Range: $calendarStart to $calendarEnd");

    DateTime currentDate = calendarStart;
    while (currentDate.isBefore(calendarEnd) || currentDate.isAtSameMomentAs(calendarEnd)) {
      List<DateTime> week = [];
      for (int i = 0; i < 7; i++) {
        week.add(currentDate.add(Duration(days: i)));
      }
      _weeks.add(week);
      currentDate = currentDate.add(const Duration(days: 7));
    }
    print("[DEBUG] All weeks generated. Total weeks: ${_weeks.length}");
  }

  void _scrollListener() {
    print("[DEBUG] Scroll listener: Pixels: ${_scrollController.position.pixels}, Min: ${_scrollController.position.minScrollExtent}, Max: ${_scrollController.position.maxScrollExtent}");
    if (_scrollController.hasClients) {
      final itemHeight = _scrollController.position.maxScrollExtent / (_weeks.length - 1);
      if (itemHeight > 0) {
        final topWeekIndex = (_scrollController.offset / itemHeight).floor();
        if (topWeekIndex >= 0 && topWeekIndex < _weeks.length) {
          widget.onVisibleMonthChanged(_weeks[topWeekIndex].first);
        }
      }
    }
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
    return LayoutBuilder(
      builder: (context, constraints) {
        print("[DEBUG] CalendarWidget received constraints: $constraints");

        if (!_initialScrollCompleted && _weeks.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_scrollController.hasClients) {
              final double listViewHeight = constraints.maxHeight - 32.0;
              final double itemHeight = listViewHeight / widget.maxRows;
              final int lastItemIndex = _weeks.length - 1;
              final int firstItemIndex = lastItemIndex - (widget.maxRows - 1);
              final initialScrollOffset = firstItemIndex > 0 ? firstItemIndex * itemHeight : 0.0;

              print("[DEBUG] Jumping to initial offset: $initialScrollOffset (itemHeight: $itemHeight)");
              _scrollController.jumpTo(initialScrollOffset);

              Future.delayed(const Duration(milliseconds: 50), () {
                if(firstItemIndex >= 0 && firstItemIndex < _weeks.length) {
                  widget.onVisibleMonthChanged(_weeks[firstItemIndex].first);
                }
              });

              print("[DEBUG] Jumped to initial position.");
              _initialScrollCompleted = true;
            }
          });
        }

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
                      displayMonth: _isScrolling ? week.first : widget.displayMonth,
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
      },
    );
  }
}
