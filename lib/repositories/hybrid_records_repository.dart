import 'package:intl/intl.dart';
import '../models/calendar_records.dart';
import 'records_repository.dart';
import 'local/local_records_repository.dart';
import 'firestore/firestore_records_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HybridRecordsRepository implements RecordsRepository {
  final LocalRecordsRepository _localRepository;
  final FirestoreRecordsRepository _firestoreRepository;
  final FirebaseAuth _firebaseAuth;

  HybridRecordsRepository({
    required LocalRecordsRepository localRepository,
    required FirestoreRecordsRepository firestoreRepository,
    required FirebaseAuth firebaseAuth,
  })  : _localRepository = localRepository,
        _firestoreRepository = firestoreRepository,
        _firebaseAuth = firebaseAuth;

  /// 同期してレコードを読み込む
  @override
  Future<CalendarRecords> loadRecords() async {
    final result = await loadRecordsWithTimestamp();
    return result.records;
  }

  /// 同期処理付きでレコードと最終更新時刻を読み込む
  @override
  Future<({CalendarRecords records, DateTime? lastUpdated})> loadRecordsWithTimestamp() async {
    final user = _firebaseAuth.currentUser;
    
    if (user == null) {
      // Googleサインインしていない場合はローカルのみ
      return await _localRepository.loadRecordsWithTimestamp();
    }

    try {
      // ローカルとFirestoreの両方からデータを取得
      final localResult = await _localRepository.loadRecordsWithTimestamp();
      final firestoreResult = await _firestoreRepository.loadRecordsWithTimestamp();

      final localRecords = localResult.records;
      final localLastUpdated = localResult.lastUpdated;
      final firestoreRecords = firestoreResult.records;
      final firestoreLastUpdated = firestoreResult.lastUpdated;

      // 同期ロジック
      if (firestoreLastUpdated == null) {
        // Firestoreにメタデータがない場合：ローカル→Firestore
        if (localRecords.recordsWithTime.isNotEmpty) {
          await _firestoreRepository.saveRecords(localRecords);
        }
        return localResult;
      } else if (localLastUpdated == null || localLastUpdated.isBefore(firestoreLastUpdated)) {
        // Firestoreの方が新しい場合：Firestore→ローカル
        await _localRepository.saveRecords(firestoreRecords);
        return firestoreResult;
      } else if (localLastUpdated.isAfter(firestoreLastUpdated)) {
        // ローカルの方が新しい場合：マージしてFirestoreにアップロード
        final mergedRecords = _mergeRecords(firestoreRecords, localRecords);
        await _localRepository.saveRecords(mergedRecords);
        await _firestoreRepository.saveRecords(mergedRecords);
        return (records: mergedRecords, lastUpdated: DateTime.now());
      } else {
        // 同じ更新時刻の場合：何もしない
        return localResult;
      }
    } catch (e) {
      print('Error during records sync: $e');
      // エラー時はローカルデータを使用
      return await _localRepository.loadRecordsWithTimestamp();
    }
  }

  /// レコードをマージする（Firestoreベース + ローカルの時刻単位での上書き）
  CalendarRecords _mergeRecords(CalendarRecords firestoreRecords, CalendarRecords localRecords) {
    // Firestoreの記録をベースとしてMapに変換
    final Map<String, List<int>> mergedMap = {};
    
    // Firestoreの記録を追加
    for (final entry in firestoreRecords.recordsWithTime) {
      final key = _formatDateTimeLocal(entry.dateTime);
      mergedMap[key] = mergedMap[key] ?? [];
      if (!mergedMap[key]!.contains(entry.itemId)) {
        mergedMap[key]!.add(entry.itemId);
      }
    }

    // ローカルの記録で上書き（時刻単位）
    for (final entry in localRecords.recordsWithTime) {
      final key = _formatDateTimeLocal(entry.dateTime);
      // ローカルの記録で完全に上書き（その時刻の記録を置き換え）
      final localRecordsForDateTime = localRecords.recordsWithTime
          .where((e) => _formatDateTimeLocal(e.dateTime) == key)
          .map((e) => e.itemId)
          .toList();
      mergedMap[key] = localRecordsForDateTime;
    }

    return CalendarRecords.fromJson(mergedMap);
  }

  /// 日時をローカルタイムでフォーマットする（CalendarRecordsと同じ形式）
  String _formatDateTimeLocal(DateTime dateTime) {
    // ミリ秒以下が0の場合は小数点以下を省略し、そうでない場合はミリ秒まで表示する
    return dateTime.millisecond == 0 && dateTime.microsecond == 0
        ? DateFormat("yyyy-MM-ddTHH:mm:ss").format(dateTime)
        : DateFormat("yyyy-MM-ddTHH:mm:ss.SSS").format(dateTime);
  }

  @override
  Future<void> saveRecords(CalendarRecords records) async {
    print('DEBUG: HybridRecordsRepository.saveRecords() called');
    // 常にローカルに保存
    await _localRepository.saveRecords(records);
    
    // Googleサインインしている場合はFirestoreにも保存
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      try {
        print('DEBUG: HybridRecordsRepository.saveRecords() calling FirestoreRecordsRepository.saveRecords()');
        await _firestoreRepository.saveRecords(records);
        print('DEBUG: HybridRecordsRepository.saveRecords() completed Firestore save');
      } catch (e) {
        print('Error saving records to Firestore: $e');
        // Firestoreへの保存が失敗してもローカルは保存済みなので続行
      }
    } else {
      print('DEBUG: HybridRecordsRepository.saveRecords() - user not logged in, skipping Firestore save');
    }
    print('DEBUG: HybridRecordsRepository.saveRecords() completed');
  }

  @override
  Future<void> deleteFirestoreRecords() async {
    print('DEBUG: HybridRecordsRepository.deleteAllRecords() called');

    final user = _firebaseAuth.currentUser;
    if (user != null) {
      await _firestoreRepository.deleteFirestoreRecords();
    }
    print('DEBUG: HybridRecordsRepository.deleteAllRecords() completed');
  }
}