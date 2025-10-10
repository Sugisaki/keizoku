import 'package:flutter/material.dart';
import '../models/calendar_settings.dart';
import '../models/calendar_item.dart';
import '../models/calendar_records.dart';
import '../repositories/settings_repository.dart';
import '../repositories/records_repository.dart';
import '../repositories/items_repository.dart';

// アプリケーションの状態を管理するクラス
class CalendarProvider extends ChangeNotifier {
  late final SettingsRepository _settingsRepository;
  late final RecordsRepository _recordsRepository;
  late final ItemsRepository _itemsRepository;

  late CalendarSettings _settings;
  late List<CalendarItem> _items; // 事柄リスト
  late CalendarRecords _records;

  // 外部から状態を読み取るためのgetter
  CalendarSettings get settings => _settings;
  List<CalendarItem> get items => _items;
  CalendarRecords get records => _records;

  CalendarProvider({
    required SettingsRepository settingsRepository,
    required RecordsRepository recordsRepository,
    required ItemsRepository itemsRepository,
  }) {
    _settingsRepository = settingsRepository;
    _recordsRepository = recordsRepository;
    _itemsRepository = itemsRepository;

    // 初期データで初期化
    _settings = CalendarSettings();
    _records = CalendarRecords();
    _items = []; // 最初は空リスト

    // 永続化されたデータをロードする
    loadData();
  }

  // 起動時にデータをロードする
  Future<void> loadData() async {
    _settings = await _settingsRepository.loadSettings();
    _records = await _recordsRepository.loadRecords();
    _items = await _itemsRepository.loadItems(); // ItemsRepositoryから読み込む
    notifyListeners();
  }

  // 事柄を更新する
  Future<void> updateItem(CalendarItem updatedItem) async {
    final index = _items.indexWhere((item) => item.id == updatedItem.id);
    if (index != -1) {
      // リストの不変性を保つために新しいリストを作成
      final newItems = List<CalendarItem>.from(_items);
      newItems[index] = updatedItem;
      _items = newItems;

      await _itemsRepository.saveItems(_items);
      notifyListeners();
    }
  }

  // 今日の事柄の記録を追加/更新する
  Future<void> addRecordsForToday(List<int> itemIds) async {
    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final newRecordsMap = Map<DateTime, List<int>>.from(_records.records);

    if (itemIds.isEmpty) {
      newRecordsMap.remove(today);
    } else {
      newRecordsMap[today] = itemIds;
    }

    _records = CalendarRecords(records: newRecordsMap);
    await _recordsRepository.saveRecords(_records);
    notifyListeners();
  }

  // 週の開始曜日を変更する
  Future<void> updateStartOfWeek(int newStartOfWeek) async {
    _settings = _settings.copyWith(startOfWeek: newStartOfWeek);
    await _settingsRepository.saveSettings(_settings);
    notifyListeners();
  }
}
