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
        final json = jsonDecode(contents) as Map<String, dynamic>;
        final localRecords = json.map((key, value) {
          // JSONのキー(String)をDateTimeに変換
          return MapEntry(DateTime.parse(key), List<int>.from(value));
        });
        // ローカルファイルのデータを追加
        finalRecords.addAll(localRecords);
      }

      // 2. 開発環境のテストアセットからデータを読み込み
      final testAssetContents = await _loadTestAsset();
      if (testAssetContents != null) {
        print('Loading test data from assets/test_calendar_records.json');
        // テストアセットがロードされていることを示すフラグを設定
        _isUsingTestAsset = true;
        final json = jsonDecode(testAssetContents) as Map<String, dynamic>;
        final testAssetRecords = json.map((key, value) {
          // JSONのキー(String)をDateTimeに変換
          return MapEntry(DateTime.parse(key), List<int>.from(value));
        });
        // アセットのテストデータを追加（最高優先度で上書き）
        finalRecords.addAll(testAssetRecords);
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
