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
  final DateTime displayMonth;
  final int maxRows; // 追加

  const CalendarWidget({
    super.key,
    required this.settings,
    required this.items,
    required this.records,
    required this.onVisibleMonthChanged,
    required this.displayMonth,
    required this.maxRows, // 追加
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
        widget.onVisibleMonthChanged(_weeks.last.first);

        // LayoutBuilderから得られる正確な高さ情報を使って計算する
        final RenderBox renderBox = context.findRenderObject() as RenderBox;
        final listViewHeight = renderBox.size.height - 32.0; // ヘッダーとスペースの高さを引く

        final double totalContentHeight = (_weeks.length / widget.maxRows) * listViewHeight;
        final initialScrollOffset = totalContentHeight - listViewHeight;

        print("[DEBUG] Jumping to initial offset: $initialScrollOffset");
        if (initialScrollOffset > 0) {
          _scrollController.jumpTo(initialScrollOffset);
        }
        print("[DEBUG] Jumped to initial position.");
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

  @override
  void didUpdateWidget(covariant CalendarWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.records != oldWidget.records || widget.settings != oldWidget.settings) {
      print("[DEBUG] Records or settings updated. Regenerating weeks.");
      setState(() {
        _generateAllWeeks();
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          final double itemHeight = _scrollController.position.maxScrollExtent / (_weeks.length - 1);
          final int lastItemIndex = _weeks.length - 1;
          final int firstItemIndex = lastItemIndex - (widget.maxRows - 1);
          final initialScrollOffset = firstItemIndex > 0 ? firstItemIndex * itemHeight : 0.0;
          _scrollController.jumpTo(initialScrollOffset);
          print("[DEBUG] Jumped to initial position after update.");
        }
      });
    }
  }

  void _scrollListener() {
    // (略: 変更なし)
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
      // 記録がない場合は、今日の(maxRows-1)週間前を開始とする
      final now = DateTime.now();
      int daysToSubtract = now.weekday % 7 - widget.settings.startOfWeek % 7;
      if (daysToSubtract < 0) daysToSubtract += 7;
      DateTime thisWeekStart = now.subtract(Duration(days: daysToSubtract));
      calendarStart = thisWeekStart.subtract(Duration(days: (widget.maxRows - 1) * 7));
    }

    // カレンダーの終了日を「今日を含む週の最終日」に設定
    final now = DateTime.now();
    int daysToAdd = (widget.settings.startOfWeek % 7 + 6) - now.weekday % 7;
    if (daysToAdd < 0) daysToAdd += 7;
    DateTime calendarEnd = now.add(Duration(days: daysToAdd));

    // 全体の週がmaxRowsより少ない場合は、過去に遡ってパディングする
    int weeksBetween = (calendarEnd.difference(calendarStart).inDays / 7).ceil();
    if (weeksBetween < widget.maxRows) {
      calendarStart = calendarStart.subtract(Duration(days: (widget.maxRows - weeksBetween) * 7));
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

  // (略: _buildDayHeaders と build メソッドは変更なし)
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
