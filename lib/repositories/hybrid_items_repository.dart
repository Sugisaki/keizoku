import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart'; // For kDebugMode
import '../models/calendar_item.dart';
import 'items_repository.dart';
import 'local/local_items_repository.dart';
import 'firestore/firestore_items_repository.dart';

class HybridItemsRepository implements ItemsRepository {
  final LocalItemsRepository _localRepository;
  final FirestoreItemsRepository _firestoreRepository;

  HybridItemsRepository({
    required LocalItemsRepository localRepository,
    required FirestoreItemsRepository firestoreRepository,
  })  : _localRepository = localRepository,
        _firestoreRepository = firestoreRepository;

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  @override
  Future<List<CalendarItem>> loadItems() async {
    final result = await loadItemsWithTimestamp();
    return result.items;
  }

  /// 同期処理付きで事柄と最終更新時刻を読み込む
  Future<({List<CalendarItem> items, DateTime? lastUpdated})> loadItemsWithTimestamp() async {
    final user = FirebaseAuth.instance.currentUser;
    
    if (user == null) {
      // Googleサインインしていない場合はローカルのみ
      final localData = await _localRepository.loadItemsWithTimestamp();
      return (items: localData.items, lastUpdated: localData.lastUpdated);
    }

    try {
      // ローカルとFirestoreの両方からデータを取得
      final localData = await _localRepository.loadItemsWithTimestamp();
      final firestoreResult = await _firestoreRepository.loadItemsWithTimestamp();

      final localItems = localData.items;
      final localLastUpdated = localData.lastUpdated;
      final firestoreItems = firestoreResult.items;
      final firestoreLastUpdated = firestoreResult.lastUpdated;

      print('DEBUG: HybridItemsRepository sync - Local: ${localItems.length} items, updated: $localLastUpdated');
      print('DEBUG: HybridItemsRepository sync - Firestore: ${firestoreItems.length} items, updated: $firestoreLastUpdated');

      // 同期ロジック
      if (firestoreLastUpdated == null) {
        // Firestoreにメタデータがない場合：ローカル→Firestore
        print('DEBUG: No Firestore metadata, uploading local items');
        if (localItems.isNotEmpty) {
          await _firestoreRepository.saveItems(localItems);
        }
        return (items: localItems, lastUpdated: localLastUpdated);
      } else if (localLastUpdated.isBefore(firestoreLastUpdated)) {
        // Firestoreの方が新しい場合：Firestore→ローカル
        print('DEBUG: Firestore data is newer, downloading to local');
        await _localRepository.saveItems(firestoreItems);
        return firestoreResult;
      } else if (localLastUpdated.isAfter(firestoreLastUpdated)) {
        // ローカルの方が新しい場合：マージしてFirestoreにアップロード
        print('DEBUG: Local data is newer, merging and uploading');
        final mergedItems = _mergeItems(firestoreItems, localItems);
        await _localRepository.saveItems(mergedItems);
        await _firestoreRepository.saveItems(mergedItems);
        return (items: mergedItems, lastUpdated: DateTime.now());
      } else {
        // 同じ更新時刻の場合：何もしない
        print('DEBUG: Same timestamp, no sync needed');
        return (items: localItems, lastUpdated: localLastUpdated);
      }
    } catch (e) {
      print('Error during items sync: $e');
      // エラー時はローカルデータを使用
      final localData = await _localRepository.loadItemsWithTimestamp();
      return (items: localData.items, lastUpdated: localData.lastUpdated);
    }
  }

  /// 事柄をマージする（Firestoreベース + ローカルのitem単位での上書き）
  List<CalendarItem> _mergeItems(List<CalendarItem> firestoreItems, List<CalendarItem> localItems) {
    // FirestoreのitemsをベースとしてMapに変換
    final Map<int, CalendarItem> mergedMap = {};
    
    // Firestoreの事柄を追加
    for (final item in firestoreItems) {
      mergedMap[item.id] = item;
    }

    // ローカルの事柄で上書き（item単位）
    for (final item in localItems) {
      mergedMap[item.id] = item;
    }

    // リストに戻して、orderでソート
    final mergedList = mergedMap.values.toList();
    mergedList.sort((a, b) => a.order.compareTo(b.order));
    
    return mergedList;
  }

  @override
  Future<void> saveItems(List<CalendarItem> items) async {
    print('DEBUG: HybridItemsRepository.saveItems() called with ${items.length} items');
    // Always save to local file
    await _localRepository.saveItems(items);

    if (_uid != null) {
      print('DEBUG: HybridItemsRepository.saveItems() calling FirestoreItemsRepository.saveItems()');
      // If logged in, also save to Firestore
      await _firestoreRepository.saveItems(items);
    } else {
      print('DEBUG: HybridItemsRepository.saveItems() - user not logged in, skipping Firestore save');
    }
    print('DEBUG: HybridItemsRepository.saveItems() completed');
  }
}