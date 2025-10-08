import 'package:flutter/material.dart';
import '../models/calendar_settings.dart';
import '../models/calendar_item.dart';
import '../models/calendar_records.dart';
import '../repositories/settings_repository.dart';
import '../repositories/records_repository.dart';

// アプリケーションの状態を管理するクラス
class CalendarProvider extends ChangeNotifier {
  late final SettingsRepository _settingsRepository;
  late final RecordsRepository _recordsRepository;

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
  }) {
    _settingsRepository = settingsRepository;
    _recordsRepository = recordsRepository;

    // 初期データで初期化
    _settings = CalendarSettings();
    _records = CalendarRecords();
    // 事柄リストは当面固定データとする
    _items = [
      CalendarItem(id: 1, name: 'Work'),
      CalendarItem(id: 2, name: 'Personal', itemColorHex: '#ff7f0e'),
      CalendarItem(id: 3, name: 'Workout', icon: Icons.fitness_center),
      CalendarItem(id: 9, name: 'Meeting', itemColorHex: '#d62728'),
      CalendarItem(id: 4, name: 'Study'),
      CalendarItem(id: 5, name: 'Hobby'),
      CalendarItem(id: 6, name: 'Shopping'),
      CalendarItem(id: 7, name: 'Health'),
      CalendarItem(id: 8, name: 'Family'),
    ];

    // 永続化されたデータをロードする
    loadData();
  }

  // 起動時にデータをロードする
  Future<void> loadData() async {
    _settings = await _settingsRepository.loadSettings();
    _records = await _recordsRepository.loadRecords();
    notifyListeners();
  }

  // 今日の事柄の記録を追加/更新する
  Future<void> addRecordsForToday(List<int> itemIds) async {
    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    // recordsのMapは不変(immutable)として扱うため、新しいMapを作成して更新する
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
