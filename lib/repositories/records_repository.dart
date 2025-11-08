import '../models/calendar_records.dart';

// 記録データの永続化に関する操作を定義する抽象クラス（インターフェース）
abstract class RecordsRepository {
  // 記録を読み込む
  Future<CalendarRecords> loadRecords();

  // 記録を読み込む（タイムスタンプ付き）
  Future<({CalendarRecords records, DateTime? lastUpdated})> loadRecordsWithTimestamp();

  // 記録を保存する
  Future<void> saveRecords(CalendarRecords records);
}
