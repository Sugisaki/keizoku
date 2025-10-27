import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
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

  List<RecordEntry> _parseAndMergeRecords(String jsonString) {
    final json = jsonDecode(jsonString) as Map<String, dynamic>;
    final List<RecordEntry> records = [];
    json.forEach((key, value) {
      final parsedDateTime = DateTime.parse(key);
      final ids = List<int>.from(value);
      for (final id in ids) {
        records.add(RecordEntry(dateTime: parsedDateTime, itemId: id));
      }
    });
    return records;
  }

  @override
  Future<CalendarRecords> loadRecords() async {
    try {
      // 最終的にマージされるレコードのリスト
      List<RecordEntry> finalRecords = [];

      // 1. ローカルファイルからデータを読み込み
      final file = await _localFile;
      if (await file.exists()) {
        print('Loading data from local file');
        final contents = await file.readAsString();
        final localRecords = _parseAndMergeRecords(contents);
        finalRecords.addAll(localRecords);
      }

      // 2. 開発環境のテストアセットからデータを読み込み
      final testAssetContents = await _loadTestAsset();
      if (testAssetContents != null) {
        print('Loading test data from assets/test_calendar_records.json');
        // テストアセットがロードされていることを示すフラグを設定
        _isUsingTestAsset = true;
        final testAssetRecords = _parseAndMergeRecords(testAssetContents);
        finalRecords.addAll(testAssetRecords);
      }
      return CalendarRecords(recordsWithTime: finalRecords);
    } catch (e) {
      // エラーが発生した場合は空のレコードを返す
      print('[ERROR] loading records: $e');
      return CalendarRecords(recordsWithTime: []);
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

      // List<RecordEntry>をMap<String, List<int>>に変換してJSONで扱えるようにする
      final Map<String, List<int>> jsonEncodableMap = {};
      records.recordsWithTime.forEach((entry) {
        final key = entry.dateTime.toIso8601String();
        jsonEncodableMap.update(key, (existingIds) => (existingIds + [entry.itemId]).toSet().toList(),
            ifAbsent: () => [entry.itemId]);
      });

      final jsonString = jsonEncode(jsonEncodableMap);
      await file.writeAsString(jsonString);
    } catch (e) {
      print('Error saving records: $e');
    }
  }
}
