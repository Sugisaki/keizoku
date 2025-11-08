import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import '../../models/calendar_records.dart';
import '../records_repository.dart';

// JSONファイルを使用して記録を永続化するクラス
class LocalRecordsRepository implements RecordsRepository {
  static const String _fileName = 'calendar_records.json';
  // 開発環境のテストファイルがロードされているかどうかを示すフラグ
  bool _isUsingTestAsset = false;
  // 開発環境のテストファイルがロードされているかどうかを取得する
  bool get isUsingTestAsset => _isUsingTestAsset;

  // ファイルへのパスを取得する
  Future<File> get _localFile async {
    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path;
    return File('$path/$_fileName');
  }

  // 開発環境のテストファイルをアセットから読み込む（デバッグモードのみ）
  Future<String?> _loadTestAsset() async {
    if (!kDebugMode) return null;
    try {
      final contents = await rootBundle.loadString('assets/test_calendar_records.json');
      return contents;
    } catch (e) {
      // アセットファイルが存在しない場合は静かに失敗（通常の動作）
      return null;
    }
  }

  Future<({CalendarRecords records, DateTime? lastUpdated})> _parseRecordsFile(String jsonString) async {
    final Map<String, dynamic> fullJson = jsonDecode(jsonString) as Map<String, dynamic>;

    DateTime? lastUpdated;
    if (fullJson.containsKey('lastUpdated')) {
      try {
        lastUpdated = DateTime.parse(fullJson['lastUpdated'] as String);
      } catch (e) {
        print('Error parsing lastUpdated from local file: $e');
      }
    }

    final Map<String, dynamic> recordsJson;
    if (fullJson.containsKey('records')) {
      recordsJson = (fullJson['records'] as Map<String, dynamic>?) ?? {};
    } else {
      // Old format: assume the entire map (excluding lastUpdated) is the records data
      recordsJson = Map.from(fullJson);
      recordsJson.remove('lastUpdated'); // Remove lastUpdated if it was at the top level
    }

    final List<RecordEntry> records = [];
    recordsJson.forEach((key, value) {
      try {
        final parsedDateTime = DateTime.parse(key);
        final ids = List<int>.from(value);
        for (final id in ids) {
          records.add(RecordEntry(dateTime: parsedDateTime, itemId: id));
        }
      } catch (e) {
        print('Error parsing record entry from local file: $e');
      }
    });
    return (records: CalendarRecords(recordsWithTime: records), lastUpdated: lastUpdated);
  }

  @override
  Future<CalendarRecords> loadRecords() async {
    final result = await loadRecordsWithTimestamp();
    return result.records;
  }

  @override
  Future<({CalendarRecords records, DateTime? lastUpdated})> loadRecordsWithTimestamp() async {
    try {
      // 最終的にマージされるレコードのリスト
      List<RecordEntry> finalRecords = [];
      DateTime? fileLastUpdated;

      // 1. ローカルファイルからデータを読み込み
      final file = await _localFile;
      if (await file.exists()) {
        print('Loading data from local file');
        final contents = await file.readAsString();
        final parsedResult = await _parseRecordsFile(contents);
        finalRecords.addAll(parsedResult.records.recordsWithTime);
        fileLastUpdated = parsedResult.lastUpdated;
      }

      // 2. 開発環境のテストアセットからデータを読み込み
      final testAssetContents = await _loadTestAsset();
      if (testAssetContents != null) {
        print('Loading test data from assets/test_calendar_records.json');
        // テストアセットがロードされていることを示すフラグを設定
        _isUsingTestAsset = true;
        final parsedResult = await _parseRecordsFile(testAssetContents);
        finalRecords.addAll(parsedResult.records.recordsWithTime);
        // テストアセットのlastUpdatedは考慮しない（常にローカルファイルが優先されるため）
      }
      return (records: CalendarRecords(recordsWithTime: finalRecords), lastUpdated: fileLastUpdated);
    } catch (e) {
      // エラーが発生した場合は空のレコードを返す
      print('[ERROR] loading records: $e');
      return (records: CalendarRecords(recordsWithTime: []), lastUpdated: null);
    }
  }

  @override
  Future<void> saveRecords(CalendarRecords records) async {
    // 開発環境のテストファイルがロードされている場合は保存処理を行わない
    if (_isUsingTestAsset) {
      print('[WARN] テストファイルがあるので保存処理はしていません');
      return;
    }
    try {
      final file = await _localFile;

      final Map<String, List<int>> recordsJsonMap = {};
      records.recordsWithTime.forEach((entry) {
        final key = _formatDateTime(entry.dateTime);
        recordsJsonMap.update(key, (existingIds) => (existingIds + [entry.itemId]).toSet().toList(),
            ifAbsent: () => [entry.itemId]);
      });

      final Map<String, dynamic> fullJson = {
        'lastUpdated': _formatDateTime(DateTime.now()),
        'records': recordsJsonMap,
      };

      final jsonString = jsonEncode(fullJson);
      await file.writeAsString(jsonString);
    } catch (e) {
      print('Error saving records: $e');
    }
  }

  // 日時を適切にフォーマットするヘルパーメソッド（ローカルタイムを使用）
  String _formatDateTime(DateTime dateTime) {
    // マイクロ秒とミリ秒が0の場合は小数点以下を削除
    if (dateTime.microsecond == 0 && dateTime.millisecond == 0) {
      return DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(dateTime);
    } else {
      // ローカルタイムでISO8601形式（Zなし）
      return dateTime.toIso8601String().replaceAll('Z', '');
    }
  }
}