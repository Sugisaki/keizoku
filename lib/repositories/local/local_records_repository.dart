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
    try {
      final file = await _localFile;
      if (!await file.exists()) {
        return CalendarRecords(); // ファイルが存在しない場合は空のデータを返す
      }

      final contents = await file.readAsString();
      final json = jsonDecode(contents) as Map<String, dynamic>;

      final records = json.map((key, value) {
        // JSONのキー(String)をDateTimeに変換
        return MapEntry(DateTime.parse(key), List<int>.from(value));
      });

      return CalendarRecords(records: records);
    } catch (e) {
      // エラーが発生した場合は空のデータを返す
      print('Error loading records: $e');
      return CalendarRecords();
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
