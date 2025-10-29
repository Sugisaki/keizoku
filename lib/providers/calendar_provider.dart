import 'package:flutter/material.dart';
import '../constants/color_constants.dart';
import '../models/calendar_settings.dart';
import '../models/calendar_item.dart';
import '../models/calendar_records.dart';
import '../models/language_settings.dart';
import '../repositories/settings_repository.dart';
import '../repositories/records_repository.dart';
import '../repositories/items_repository.dart';
import '../repositories/language_repository.dart';

// アプリケーションの状態を管理するクラス
class CalendarProvider extends ChangeNotifier {
  late final SettingsRepository _settingsRepository;
  late final RecordsRepository _recordsRepository;
  late final ItemsRepository _itemsRepository;
  late final LanguageRepository _languageRepository;

  late CalendarSettings _settings;
  late List<CalendarItem> _items; // 事柄リスト
  late CalendarRecords _records;
  late LanguageSettings _languageSettings;

  // 外部から状態を読み取るためのgetter
  CalendarSettings get settings => _settings;
  List<CalendarItem> get items => _items;
  CalendarRecords get records => _records;
  LanguageSettings get languageSettings => _languageSettings;

  CalendarProvider({
    required SettingsRepository settingsRepository,
    required RecordsRepository recordsRepository,
    required ItemsRepository itemsRepository,
    required LanguageRepository languageRepository,
  }) {
    _settingsRepository = settingsRepository;
    _recordsRepository = recordsRepository;
    _itemsRepository = itemsRepository;
    _languageRepository = languageRepository;

    // 初期データで初期化
    _settings = CalendarSettings();
    _records = CalendarRecords();
    _items = []; // 最初は空リスト
    _languageSettings = const LanguageSettings();

    // 永続化されたデータをロードする
    loadData();
  }

  // 起動時にデータをロードする
  Future<void> loadData() async {
    _settings = await _settingsRepository.loadSettings();
    _records = await _recordsRepository.loadRecords();
    _items = await _itemsRepository.loadItems(); // ItemsRepositoryから読み込む
    _languageSettings = await _loadLanguageSettings();
    notifyListeners();
  }

  // 言語設定を読み込む
  Future<LanguageSettings> _loadLanguageSettings() async {
    return await _languageRepository.loadLanguageSettings();
  }

  // 事柄を更新する
  Future<void> updateItem(CalendarItem updatedItem) async {
    // 1. _itemsリスト内でupdatedItemを更新
    List<CalendarItem> allItems = List.from(_items);
    final index = allItems.indexWhere((item) => item.id == updatedItem.id);
    if (index != -1) {
      allItems[index] = updatedItem;
    } else {
      allItems.add(updatedItem);
    }

    // 2. 有効なアイテムと無効なアイテムを分離
    List<CalendarItem> enabled = allItems.where((item) => item.isEnabled).toList();
    List<CalendarItem> disabled = allItems.where((item) => !item.isEnabled).toList();

    // 3. 有効なアイテムをユーザーが設定したorderを尊重しつつソート
    //    - updatedItemが有効な場合のみ処理
    if (updatedItem.isEnabled) {
      // updatedItemをenabledリストから一旦削除（もし存在すれば）
      enabled.removeWhere((item) => item.id == updatedItem.id);

      // ユーザーが設定したorderを有効な範囲に調整
      int desiredOrder = updatedItem.order;
      if (desiredOrder < 1) desiredOrder = 1;
      if (desiredOrder > enabled.length + 1) desiredOrder = enabled.length + 1;

      // desiredOrderの位置にupdatedItemを挿入
      enabled.insert(desiredOrder - 1, updatedItem);
    }

    // 4. 有効なアイテムのorderを1から連番で再割り当て
    for (int i = 0; i < enabled.length; i++) {
      enabled[i] = enabled[i].copyWith(order: i + 1);
    }

    // 5. 最終的な_itemsリストを再構築（有効なアイテムをorder順に、その後無効なアイテム）
    _items = [...enabled, ...disabled];

    await _itemsRepository.saveItems(_items);
    notifyListeners();
  }

  // 事柄の順序を並べ替える
  Future<void> reorderItems(List<CalendarItem> reorderedItems) async {
    // 有効なアイテムのorderを1から連番で再割り当て
    List<CalendarItem> enabled = reorderedItems.where((item) => item.isEnabled).toList();
    List<CalendarItem> disabled = reorderedItems.where((item) => !item.isEnabled).toList();
    
    for (int i = 0; i < enabled.length; i++) {
      enabled[i] = enabled[i].copyWith(order: i + 1);
    }
    //
    _items = [...enabled, ...disabled];
    await _itemsRepository.saveItems(_items);
    notifyListeners();
  }

  // 初期事柄の名前を多言語化された名前に更新
  Future<void> updateDefaultItemNames(String newItemText) async {
    bool hasChanges = false;
    List<CalendarItem> updatedItems = [];
    
    for (CalendarItem item in _items) {
      // デフォルト名パターン（新規項目{数字} または New Item{数字} など）をチェック
      final expectedDefaultName = ColorConstants.getDefaultItemName(newItemText, item.id);
      
      // 現在の名前がデフォルトパターンのいずれかと一致するかチェック
      final isDefaultName = _isDefaultItemName(item.name, item.id);
      
      if (isDefaultName && item.name != expectedDefaultName) {
        updatedItems.add(item.copyWith(name: expectedDefaultName));
        hasChanges = true;
      } else {
        updatedItems.add(item);
      }
    }
    
    if (hasChanges) {
      _items = updatedItems;
      await _itemsRepository.saveItems(_items);
      notifyListeners();
    }
  }

  // デフォルト名かどうかを判定するヘルパーメソッド
  bool _isDefaultItemName(String name, int id) {
    // 各言語でのデフォルト名パターンをチェック
    final patterns = [
      '新規項目$id',      // 日本語
      'New Item$id',      // 英語
      '新建项目$id',      // 中国語簡体字
      '新建項目$id',      // 中国語繁体字
      '새 항목$id',       // 韓国語
      'Nouvel élément$id', // フランス語
      'Neues Element$id', // ドイツ語
      'Nuevo elemento$id', // スペイン語
      'नया आइटम$id',       // ヒンディー語
      'Item Baru$id',     // インドネシア語
      'Novo Item$id',     // ポルトガル語
      'عنصر جديد$id',        // アラビア語
    ];
    return patterns.contains(name);
  }



  // 指定された時刻の記録を更新する（追加・削除）
  Future<void> updateRecordsForToday(DateTime dateTime, List<int> addIds, List<int> removeIds) async {
    final List<RecordEntry> newRecordsList = List.from(_records.recordsWithTime);

    // 同じ日かどうかを判定するヘルパーメソッド
    bool isSameDay(DateTime dt1, DateTime dt2) {
      return dt1.year == dt2.year && dt1.month == dt2.month && dt1.day == dt2.day;
    }

    // 削除するIDを処理
    for (final removeId in removeIds) {
      newRecordsList.removeWhere((entry) => isSameDay(entry.dateTime, dateTime) && entry.itemId == removeId);
    }

    // 追加するIDを処理
    for (final addId in addIds) {
      // 同じdateTimeとitemIdの組み合わせが既に存在しないか確認してから追加
      final bool alreadyExists = newRecordsList.any((entry) => isSameDay(entry.dateTime, dateTime) && entry.itemId == addId);
      if (!alreadyExists) {
        newRecordsList.add(RecordEntry(dateTime: dateTime, itemId: addId));
      }
    }

    _records = CalendarRecords(recordsWithTime: newRecordsList);
    await _recordsRepository.saveRecords(_records);
    notifyListeners();
  }

  // 週の開始曜日を変更する
  Future<void> updateStartOfWeek(int newStartOfWeek) async {
    _settings = _settings.copyWith(startOfWeek: newStartOfWeek);
    await _settingsRepository.saveSettings(_settings);
    notifyListeners();
  }

  // 言語設定を変更する
  Future<void> updateLanguage(Locale? newLocale) async {
    _languageSettings = _languageSettings.copyWith(selectedLocale: newLocale);
    await _languageRepository.saveLanguageSettings(_languageSettings);
    notifyListeners();
  }

  // 指定された日に特定の事柄が記録されているかチェック
  bool _hasRecordOnDay(DateTime date, int itemId) {
    final recordsForDay = _records.getRecordsForDay(date);
    return recordsForDay.contains(itemId);
  }

  // 連続日数を計算
  int calculateContinuousDays(int itemId) {
    int totalContinuousDays = _calculatePastContinuousDays(itemId);
    DateTime today = DateTime.now();
    today = DateTime(today.year, today.month, today.day);
    if (_hasRecordOnDay(today, itemId)) {
      totalContinuousDays++;
    }
    return totalContinuousDays;
  }

  // 過去連続日数を計算（昨日から遡る）
  int _calculatePastContinuousDays(int itemId) {
    int pastContinuousDays = 0;
    DateTime currentDate = DateTime.now().subtract(const Duration(days: 1)); // 昨日から開始
    currentDate = DateTime(currentDate.year, currentDate.month, currentDate.day); // 時刻をリセット

    while (true) {
      if (_hasRecordOnDay(currentDate, itemId)) {
        pastContinuousDays++;
      } else {
        break;
      }
      currentDate = currentDate.subtract(const Duration(days: 1));
    }
    return pastContinuousDays;
  }

  // 連続週数を計算
  int calculateContinuousWeeks(int itemId) {
    int totalContinuousWeeks = _calculatePastContinuousWeeks(itemId);
    DateTime thisWeek = DateTime.now();
    if (_hasRecordInWeek(thisWeek, itemId)) {
      totalContinuousWeeks++;
    }
    return totalContinuousWeeks;
  }

  // 過去連続週数を計算（先週から遡る）
  int _calculatePastContinuousWeeks(int itemId) {
    int pastContinuousWeeks = 0;
    DateTime currentDate = DateTime.now().subtract(const Duration(days: 7)); // 先週から開始
    currentDate = DateTime(currentDate.year, currentDate.month, currentDate.day); // 時刻をリセット

    while (true) {
      if (_hasRecordInWeek(currentDate, itemId)) {
        pastContinuousWeeks++;
      } else {
        break;
      }
      currentDate = currentDate.subtract(const Duration(days: 7));
    }
    return pastContinuousWeeks;
  }

  // 指定された週に特定の事柄が記録されているかチェック
  bool _hasRecordInWeek(DateTime dateInWeek, int itemId) {
    // 設定された週の開始曜日を考慮して週の開始日を計算
    int daysFromStartOfWeek;
    if (_settings.startOfWeek == ColorConstants.sundayStartOfWeek) {
      // 日曜始まりの場合: 日曜=0, 月曜=1, ..., 土曜=6
      daysFromStartOfWeek = dateInWeek.weekday % 7;
    } else {
      // 月曜始まりの場合: 月曜=0, 火曜=1, ..., 日曜=6
      daysFromStartOfWeek = dateInWeek.weekday - 1;
    }
    DateTime startOfWeek = dateInWeek.subtract(Duration(days: daysFromStartOfWeek));
    for (int i = 0; i < 7; i++) {
      if (_hasRecordOnDay(startOfWeek.add(Duration(days: i)), itemId)) {
        return true;
      }
    }
    return false;
  }

  // 連続月数を計算
  int calculateContinuousMonths(int itemId) {
    int totalContinuousMonths = _calculatePastContinuousMonths(itemId);
    DateTime thisMonth = DateTime.now();
    thisMonth = DateTime(thisMonth.year, thisMonth.month, 1);
    if (_hasRecordInMonth(thisMonth, itemId)) {
      totalContinuousMonths++;
    }
    return totalContinuousMonths;
  }

  // 過去連続月数を計算（先月から遡る）
  int _calculatePastContinuousMonths(int itemId) {
    int pastContinuousMonths = 0;
    DateTime currentDate = DateTime.now();
    currentDate = DateTime(currentDate.year, currentDate.month - 1, 1); // 先月から開始

    while (true) {
      if (_hasRecordInMonth(currentDate, itemId)) {
        pastContinuousMonths++;
      } else {
        break;
      }
      currentDate = DateTime(currentDate.year, currentDate.month - 1, 1); // 前の月の初めに移動
    }
    return pastContinuousMonths;
  }

  // 指定された月に特定の事柄が記録されているかチェック
  bool _hasRecordInMonth(DateTime dateInMonth, int itemId) {
    final startOfMonth = DateTime(dateInMonth.year, dateInMonth.month, 1);
    final endOfMonth = DateTime(dateInMonth.year, dateInMonth.month + 1, 0);

    for (var date = startOfMonth; date.isBefore(endOfMonth.add(const Duration(days: 1))); date = date.add(const Duration(days: 1))) {
      if (_hasRecordOnDay(date, itemId)) {
        return true;
      }
    }
    return false;
  }

  // 最後の記録日を取得
  DateTime? getLastRecordDate(int itemId) {
    // 今日から過去に遡って記録を探す
    DateTime currentDate = DateTime.now();
    currentDate = DateTime(currentDate.year, currentDate.month, currentDate.day); // 時刻をリセット
    
    // 最大で1年分だけ遡る（パフォーマンス対策）
    final oneYearAgo = currentDate.subtract(const Duration(days: 365));
    
    while (!currentDate.isBefore(oneYearAgo)) {
      if (_hasRecordOnDay(currentDate, itemId)) {
        return currentDate;
      }
      currentDate = currentDate.subtract(const Duration(days: 1));
    }
    
    return null; // 記録が見つからない場合
  }

  // 事柄の記録のある総日数を計算
  int getTotalRecordDays(int itemId) {
    int totalDays = 0;
    
    // 今日から過去に遡って記録を探す
    DateTime currentDate = DateTime.now();
    currentDate = DateTime(currentDate.year, currentDate.month, currentDate.day); // 時刻をリセット
    
    // 最大で1年分だけ遡る（パフォーマンス対策）
    final oneYearAgo = currentDate.subtract(const Duration(days: 365));
    
    while (!currentDate.isBefore(oneYearAgo)) {
      if (_hasRecordOnDay(currentDate, itemId)) {
        totalDays++;
      }
      currentDate = currentDate.subtract(const Duration(days: 1));
    }
    
    return totalDays;
  }
}
