// AGENTS.mdの仕様に基づいた事柄の記録を管理するクラス
/// 記録の単一エントリを表すクラス
class RecordEntry {
  final DateTime dateTime;
  final int itemId;

  RecordEntry({required this.dateTime, required this.itemId});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecordEntry &&
          runtimeType == other.runtimeType &&
          dateTime == other.dateTime &&
          itemId == other.itemId;

  @override
  int get hashCode => dateTime.hashCode ^ itemId.hashCode;

  @override
  String toString() => 'RecordEntry(dateTime: $dateTime, itemId: $itemId)';
}

class CalendarRecords {
  final List<RecordEntry> _recordsWithTime;
  final Map<DateTime, List<int>> _recordsByDay;

  CalendarRecords({
    List<RecordEntry>? recordsWithTime,
  })  : _recordsWithTime = recordsWithTime ?? [],
        _recordsByDay = _buildRecordsByDay(recordsWithTime ?? []);

  // _recordsWithTimeから_recordsByDayを構築するヘルパーメソッド
  static Map<DateTime, List<int>> _buildRecordsByDay(List<RecordEntry> recordsWithTime) {
    final Map<DateTime, List<int>> tempRecordsByDay = {};
    for (var entry in recordsWithTime) {
      final day = DateTime(entry.dateTime.year, entry.dateTime.month, entry.dateTime.day);
      tempRecordsByDay.update(day, (existingIds) => (existingIds + [entry.itemId]).toSet().toList(),
          ifAbsent: () => [entry.itemId]);
    }
    return tempRecordsByDay;
  }

  // ファイル操作のために時刻情報を持つレコードを公開する
  List<RecordEntry> get recordsWithTime => _recordsWithTime;

  // 特定の日に記録があるかどうかを判定する
  bool hasRecord(DateTime date) {
    final targetDay = DateTime(date.year, date.month, date.day);
    return _recordsByDay.containsKey(targetDay) && _recordsByDay[targetDay]!.isNotEmpty;
  }

  // 特定の日の事柄IDリストを取得する
  List<int> getRecordsForDay(DateTime date) {
    final targetDay = DateTime(date.year, date.month, date.day);
    return _recordsByDay[targetDay] ?? [];
  }
}
