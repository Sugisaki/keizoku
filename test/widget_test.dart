import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flutter_calendar_app/main.dart';
import 'package:flutter_calendar_app/providers/calendar_provider.dart';
import 'package:flutter_calendar_app/repositories/settings_repository.dart';
import 'package:flutter_calendar_app/repositories/local/local_records_repository.dart';
import 'package:flutter_calendar_app/repositories/firestore/firestore_records_repository.dart';
import 'package:flutter_calendar_app/repositories/items_repository.dart';
import 'package:flutter_calendar_app/repositories/language_repository.dart';
import 'package:flutter_calendar_app/models/calendar_settings.dart';
import 'package:flutter_calendar_app/models/calendar_records.dart';
import 'package:flutter_calendar_app/models/calendar_item.dart';
import 'package:flutter_calendar_app/models/language_settings.dart';

// Import the generated mocks
import 'widget_test.mocks.dart';

@GenerateMocks([FirebaseAuth])

// --- テスト用のダミーリポジトリ ---
class InMemorySettingsRepository implements SettingsRepository {
  @override
  Future<CalendarSettings> loadSettings() async => CalendarSettings();
  @override
  Future<void> saveSettings(CalendarSettings settings) async {}
}

class InMemoryLocalRecordsRepository implements LocalRecordsRepository {
  bool _isUsingTestAsset = false;
  @override
  bool get isUsingTestAsset => _isUsingTestAsset;
  
  @override
  Future<CalendarRecords> loadRecords() async => CalendarRecords();
  @override
  Future<void> saveRecords(CalendarRecords records) async {}
  @override
  Future<({CalendarRecords records, DateTime? lastUpdated})> loadRecordsWithTimestamp() async => (records: CalendarRecords(), lastUpdated: null);
  @override
  Future<void> deleteFirestoreRecords() async {}
}

class InMemoryFirestoreRecordsRepository implements FirestoreRecordsRepository {
  @override
  String? get uid => null;
  
  @override
  Future<CalendarRecords> loadRecords() async => CalendarRecords();
  @override
  Future<void> saveRecords(CalendarRecords records) async {}
  @override
  Future<({CalendarRecords records, DateTime? lastUpdated})> loadRecordsWithTimestamp() async => (records: CalendarRecords(), lastUpdated: null);
  @override
  Future<void> deleteFirestoreRecords() async {}
}

class InMemoryItemsRepository implements ItemsRepository {
  @override
  Future<List<CalendarItem>> loadItems() async => List.generate(9, (i) => CalendarItem(id: i + 1, name: 'Item ${i + 1}'));
  @override
  Future<void> saveItems(List<CalendarItem> items) async {}
  @override
  Future<void> deleteFirestoreItems() async {}
}

class InMemoryLanguageRepository implements LanguageRepository {
  @override
  Future<LanguageSettings> loadLanguageSettings() async => LanguageSettings(selectedLocale: const Locale('en'));
  @override
  Future<void> saveLanguageSettings(LanguageSettings settings) async {}
}

// --- ここまで ---

// Firebase Mock Platform の設定
class MockFirebaseOptions implements FirebaseOptions {
  @override
  String get apiKey => 'mock-api-key';
  
  @override
  String get appId => 'mock-app-id';
  
  @override
  String get messagingSenderId => 'mock-sender-id';
  
  @override
  String get projectId => 'mock-project-id';
  
  @override
  String? get authDomain => null;
  
  @override
  String? get databaseURL => null;
  
  @override
  String? get storageBucket => null;
  
  @override
  String? get measurementId => null;
  
  @override
  String? get trackingId => null;
  
  @override
  String? get deepLinkURLScheme => null;
  
  @override
  String? get androidClientId => null;
  
  @override
  String? get iosClientId => null;
  
  @override
  String? get iosBundleId => null;
  
  @override
  String? get appGroupId => null;
  
  @override
  Map<String, String?> get asMap => {
    'apiKey': apiKey,
    'appId': appId,
    'messagingSenderId': messagingSenderId,
    'projectId': projectId,
    'authDomain': authDomain,
    'databaseURL': databaseURL,
    'storageBucket': storageBucket,
    'measurementId': measurementId,
    'trackingId': trackingId,
    'deepLinkURLScheme': deepLinkURLScheme,
    'androidClientId': androidClientId,
    'iosClientId': iosClientId,
    'iosBundleId': iosBundleId,
    'appGroupId': appGroupId,
  };
  
  @override
  FirebaseOptions copyWith({
    String? apiKey,
    String? appId,
    String? messagingSenderId,
    String? projectId,
    String? authDomain,
    String? databaseURL,
    String? storageBucket,
    String? measurementId,
    String? trackingId,
    String? deepLinkURLScheme,
    String? androidClientId,
    String? iosClientId,
    String? iosBundleId,
    String? appGroupId,
  }) {
    return MockFirebaseOptions();
  }
}

void setupFirebaseForTest() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  // Mock Firebase Core Platform
  FirebasePlatform.instance = MockFirebasePlatform();
}

class MockFirebasePlatform extends FirebasePlatform {
  @override
  FirebaseAppPlatform app([String name = defaultFirebaseAppName]) {
    return MockFirebaseApp();
  }
  
  @override
  Future<FirebaseAppPlatform> initializeApp({
    String? name,
    FirebaseOptions? options,
  }) async {
    return MockFirebaseApp();
  }
  
  @override
  List<FirebaseAppPlatform> get apps => [MockFirebaseApp()];
}

class MockFirebaseApp extends FirebaseAppPlatform {
  MockFirebaseApp() : super(defaultFirebaseAppName, MockFirebaseOptions());
}

void main() {
  testWidgets('Calendar smoke test', (WidgetTester tester) async {
    // Firebase Mock Platform を設定
    setupFirebaseForTest();
    
    // ダミーリポジトリのインスタンスを作成
    final settingsRepository = InMemorySettingsRepository();
    final localRecordsRepository = InMemoryLocalRecordsRepository();
    final firestoreRecordsRepository = InMemoryFirestoreRecordsRepository();
    final itemsRepository = InMemoryItemsRepository();
    final languageRepository = InMemoryLanguageRepository();
    final firebaseAuth = MockFirebaseAuth();
    
    // currentUserプロパティにスタブを設定
    when(firebaseAuth.currentUser).thenReturn(null);

    // Providerをウィジェットツリーのトップに配置してアプリをビルド
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (context) => CalendarProvider(
          settingsRepository: settingsRepository,
          localRecordsRepository: localRecordsRepository,
          firestoreRecordsRepository: firestoreRecordsRepository,
          itemsRepository: itemsRepository,
          languageRepository: languageRepository,
          firebaseAuth: firebaseAuth,
        ),
        child: const MyApp(),
      ),
    );

    // 非同期処理（loadData）とUIの更新が完了するのを待つ
    await tester.pumpAndSettle();

    // カレンダーの基本的な要素（曜日のヘッダー）が表示されることだけを確認する
    expect(find.text('Sun'), findsOneWidget);
    expect(find.text('Mon'), findsOneWidget);
  });
}
