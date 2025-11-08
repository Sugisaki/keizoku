import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/calendar_item.dart';
import '../items_repository.dart';
import '../../constants/color_constants.dart';

// Firestore items metadata
class FirestoreItemsMetadata {
  final DateTime lastUpdated;

  FirestoreItemsMetadata({required this.lastUpdated});

  Map<String, dynamic> toJson() {
    return {
      'lastUpdated': FieldValue.serverTimestamp(), // Use server timestamp for Firestore
    };
  }

  factory FirestoreItemsMetadata.fromFirestore(Map<String, dynamic> json) {
    return FirestoreItemsMetadata(
      lastUpdated: (json['lastUpdated'] as Timestamp).toDate(),
    );
  }
}

class FirestoreItemsRepository implements ItemsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  FirestoreItemsRepository();

  String? get uid => FirebaseAuth.instance.currentUser?.uid;

  // Load items with timestamp
  Future<({List<CalendarItem> items, DateTime? lastUpdated})> loadItemsWithTimestamp() async {
    if (uid == null) {
      print('No user logged in. Returning empty items list.');
      return (items: <CalendarItem>[], lastUpdated: null);
    }
    try {
      final itemsCollectionRef = _firestore.collection('users').doc(uid).collection('items');
      final metadataDocRef = _firestore.collection('users').doc(uid).collection('metadata').doc('items');

      final itemsQuerySnapshot = await itemsCollectionRef.orderBy('order').get();
      final metadataDocSnapshot = await metadataDocRef.get();

      DateTime? firestoreLastUpdated;
      if (metadataDocSnapshot.exists && metadataDocSnapshot.data() != null) {
        firestoreLastUpdated = FirestoreItemsMetadata.fromFirestore(metadataDocSnapshot.data()!).lastUpdated;
      }

      // If no items exist in Firestore, just return an empty list
      if (itemsQuerySnapshot.docs.isEmpty) {
        return (items: <CalendarItem>[], lastUpdated: firestoreLastUpdated);
      }

      return (
        items: itemsQuerySnapshot.docs.map((doc) => CalendarItem.fromJson(doc.data())).toList(),
        lastUpdated: firestoreLastUpdated,
      );
    } catch (e) {
      print('Error loading items from Firestore: $e');
      return (items: <CalendarItem>[], lastUpdated: null);
    }
  }

  @override
  Future<List<CalendarItem>> loadItems() async {
    final result = await loadItemsWithTimestamp();
    return result.items;
  }

  @override
  Future<void> saveItems(List<CalendarItem> items) async {
    print('DEBUG: FirestoreItemsRepository.saveItems() called with ${items.length} items');
    if (uid == null) {
      print('No user logged in. Not saving items to Firestore.');
      return;
    }
    try {
      final batch = _firestore.batch();
      final itemsCollectionRef = _firestore.collection('users').doc(uid).collection('items');
      final metadataDocRef = _firestore.collection('users').doc(uid).collection('metadata').doc('items');

      // Delete all existing items
      final existingItems = await itemsCollectionRef.get();
      for (final doc in existingItems.docs) {
        batch.delete(doc.reference);
      }

      // Add all current items
      for (final item in items) {
        batch.set(itemsCollectionRef.doc(item.id.toString()), item.toJson());
      }

      // Update metadata timestamp
      print('DEBUG: Updating ITEMS metadata at users/$uid/metadata/items');
      batch.set(metadataDocRef, FirestoreItemsMetadata(lastUpdated: DateTime.now()).toJson());

      await batch.commit();
    } catch (e) {
      print('Error saving items to Firestore: $e');
      rethrow;
    }
  }
}
