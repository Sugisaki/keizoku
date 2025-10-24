import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import '../../constants/color_constants.dart';
import '../../models/calendar_item.dart';
import '../items_repository.dart';

// JSONファイルを使用して事柄リストを永続化するクラス
class LocalItemsRepository implements ItemsRepository {
  static const String _fileName = 'calendar_items.json';
  bool _isUsingTestAsset = false;
  bool get isUsingTestAsset => _isUsingTestAsset;

  Future<File> get _localFile async {
    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path;
    return File('$path/$_fileName');
  }

  // 開発環境のテストファイルをアセットから読み込む（デバッグモードのみ）
  Future<String?> _loadTestAsset() async {
    if (!kDebugMode) return null;
    try {
      final contents = await rootBundle.loadString('assets/test_calendar_items.json');
      return contents;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<CalendarItem>> loadItems() async {
    try {
      final testAssetContents = await _loadTestAsset();
      if (testAssetContents != null) {
        print('Loading test data from assets/test_calendar_items.json');
        _isUsingTestAsset = true;
        final List<dynamic> jsonList = jsonDecode(testAssetContents);
        return jsonList.map((json) => CalendarItem.fromJson(json)).toList();
      }

      final file = await _localFile;
      if (!await file.exists()) {
         // ファイルが存在しない場合は、8つのデフォルト事柄を生成して返す
         final defaultItems = List.generate(8, (i) {
          final colorHex = ColorConstants.colorKeys[(i + 1 - 1) % ColorConstants.colorKeys.length];
          if (i == 0) {
            // id=1の事柄のみ有効で名前は「新規項目1」
            return CalendarItem(
              id: i + 1, 
              name: '新規項目${i + 1}', 
              isEnabled: true, 
              order: 1,
              itemColorHex: colorHex,
            );
          } else {
            // その他の事柄は無効で名前は「新規項目+id」
            return CalendarItem(
              id: i + 1, 
              name: '新規項目${i + 1}', 
              isEnabled: false, 
              order: i + 1,
              itemColorHex: colorHex,
            );
          }
        });
        // デフォルトデータをファイルに保存しておく
        await saveItems(defaultItems);
        return defaultItems;
      }

      final contents = await file.readAsString();
      final List<dynamic> jsonList = jsonDecode(contents);

      return jsonList.map((json) => CalendarItem.fromJson(json)).toList();
    } catch (e) {
      print('Error loading items: $e');
      // エラー時もデフォルトデータを返す
       return List.generate(8, (i) {
        final colorHex = ColorConstants.colorKeys[(i + 1 - 1) % ColorConstants.colorKeys.length];
        if (i == 0) {
          // id=1の事柄のみ有効で名前は「新規項目1」
          return CalendarItem(
            id: i + 1, 
            name: '新規項目${i + 1}', 
            isEnabled: true, 
            order: 1,
            itemColorHex: colorHex,
          );
        } else {
          // その他の事柄は無効で名前は「新規項目+id」
          return CalendarItem(
            id: i + 1, 
            name: '新規項目${i + 1}', 
            isEnabled: false, 
            order: i + 1,
            itemColorHex: colorHex,
          );
        }
      });
    }
  }

  @override
  Future<void> saveItems(List<CalendarItem> items) async {
    if (_isUsingTestAsset) {
      print('[WARN] テストファイルがあるので保存処理はしていません');
      return;
    }
    try {
      final file = await _localFile;
      final jsonList = items.map((item) => item.toJson()).toList();
      final jsonString = jsonEncode(jsonList);
      await file.writeAsString(jsonString);
    } catch (e) {
      print('Error saving items: $e');
    }
  }
}
