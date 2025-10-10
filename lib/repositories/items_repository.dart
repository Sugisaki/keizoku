import '../models/calendar_item.dart';

// 事柄リストの永続化に関する操作を定義する抽象クラス（インターフェース）
abstract class ItemsRepository {
  // 事柄リストを読み込む
  Future<List<CalendarItem>> loadItems();

  // 事柄リストを保存する
  Future<void> saveItems(List<CalendarItem> items);
}
