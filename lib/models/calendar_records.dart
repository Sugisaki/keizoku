import 'package:intl/intl.dart';

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
    Map<String, List<int>>? recordsMap, // New parameter for Firestore data
  })  : _recordsWithTime = recordsWithTime ?? [],
        _recordsByDay = recordsMap != null
            ? _buildRecordsByDayFromMap(recordsMap)
            : _buildRecordsByDay(recordsWithTime ?? []);

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

  // Helper method to build _recordsByDay from a map (Firestore format)
  static Map<DateTime, List<int>> _buildRecordsByDayFromMap(Map<String, List<int>> recordsMap) {
    final Map<DateTime, List<int>> tempRecordsByDay = {};
    for (final entry in recordsMap.entries) {
      try {
        final dateTime = DateTime.parse(entry.key);
        final day = DateTime(dateTime.year, dateTime.month, dateTime.day);
        tempRecordsByDay.update(day, (existingIds) => (existingIds + entry.value).toSet().toList(),
            ifAbsent: () => entry.value);
      } catch (e) {
        print('Error parsing date string from Firestore: ${entry.key}, Error: $e');
      }
    }
    return tempRecordsByDay;
  }

  // Factory method to create CalendarRecords from Firestore data
  factory CalendarRecords.fromJson(Map<String, dynamic> json) {
    final List<RecordEntry> recordsWithTime = [];
    json.forEach((key, value) {
      try {
        final parsedDateTime = DateTime.parse(key);
        if (value is List) {
          for (final itemId in value) {
            if (itemId is int) {
              recordsWithTime.add(RecordEntry(dateTime: parsedDateTime, itemId: itemId));
            }
          }
        }
      } catch (e) {
        print('Error parsing date string from Firestore: $key, Error: $e');
      }
    });
    return CalendarRecords(recordsWithTime: recordsWithTime);
  }

  // Convert CalendarRecords to a JSON-compatible map for Firestore
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> jsonMap = {};
    for (final entry in _recordsWithTime) {
      // ミリ秒以下が0の場合は小数点以下を省略し、そうでない場合はミリ秒まで表示する
      final String formattedDateTime = entry.dateTime.millisecond == 0 && entry.dateTime.microsecond == 0
          ? DateFormat("yyyy-MM-ddTHH:mm:ss").format(entry.dateTime)
          : DateFormat("yyyy-MM-ddTHH:mm:ss.SSS").format(entry.dateTime);
      jsonMap.update(formattedDateTime, (existingIds) => (existingIds + [entry.itemId]).toSet().toList(),
          ifAbsent: () => [entry.itemId]);
    }
    return jsonMap;
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