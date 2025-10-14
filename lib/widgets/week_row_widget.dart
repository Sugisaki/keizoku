import 'package:flutter/material.dart';
import '../models/calendar_item.dart';
import '../models/calendar_records.dart';
import '../models/calendar_settings.dart';
import 'day_cell_widget.dart';

// 1週間分の行を表示するウィジェット
class WeekRowWidget extends StatelessWidget {
  final List<DateTime> weekDates; // この週の7日間の日付
  final DateTime displayMonth; // 表示対象の月
  final List<CalendarItem> items;
  final CalendarRecords records;
  final CalendarSettings settings;
  final bool isScrolling;
  final double cellWidth;

  const WeekRowWidget({
    super.key,
    required this.weekDates,
    required this.displayMonth,
    required this.items,
    required this.records,
    required this.settings,
    this.isScrolling = false,
    required this.cellWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 7日分のセルを横に並べる
        Row(
          children: weekDates.map((date) {
            return Expanded(
              child: AspectRatio(
                aspectRatio: 1.0, // 正方形にする
                child: DayCellWidget(
                  date: date,
                  isThisMonth: date.month == displayMonth.month,
                  items: items,
                  recordIds: records.getRecordsForDay(date),
                  settings: settings,
                  isScrolling: isScrolling,
                  cellWidth: cellWidth,
                ),
              ),
            );
          }).toList(),
        ),
        // 事柄ごとの線を引く
        _buildItemLines(),
      ],
    );
  }

  // 週の下に表示する事柄の線を構築する
  Widget _buildItemLines() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Column(
        children: items.map((item) {
          // この週にこの事柄の記録が1件でもあるかチェック
          final bool hasRecordInWeek = weekDates.any((day) {
            return records.getRecordsForDay(day).contains(item.id);
          });

          return Container(
            height: 2, // 線の太さ
            margin: const EdgeInsets.symmetric(vertical: 1.0), // 線と線の間のマージン
            color: hasRecordInWeek ? item.getEffectiveColor(settings) : settings.disabledItemColor,
          );
        }).toList(),
      ),
    );
  }
}
