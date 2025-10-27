import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:mockito/mockito.dart'; // Import mockito
import '../lib/providers/calendar_provider.dart';
import '../lib/repositories/records_repository.dart';
import '../lib/repositories/settings_repository.dart';
import '../lib/repositories/items_repository.dart';
import '../lib/repositories/language_repository.dart';
import '../lib/repositories/local/local_records_repository.dart';
import '../lib/models/calendar_settings.dart';
import '../lib/models/calendar_item.dart';
import '../lib/models/language_settings.dart';
import 'dart:io';
import 'dart:convert';

/**
 * Gemini でテストを生成した
  # プロンプト
    事柄id=1 の事柄を追加したら、それがjsonファイルに保存されて、
    "2025-10-26T13:50:03.000":[1]
    このようなエントリが追加されることを確認するテスト。
  Gemini>
    これにより、以下のことが確認されました。
    1. LocalRecordsRepository は、特定の時刻コンポーネントを持つレコードを正しく保存します。
    2. 同じ日でも異なる時刻の複数のレコードを正しく処理します。
    3. 正確な DateTime（時刻を含む）が同じ場合、項目IDを正しくマージします。
    4. レコードを正しく削除します。
    5. CalendarProvider.updateRecordsForToday メソッドは期待どおりに機能します。
 */

// Mock PathProviderPlatform
class MockPathProviderPlatform extends PathProviderPlatform with Mock {
  @override
  Future<String?> getApplicationDocumentsPath() async {
    return Directory.current.path; // Use current directory for testing
  }
}

// Mock Repositories
class MockSettingsRepository extends Mock implements SettingsRepository {
  @override
  Future<CalendarSettings> loadSettings() async => CalendarSettings();
  @override
  Future<void> saveSettings(CalendarSettings settings) async {}
}

class MockItemsRepository extends Mock implements ItemsRepository {
  @override
  Future<List<CalendarItem>> loadItems() async => [];
  @override
  Future<void> saveItems(List<CalendarItem> items) async {}
}

class MockLanguageRepository extends Mock implements LanguageRepository {
  @override
  Future<LanguageSettings> loadLanguageSettings() async => const LanguageSettings();
  @override
  Future<void> saveLanguageSettings(LanguageSettings settings) async {}
}

void main() {
  group('Records Saving Test', () {
    late LocalRecordsRepository localRecordsRepository;
    late CalendarProvider calendarProvider;
    late String testFilePath;

    setUp(() async {
      // Initialize mock path provider
      PathProviderPlatform.instance = MockPathProviderPlatform();

      localRecordsRepository = LocalRecordsRepository();
      testFilePath = '${Directory.current.path}/calendar_records.json';

      // Ensure the test file is clean before each test
      final file = File(testFilePath);
      if (await file.exists()) {
        await file.delete();
      }

      calendarProvider = CalendarProvider(
        settingsRepository: MockSettingsRepository(),
        recordsRepository: localRecordsRepository,
        itemsRepository: MockItemsRepository(),
        languageRepository: MockLanguageRepository(),
      );
      await calendarProvider.loadData(); // Load initial data (should be empty)
    });

    tearDown(() async {
      // Clean up the test file after each test
      final file = File(testFilePath);
      if (await file.exists()) {
        await file.delete();
      }
    });

    test('should save a new record with specific time and item ID', () async {
      final testDateTime = DateTime(2025, 10, 26, 13, 50, 3);
      final testItemId = 1;

      // Add the record
      await calendarProvider.updateRecordsForToday(testDateTime, [testItemId], []);

      // Read the file directly
      final file = File(testFilePath);
      expect(await file.exists(), isTrue);

      final contents = await file.readAsString();
      final json = jsonDecode(contents) as Map<String, dynamic>;

      // Format the DateTime key as it would be in the JSON
      final expectedKey = testDateTime.toIso8601String();

      expect(json, containsPair(expectedKey, [testItemId]));
    });

    test('should add multiple records for the same day but different times', () async {
      final testDateTime1 = DateTime(2025, 10, 26, 13, 0, 0);
      final testItemId1 = 1;
      final testDateTime2 = DateTime(2025, 10, 26, 14, 0, 0);
      final testItemId2 = 3;

      await calendarProvider.updateRecordsForToday(testDateTime1, [testItemId1], []);
      await calendarProvider.updateRecordsForToday(testDateTime2, [testItemId2], []);

      final file = File(testFilePath);
      final contents = await file.readAsString();
      final json = jsonDecode(contents) as Map<String, dynamic>;

      expect(json, containsPair(testDateTime1.toIso8601String(), [testItemId1]));
      expect(json, containsPair(testDateTime2.toIso8601String(), [testItemId2]));
    });

    test('should merge item IDs if the exact DateTime is the same', () async {
      final testDateTime = DateTime(2025, 10, 26, 13, 50, 0);
      final testItemId1 = 1;
      final testItemId2 = 3;

      await calendarProvider.updateRecordsForToday(testDateTime, [testItemId1], []);
      await calendarProvider.updateRecordsForToday(testDateTime, [testItemId2], []); // This should merge

      final file = File(testFilePath);
      final contents = await file.readAsString();
      final json = jsonDecode(contents) as Map<String, dynamic>;

      expect(json, containsPair(testDateTime.toIso8601String(), [testItemId1, testItemId2]));
    });

    test('should remove a record entry if item ID is removed and no other IDs remain for that DateTime', () async {
      final testDateTime = DateTime(2025, 10, 26, 13, 50, 0);
      final testItemId = 1;

      // Add the record first
      await calendarProvider.updateRecordsForToday(testDateTime, [testItemId], []);

      // Then remove it
      await calendarProvider.updateRecordsForToday(testDateTime, [], [testItemId]);

      final file = File(testFilePath);
      final contents = await file.readAsString();
      final json = jsonDecode(contents) as Map<String, dynamic>;

      expect(json, isNot(contains(testDateTime.toIso8601String())));
    });

    test('should remove only the specified item ID from a multi-item record', () async {
      final testDateTime = DateTime(2025, 10, 26, 13, 50, 0);
      final testItemId1 = 1;
      final testItemId2 = 2;
      final testItemId3 = 3;

      // Add multiple items to the same timestamp
      await calendarProvider.updateRecordsForToday(testDateTime, [testItemId1, testItemId2, testItemId3], []);

      // Remove one item
      await calendarProvider.updateRecordsForToday(testDateTime, [], [testItemId2]);

      final file = File(testFilePath);
      final contents = await file.readAsString();
      final json = jsonDecode(contents) as Map<String, dynamic>;

      expect(json, containsPair(testDateTime.toIso8601String(), [testItemId1, testItemId3]));
      expect(json[testDateTime.toIso8601String()], isNot(contains(testItemId2)));
    });
  });
}
