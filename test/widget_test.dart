import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:flutter_calendar_app/main.dart';
import 'package:flutter_calendar_app/providers/calendar_provider.dart';
import 'package:flutter_calendar_app/repositories/settings_repository.dart';
import 'package:flutter_calendar_app/repositories/records_repository.dart';
import 'package:flutter_calendar_app/repositories/items_repository.dart';
import 'package:flutter_calendar_app/models/calendar_settings.dart';
import 'package:flutter_calendar_app/models/calendar_records.dart';
import 'package:flutter_calendar_app/models/calendar_item.dart';

// --- テスト用のダミーリポジトリ ---
class InMemorySettingsRepository implements SettingsRepository {
  @override
  Future<CalendarSettings> loadSettings() async => CalendarSettings();
  @override
  Future<void> saveSettings(CalendarSettings settings) async {}
}

class InMemoryRecordsRepository implements RecordsRepository {
  @override
  Future<CalendarRecords> loadRecords() async => CalendarRecords();
  @override
  Future<void> saveRecords(CalendarRecords records) async {}
}

class InMemoryItemsRepository implements ItemsRepository {
  @override
  Future<List<CalendarItem>> loadItems() async => List.generate(9, (i) => CalendarItem(id: i + 1, name: 'Item ${i + 1}'));
  @override
  Future<void> saveItems(List<CalendarItem> items) async {}
}
// --- ここまで ---

void main() {
  testWidgets('Calendar smoke test', (WidgetTester tester) async {
    // ダミーリポジトリのインスタンスを作成
    final settingsRepository = InMemorySettingsRepository();
    final recordsRepository = InMemoryRecordsRepository();
    final itemsRepository = InMemoryItemsRepository(); // 追加

    // Providerをウィジェットツリーのトップに配置してアプリをビルド
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (context) => CalendarProvider(
          settingsRepository: settingsRepository,
          recordsRepository: recordsRepository,
          itemsRepository: itemsRepository, // 追加
        ),
        child: const MyApp(),
      ),
    );

    // 非同期処理（loadData）とUIの更新が完了するのを待つ
    await tester.pumpAndSettle();

    // カレンダーの基本的な要素（曜日のヘッダー）が表示されることだけを確認する
    expect(find.text('SUN'), findsOneWidget);
    expect(find.text('MON'), findsOneWidget);
  });
}
