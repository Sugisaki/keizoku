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

  const DayCellWidget({
    super.key,
    required this.date,
    required this.isThisMonth,
    required this.items,
    required this.recordIds,
    required this.settings,
  });

  @override
  Widget build(BuildContext context) {
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
                  color: isThisMonth ? Colors.black : Colors.grey,
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
    // IDとグリッド位置のマッピング
    // GridViewは左上から右下へindexを振るので、仕様に合わせる
    // 7 8 9
    // 1 2 3
    // 4 5 6
    const idToIndexMap = {
      7: 0, 8: 1, 9: 2,
      1: 3, 2: 4, 3: 5,
      4: 6, 5: 7, 6: 8,
    };

    // 9個のWidgetのリストを作成し、対応するIDのアイコンで埋める
    List<Widget> gridChildren = List.generate(9, (index) {
      final targetId = idToIndexMap.entries.firstWhere((entry) => entry.value == index, orElse: () => const MapEntry(-1, -1)).key;

      if (recordIds.contains(targetId)) {
        try {
          final item = items.firstWhere((item) => item.id == targetId);
          return Opacity(
            opacity: 0.5, // 仕様通り半透明にする
            child: Icon(
              item.getEffectiveIcon(),
              color: item.getEffectiveColor(settings),
              size: 12, // サイズは調整
            ),
          );
        } catch (e) {
          return const SizedBox.shrink(); // itemが見つからない場合
        }
      }
      return const SizedBox.shrink(); // 記録がないセルは空
    });

    return GridView.count(
      crossAxisCount: 3,
      physics: const NeverScrollableScrollPhysics(), // GridView自体はスクロールさせない
      children: gridChildren,
    );
  }
}
