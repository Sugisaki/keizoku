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

  const CalendarWidget({
    super.key,
    required this.settings,
    required this.items,
    required this.records,
    required this.onVisibleMonthChanged,
  });

  @override
  State<CalendarWidget> createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  final ScrollController _scrollController = ScrollController();
  // 週リスト。過去の週を効率的に追加するため、双方向キューを使用
  final ListQueue<List<DateTime>> _weeks = ListQueue();
  bool _isScrolling = false;

  @override
  void initState() {
    super.initState();
    _generateInitialWeeks();
    _scrollController.addListener(_scrollListener);

    // 初期表示の年月を通知
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_weeks.isNotEmpty) {
        widget.onVisibleMonthChanged(_weeks.first.first);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  // スクロールリスナー
  void _scrollListener() {
    // スクロール位置が一番上（過去側）に近づいたら、さらに過去の週を読み込む
    if (_scrollController.position.pixels < _scrollController.position.minScrollExtent + 200) {
      _loadMoreWeeks();
    }

    // 現在一番上に表示されている週の年月をAppBarに通知
    if (_scrollController.hasClients) {
        final topWeekIndex = (_scrollController.offset / (_scrollController.position.maxScrollExtent / _weeks.length)).floor();
        if (topWeekIndex >= 0 && topWeekIndex < _weeks.length) {
            widget.onVisibleMonthChanged(_weeks.elementAt(topWeekIndex).first);
        }
    }
  }

  // 初期表示の6週間を生成する
  void _generateInitialWeeks() {
    final now = DateTime.now();
    // 今月の最終日を取得
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);

    // lastDayOfMonthを含む週の最初の日を計算
    int daysToSubtract = lastDayOfMonth.weekday % 7 - widget.settings.startOfWeek % 7;
    if (daysToSubtract < 0) daysToSubtract += 7;
    DateTime currentWeekStart = lastDayOfMonth.subtract(Duration(days: daysToSubtract));

    // そこから遡って6週間分のデータを生成
    for (int i = 0; i < 6; i++) {
      List<DateTime> week = [];
      for (int j = 0; j < 7; j++) {
        week.add(currentWeekStart.add(Duration(days: j)));
      }
      _weeks.addFirst(week); // 過去の週をリストの先頭に追加
      currentWeekStart = currentWeekStart.subtract(const Duration(days: 7));
    }
  }

  // 過去の週データを4週間分追加する
  void _loadMoreWeeks() {
    if (_weeks.isEmpty) return;
    DateTime oldestWeekStart = _weeks.first.first;

    // さらに過去の4週間を追加
    for (int i = 0; i < 4; i++) {
      oldestWeekStart = oldestWeekStart.subtract(const Duration(days: 7));
      List<DateTime> week = [];
      for (int j = 0; j < 7; j++) {
        week.add(oldestWeekStart.add(Duration(days: j)));
      }
      _weeks.addFirst(week);
    }
    setState(() {});
  }

  // 曜日のヘッダーを構築する
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
              // 初期状態より未来（下）にはスクロールできないようにする
              physics: const ClampingScrollPhysics(),
              itemCount: _weeks.length,
              itemBuilder: (context, index) {
                final week = _weeks.elementAt(index);
                return WeekRowWidget(
                  weekDates: week,
                  // スクロール中は今月を意識しないため、一番上の週の月を基準月とする
                  displayMonth: _isScrolling ? week.first : DateTime.now(),
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
