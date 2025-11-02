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
    final localData = await _localRepository.loadItemsWithTimestamp();
    List<CalendarItem> itemsToReturn = localData.items;

    if (_uid != null) {
      final firestoreResult = await _firestoreRepository.loadItemsWithTimestamp();
      final firestoreItems = firestoreResult.items;
      final firestoreLastUpdated = firestoreResult.lastUpdated;

      // Determine which data is newer
      if (firestoreLastUpdated != null && firestoreLastUpdated.isAfter(localData.lastUpdated)) {
        // Firestore data is newer, use it and update local
        if (kDebugMode) {
          print('Firestore data is newer. Using Firestore data and updating local.');
        }
        itemsToReturn = firestoreItems;
        await _localRepository.saveItems(firestoreItems);
      } else if (localData.items.isNotEmpty && (firestoreLastUpdated == null || localData.lastUpdated.isAtSameMomentAs(firestoreLastUpdated) || localData.lastUpdated.isAfter(firestoreLastUpdated))) {
        // Local data is newer or Firestore is empty, use local data and update Firestore
        if (kDebugMode) {
          print('Local data is newer or Firestore is empty. Using local data and updating Firestore.');
        }
        itemsToReturn = localData.items;
        await _firestoreRepository.saveItems(localData.items);
      } else if (firestoreItems.isNotEmpty) {
        // Fallback: if Firestore has items and local doesn't, use Firestore
        if (kDebugMode) {
          print('Firestore has items, local does not. Using Firestore data.');
        }
        itemsToReturn = firestoreItems;
        await _localRepository.saveItems(firestoreItems);
      }
    } else {
      // Not logged in, just return local items
      if (kDebugMode) {
        print('Not logged in. Using local data.');
      }
    }
    return itemsToReturn;
  }

  @override
  Future<void> saveItems(List<CalendarItem> items) async {
    // Always save to local file
    await _localRepository.saveItems(items);

    if (_uid != null) {
      // If logged in, also save to Firestore
      await _firestoreRepository.saveItems(items);
    }
  }
}