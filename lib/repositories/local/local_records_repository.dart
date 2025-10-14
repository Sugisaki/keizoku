import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../../models/calendar_records.dart';
import '../records_repository.dart';

// JSONファイルを使用して記録を永続化するクラス
class LocalRecordsRepository implements RecordsRepository {
  static const String _fileName = 'calendar_records.json';

  // ファイルへのパスを取得する
  Future<File> get _localFile async {
    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path;
    return File('$path/$_fileName');
  }

  @override
  Future<CalendarRecords> loadRecords() async {
    // 固定のテストデータを定義
    final testData = {
      DateTime(2024, 10, 9): [1],
      DateTime(2024, 10, 10): [2],
      DateTime(2024, 10, 11): [3],

      DateTime(2025, 9, 1): [1,2,3],
      DateTime(2025, 9, 4): [1,2,3,4,5,6],
      DateTime(2025, 9, 7): [1,2,3,4,5,6,7,8,9],

      DateTime(2025, 10, 3): [2,4,6],
      DateTime(2025, 10, 9): [1,3,5],
    };

    try {
      final file = await _localFile;
      if (!await file.exists()) {
        // ファイルが存在しない場合はテストデータのみを返す
        return CalendarRecords(records: testData);
      }

      final contents = await file.readAsString();
      final json = jsonDecode(contents) as Map<String, dynamic>;

      final loadedRecords = json.map((key, value) {
        // JSONのキー(String)をDateTimeに変換
        return MapEntry(DateTime.parse(key), List<int>.from(value));
      });

      // 読み込んだデータとテストデータをマージする (テストデータが優先される)
      loadedRecords.addAll(testData);

      return CalendarRecords(records: loadedRecords);
    } catch (e) {
      // エラーが発生した場合はテストデータのみを返す
      print('Error loading records: $e');
      return CalendarRecords(records: testData);
    }
  }

  @override
  Future<void> saveRecords(CalendarRecords records) async {
    try {
      final file = await _localFile;

      // DateTimeキーをJSONで扱えるStringに変換
      final jsonEncodableMap = records.records.map((key, value) {
        return MapEntry(key.toIso8601String(), value);
      });

      final jsonString = jsonEncode(jsonEncodableMap);
      await file.writeAsString(jsonString);
    } catch (e) {
      print('Error saving records: $e');
    }
  }
}
