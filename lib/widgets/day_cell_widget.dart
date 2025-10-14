import 'package:flutter/material.dart';
import '../models/calendar_item.dart';
import '../models/calendar_records.dart';
import '../models/calendar_settings.dart';

// 1日分のセルを表示するウィジェット
class DayCellWidget extends StatelessWidget {
  final DateTime date;
  final bool isThisMonth; // 表示している月の日付かどうか
  final List<CalendarItem> items;
  final List<int> recordIds;
  final CalendarSettings settings;
  final bool isScrolling;
  final double cellWidth;

  const DayCellWidget({
    super.key,
    required this.date,
    required this.isThisMonth,
    required this.items,
    required this.recordIds,
    required this.settings,
    this.isScrolling = false,
    required this.cellWidth,
  });

  @override
  Widget build(BuildContext context) {
    // スクロール中はすべて黒、それ以外は当月かどうかで色を分ける
    final Color dateColor = isScrolling ? Colors.black : (isThisMonth ? Colors.black : Colors.grey);

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300, width: 0.5),
      ),
      child: Stack(
        children: [
          // 日付の表示
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Text(
                '${date.day}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: dateColor, // 動的に色を変更
                ),
              ),
            ),
          ),
          // 事柄アイコンのグリッド表示
          if (recordIds.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(2.0),
              child: _buildIconGrid(),
            ),
        ],
      ),
    );
  }

  // 3x3のアイコン用グリッドを構築する
  Widget _buildIconGrid() {
    final iconSize = cellWidth / 4;
    const orderToIndexMap = {
      7: 0, 8: 1, 9: 2,
      1: 3, 2: 4, 3: 5,
      4: 6, 5: 7, 6: 8,
    };

    final relevantItems = items
        .where((item) => recordIds.contains(item.id) && item.isEnabled)
        .toList();

    relevantItems.sort((a, b) => a.order.compareTo(b.order));

    List<Widget> gridChildren = List.generate(9, (_) => const SizedBox.shrink());

    for (var item in relevantItems) {
      if (orderToIndexMap.containsKey(item.id)) {
        final gridIndex = orderToIndexMap[item.id]!;
        if (gridIndex >= 0 && gridIndex < 9) {
          gridChildren[gridIndex] = Opacity(
            opacity: 0.5,
            child: Icon(
              item.getEffectiveIcon(),
              color: item.getEffectiveColor(settings),
              size: iconSize,
            ),
          );
        }
      }
    }

    return GridView.count(
      crossAxisCount: 3,
      physics: const NeverScrollableScrollPhysics(),
      children: gridChildren,
    );
  }
}
