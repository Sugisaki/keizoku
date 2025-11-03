import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; // For date formatting
import '../../models/calendar_records.dart';
import '../records_repository.dart';

// Firestore records metadata
class FirestoreRecordsMetadata {
  final DateTime lastUpdated;

  FirestoreRecordsMetadata({required this.lastUpdated});

  Map<String, dynamic> toJson() {
    return {
      'lastUpdated': FieldValue.serverTimestamp(), // Use server timestamp for Firestore
    };
  }

  factory FirestoreRecordsMetadata.fromFirestore(Map<String, dynamic> json) {
    return FirestoreRecordsMetadata(
      lastUpdated: (json['lastUpdated'] as Timestamp).toDate(),
    );
  }
}

class FirestoreRecordsRepository implements RecordsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  FirestoreRecordsRepository();

  String? get uid => FirebaseAuth.instance.currentUser?.uid;

  // Load records with timestamp
  Future<({CalendarRecords records, DateTime? lastUpdated})> loadRecordsWithTimestamp() async {
    if (uid == null) {
      print('No user logged in. Returning empty records.');
      return (records: CalendarRecords(recordsMap: {}), lastUpdated: null);
    }
    try {
      final recordsCollectionRef = _firestore.collection('users').doc(uid).collection('records');
      final metadataDocRef = _firestore.collection('users').doc(uid).collection('metadata').doc('records');

      final recordsQuerySnapshot = await recordsCollectionRef.get();
      final metadataDocSnapshot = await metadataDocRef.get();

      DateTime? firestoreLastUpdated;
      if (metadataDocSnapshot.exists && metadataDocSnapshot.data() != null) {
        firestoreLastUpdated = FirestoreRecordsMetadata.fromFirestore(metadataDocSnapshot.data()!).lastUpdated;
      }

      final Map<String, dynamic> loadedRecordsMap = {};
      for (final doc in recordsQuerySnapshot.docs) {
        final data = doc.data();
        if (data.containsKey('itemIds') && data['itemIds'] is List) {
          loadedRecordsMap[doc.id] = List<int>.from(data['itemIds']);
        }
      }

      return (records: CalendarRecords.fromJson(loadedRecordsMap), lastUpdated: firestoreLastUpdated);
    } catch (e) {
      print('Error loading records from Firestore: $e');
      return (records: CalendarRecords(recordsMap: {}), lastUpdated: null);
    }
  }

  @override
  Future<CalendarRecords> loadRecords() async {
    final result = await loadRecordsWithTimestamp();
    return result.records;
  }

  @override
  Future<void> saveRecords(CalendarRecords records) async {
    if (uid == null) {
      print('No user logged in. Not saving records to Firestore.');
      return;
    }
    try {
      final batch = _firestore.batch();
      final recordsCollectionRef = _firestore.collection('users').doc(uid).collection('records');
      final metadataDocRef = _firestore.collection('users').doc(uid).collection('metadata').doc('records');

      // Delete all existing records
      final existingRecords = await recordsCollectionRef.get();
      for (final doc in existingRecords.docs) {
        batch.delete(doc.reference);
      }

      // Add all current records
      final recordsJson = records.toJson();
      for (final entry in recordsJson.entries) {
        final dateTimeString = entry.key;
        final itemIds = entry.value;
        batch.set(recordsCollectionRef.doc(dateTimeString), {'itemIds': itemIds});
      }

      // Update metadata timestamp
      batch.set(metadataDocRef, FirestoreRecordsMetadata(lastUpdated: DateTime.now()).toJson());

      await batch.commit();
    } catch (e) {
      print('Error saving records to Firestore: $e');
      rethrow;
    }
  }
}
