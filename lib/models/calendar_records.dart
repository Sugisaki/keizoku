// AGENTS.mdの仕様に基づいた事柄の記録を管理するクラス
class CalendarRecords {
  // Map<日付, 事柄IDのリスト>
  final Map<DateTime, List<int>> records;

  CalendarRecords({
    Map<DateTime, List<int>>? records,
  }) : records = records ?? {};

  // 特定の日に記録があるかどうかを判定する
  bool hasRecord(DateTime date) {
    // 日付のみを比較するために、時分秒を0にする
    final day = DateTime(date.year, date.month, date.day);
    return records.containsKey(day) && records[day]!.isNotEmpty;
  }

  // 特定の日の事柄IDリストを取得する
  List<int> getRecordsForDay(DateTime date) {
    final day = DateTime(date.year, date.month, date.day);
    return records[day] ?? [];
  }
}
