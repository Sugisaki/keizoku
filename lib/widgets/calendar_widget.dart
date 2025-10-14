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
  final CalendarWidgetController? controller;

  const CalendarWidget({
    super.key,
    required this.settings,
    required this.items,
    required this.records,
    required this.onVisibleMonthChanged,
    required this.displayMonth,
    required this.maxRows,
    this.controller,
  });

  @override
  State<CalendarWidget> createState() => _CalendarWidgetState();
}

class CalendarWidgetController {
  _CalendarWidgetState? _state;

  void _attach(_CalendarWidgetState state) {
    _state = state;
  }

  void _detach() {
    _state = null;
  }

  void scrollToBottom() {
    _state?._scrollToBottom();
  }
}

class _CalendarWidgetState extends State<CalendarWidget> {
  final ScrollController _scrollController = ScrollController();
  final List<List<DateTime>> _weeks = [];
  bool _isScrolling = false;
  bool _initialScrollCompleted = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _generateAllWeeks();
    _scrollController.addListener(_scrollListener);
    widget.controller?._attach(this);
  }

  @override
  void dispose() {
    widget.controller?._detach();
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
    int daysToAdd = (widget.settings.startOfWeek % 7 + 6) - now.weekday % 7;
    if (daysToAdd < 0) daysToAdd += 7;
    DateTime calendarEnd = now.add(Duration(days: daysToAdd));

    DateTime calendarStart = calendarEnd.subtract(Duration(days: (weeksToGenerate * 7) - 1));
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
    if (!_isLoading && _scrollController.position.pixels == _scrollController.position.minScrollExtent) {
      _loadMorePastWeeks();
    }

    if (_scrollController.hasClients) {
      final itemHeight = _scrollController.position.maxScrollExtent > 0 ? _scrollController.position.maxScrollExtent / (_weeks.length - 1) : 0.0;
      if (itemHeight > 0) {
        final topWeekIndex = (_scrollController.offset / itemHeight).floor();
        if (topWeekIndex >= 0 && topWeekIndex < _weeks.length) {
          widget.onVisibleMonthChanged(_weeks[topWeekIndex].first);
        }
      }
    }
  }

  Future<void> _loadMorePastWeeks() async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
    });

    print("[DEBUG] Loading more past weeks...");
    final oldestWeekStart = _weeks.first.first;
    const int weeksToGenerate = 26;

    DateTime newCalendarStart = oldestWeekStart.subtract(Duration(days: (weeksToGenerate * 7)));
    int startDaysToSubtract = newCalendarStart.weekday % 7 - widget.settings.startOfWeek % 7;
    if (startDaysToSubtract < 0) startDaysToSubtract += 7;
    newCalendarStart = newCalendarStart.subtract(Duration(days: startDaysToSubtract));

    final List<List<DateTime>> newWeeks = [];
    DateTime currentDate = newCalendarStart;
    while (currentDate.isBefore(oldestWeekStart)) {
      List<DateTime> week = [];
      for (int i = 0; i < 7; i++) {
        week.add(currentDate.add(Duration(days: i)));
      }
      newWeeks.add(week);
      currentDate = currentDate.add(const Duration(days: 7));
    }

    final double oldMaxScrollExtent = _scrollController.position.maxScrollExtent;
    final int oldLength = _weeks.length;

    setState(() {
      _weeks.insertAll(0, newWeeks);
      _isLoading = false;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        final double estimatedItemHeight = (oldLength > 1) ? oldMaxScrollExtent / (oldLength - 1) : 0.0;
        final double addedHeight = newWeeks.length * estimatedItemHeight;

        _scrollController.jumpTo(addedHeight);
        print("[DEBUG] More weeks loaded. Total weeks: ${_weeks.length}");
      }
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
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
              final maxScroll = _scrollController.position.maxScrollExtent;
              print("[DEBUG] Jumping to maxScrollExtent: $maxScroll");
              _scrollController.jumpTo(maxScroll);

              widget.onVisibleMonthChanged(_weeks.last.first);

              print("[DEBUG] Jumped to bottom.");
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
