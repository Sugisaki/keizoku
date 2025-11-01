import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/calendar_item.dart';
import '../items_repository.dart';
import '../../constants/color_constants.dart'; // Add this import

class FirestoreItemsRepository implements ItemsRepository {
  // Remove uid from here. It will be accessed dynamically.
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  FirestoreItemsRepository(); // Remove uid from constructor

  String? get uid => FirebaseAuth.instance.currentUser?.uid;

  @override
  Future<List<CalendarItem>> loadItems() async {
    if (uid == null) { // Check if uid is null
      print('No user logged in. Returning empty items list.');
      return [];
    }
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('items')
          .orderBy('order') // Order by the 'order' field
          .get();

      if (querySnapshot.docs.isEmpty) {
        // If no items exist in Firestore, generate default items and save them
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
        // Save default items to Firestore
        await saveItems(defaultItems);
        return defaultItems;
      }

      return querySnapshot.docs.map((doc) => CalendarItem.fromJson(doc.data())).toList();
    } catch (e) {
      print('Error loading items from Firestore: $e');
      return []; // Return empty list on error
    }
  }

  @override
  Future<void> saveItems(List<CalendarItem> items) async {
    if (uid == null) { // Check if uid is null
      print('No user logged in. Not saving items to Firestore.');
      return;
    }
    try {
      final batch = _firestore.batch();
      final collectionRef = _firestore.collection('users').doc(uid).collection('items');

      // First, delete all existing items for this user to ensure a clean sync
      // This approach simplifies handling deletions and reordering.
      final existingItems = await collectionRef.get();
      for (final doc in existingItems.docs) {
        batch.delete(doc.reference);
      }

      // Then, add all current items
      for (final item in items) {
        batch.set(collectionRef.doc(item.id.toString()), item.toJson());
      }

      await batch.commit();
    } catch (e) {
      print('Error saving items to Firestore: $e');
      rethrow;
    }
  }
}
