import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import '../../constants/color_constants.dart';
import '../../models/calendar_item.dart';
import '../items_repository.dart';

// Hold items and timestamp
class LocalItemsData {
  final List<CalendarItem> items;
  final DateTime lastUpdated;

  LocalItemsData({required this.items, required this.lastUpdated});

  Map<String, dynamic> toJson() {
    return {
      'items': items.map((item) => item.toJson()).toList(),
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  factory LocalItemsData.fromJson(Map<String, dynamic> json) {
    return LocalItemsData(
      items: (json['items'] as List).map((i) => CalendarItem.fromJson(i)).toList(),
      lastUpdated: DateTime.parse(json['lastUpdated']),
    );
  }
}

class LocalItemsRepository implements ItemsRepository {
  static const String _fileName = 'calendar_items.json';
  bool _isUsingTestAsset = false;
  bool get isUsingTestAsset => _isUsingTestAsset;

  Future<File> get _localFile async {
    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path;
    return File('$path/$_fileName');
  }

  Future<String?> _loadTestAsset() async {
    if (!kDebugMode) return null;
    try {
      final contents = await rootBundle.loadString('assets/test_calendar_items.json');
      return contents;
    } catch (e) {
      return null;
    }
  }

  // loadItems to return LocalItemsData
  Future<LocalItemsData> loadItemsWithTimestamp() async {
    try {
      final testAssetContents = await _loadTestAsset();
      if (testAssetContents != null) {
        print('Loading test data from assets/test_calendar_items.json');
        _isUsingTestAsset = true;
        final List<dynamic> jsonList = jsonDecode(testAssetContents);
        return LocalItemsData(
          items: jsonList.map((json) => CalendarItem.fromJson(json)).toList(),
          lastUpdated: DateTime(2000), // テストアセット使用時も古い日付でFirestore同期を優先
        );
      }

      final file = await _localFile;
      if (!await file.exists()) {
        final defaultItems = _generateDefaultItems();
        // 初期設定時は古い日付を設定してFirestoreからの同期を優先
        final defaultData = LocalItemsData(items: defaultItems, lastUpdated: DateTime(2000));
        await saveItemsWithTimestamp(defaultData); // Save with timestamp
        return defaultData;
      }

      final contents = await file.readAsString();
      final decodedContents = jsonDecode(contents);

      if (decodedContents is List) {
        // Old format: top-level is a list of items
        print('Loading old format items from local file.');
        return LocalItemsData(
          items: decodedContents.map((json) => CalendarItem.fromJson(json)).toList(),
          lastUpdated: DateTime(2000), // 古い日付を設定してFirestoreからの同期を優先
        );
      } else if (decodedContents is Map<String, dynamic>) {
        // New format: top-level is a map with 'items' and 'lastUpdated'
        print('Loading new format items from local file.');
        return LocalItemsData.fromJson(decodedContents);
      } else {
        print('Unknown format for local items file. Returning default items.');
        final defaultItems = _generateDefaultItems();
        // 初期設定時は古い日付を設定してFirestoreからの同期を優先
        return LocalItemsData(items: defaultItems, lastUpdated: DateTime(2000));
      }
    } catch (e) {
      print('Error loading items: $e');
      final defaultItems = _generateDefaultItems();
      // エラー時も古い日付を設定してFirestoreからの同期を優先
      return LocalItemsData(items: defaultItems, lastUpdated: DateTime(2000));
    }
  }

  // Helper to generate default items
  List<CalendarItem> _generateDefaultItems() {
    return List.generate(8, (i) {
      final colorHex = ColorConstants.colorKeys[(i + 1 - 1) % ColorConstants.colorKeys.length];
      return CalendarItem(
        id: i + 1,
        name: '新規項目${i + 1}',
        isEnabled: i == 0, // Only first item enabled by default
        order: i + 1,
        itemColorHex: colorHex,
      );
    });
  }

  @override
  Future<List<CalendarItem>> loadItems() async {
    final data = await loadItemsWithTimestamp();
    return data.items;
  }

  // saveItems to accept LocalItemsData
  Future<void> saveItemsWithTimestamp(LocalItemsData data) async {
    if (_isUsingTestAsset) {
      print('[WARN] テストファイルがあるので保存処理はしていません');
      return;
    }
    try {
      final file = await _localFile;
      final jsonString = jsonEncode(data.toJson());
      await file.writeAsString(jsonString);
    } catch (e) {
      print('Error saving items: $e');
    }
  }

  @override
  Future<void> saveItems(List<CalendarItem> items) async {
    final data = LocalItemsData(items: items, lastUpdated: DateTime.now());
    await saveItemsWithTimestamp(data);
  }

  @override
  Future<void> deleteFirestoreItems() async {
    try {
      final file = await _localFile;
      if (await file.exists()) {
        await file.delete();
        print('Local items file deleted.');
      }
    } catch (e) {
      print('Error deleting local items file: $e');
      rethrow;
    }
  }
}
