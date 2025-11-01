import 'package:firebase_auth/firebase_auth.dart'; // Ensure this is imported
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

  // Add a getter for uid that always reflects the current FirebaseAuth state
  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  @override
  Future<List<CalendarItem>> loadItems() async {
    // Always try to load from local first
    List<CalendarItem> localItems = await _localRepository.loadItems();

    if (_uid != null) {
      // If logged in, try to load from Firestore
      List<CalendarItem> firestoreItems = await _firestoreRepository.loadItems();

      if (firestoreItems.isNotEmpty) {
        // If Firestore has data, use it.
        // This assumes Firestore is the source of truth when logged in.
        // A more complex merge strategy might be needed depending on requirements.
        // For now, if Firestore has items, we'll use them.
        // If local has items but Firestore doesn't, add them to Firestore.
        if (localItems.isNotEmpty) {
          // If both have data, we need a strategy. For simplicity, let's say Firestore wins.
          // Or, if local has items not in Firestore, add them to Firestore.
          // For this task, let's assume Firestore is the primary source when logged in.
          // If local has items and firestore is empty, upload local to firestore.
          if (firestoreItems.isEmpty) {
            if (kDebugMode) {
              print('Firestore is empty for logged-in user, uploading local items.');
            }
            await _firestoreRepository.saveItems(localItems);
            return localItems; // Return local items after uploading them
          }
        }
        return firestoreItems;
      } else {
        // If Firestore is empty, but local has items, upload local items to Firestore
        if (localItems.isNotEmpty) {
          if (kDebugMode) {
            print('Firestore is empty for logged-in user, uploading local items.');
          }
          await _firestoreRepository.saveItems(localItems);
        }
      }
    }
    // If not logged in, or Firestore is empty and local is used, return local items
    return localItems;
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