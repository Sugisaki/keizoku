import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:flutter_calendar_app/main.dart';
import 'package:flutter_calendar_app/providers/calendar_provider.dart';
import 'package:flutter_calendar_app/repositories/settings_repository.dart';
import 'package:flutter_calendar_app/repositories/records_repository.dart';
import 'package:flutter_calendar_app/models/calendar_settings.dart';
import 'package:flutter_calendar_app/models/calendar_records.dart';

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
// --- ここまで ---

void main() {
  testWidgets('Calendar smoke test', (WidgetTester tester) async {
    // ダミーリポジトリのインスタンスを作成
    final settingsRepository = InMemorySettingsRepository();
    final recordsRepository = InMemoryRecordsRepository();

    // Providerをウィジェットツリーのトップに配置してアプリをビルド
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (context) => CalendarProvider(
          settingsRepository: settingsRepository,
          recordsRepository: recordsRepository,
        ),
        child: const MyApp(),
      ),
    );

    // フレームをトリガー
    await tester.pumpAndSettle();

    // Verify that the calendar title is displayed.
    expect(find.text('Calendar Demo'), findsOneWidget);

    // Verify that day headers are displayed.
    expect(find.text('SUN'), findsOneWidget);
    expect(find.text('MON'), findsOneWidget);
  });
}
