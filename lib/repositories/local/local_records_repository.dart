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

  Map<DateTime, List<int>> _parseAndMergeRecords(String jsonString) {
    final json = jsonDecode(jsonString) as Map<String, dynamic>;
    final Map<DateTime, List<int>> mergedRecords = {};
    json.forEach((key, value) {
      final parsedDateTime = DateTime.parse(key);
      final normalizedDate = DateTime(parsedDateTime.year, parsedDateTime.month, parsedDateTime.day);
      final ids = List<int>.from(value);

      mergedRecords.update(normalizedDate, (existingIds) => (existingIds + ids).toSet().toList(),
          ifAbsent: () => ids);
    });
    return mergedRecords;
  }

  @override
  Future<CalendarRecords> loadRecords() async {
    try {
      // 最終的にマージされるレコードのマップ
      Map<DateTime, List<int>> finalRecords = {};

      // 1. ローカルファイルからデータを読み込み
      final file = await _localFile;
      if (await file.exists()) {
        print('Loading data from local file');
        final contents = await file.readAsString();
        final localRecords = _parseAndMergeRecords(contents);
        // ローカルファイルのデータをマージ
        localRecords.forEach((date, ids) {
          finalRecords.update(date, (existingIds) => (existingIds + ids).toSet().toList(),
              ifAbsent: () => ids);
        });
      }

      // 2. 開発環境のテストアセットからデータを読み込み
      final testAssetContents = await _loadTestAsset();
      if (testAssetContents != null) {
        print('Loading test data from assets/test_calendar_records.json');
        // テストアセットがロードされていることを示すフラグを設定
        _isUsingTestAsset = true;
        final testAssetRecords = _parseAndMergeRecords(testAssetContents);
        // アセットのテストデータをマージ（最高優先度で上書き）
        testAssetRecords.forEach((date, ids) {
          finalRecords.update(
              date, (existingIds) => (existingIds + ids).toSet().toList(),
              ifAbsent: () => ids);
        });
      }
      return CalendarRecords(records: finalRecords);
    } catch (e) {
      // エラーが発生した場合は空のレコードを返す
      print('[ERROR] loading records: $e');
      return CalendarRecords(records: {});
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
