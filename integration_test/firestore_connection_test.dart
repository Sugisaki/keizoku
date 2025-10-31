import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  group('Firestore Real Connection Test', () {
    const testCollection = 'integration_test_data';
    const testDocId = 'connection_check_id';

    // 🌟 テストで書き込むデータ（検証のために使用）
    final Map<String, dynamic> initialTestData = {
      'test_string': 'Integration Test Value - Date: ${DateTime.now().toIso8601String()}',
      'test_number': 12345,
      'is_active': true,
    };

    setUpAll(() async {
      // Firebaseの初期化
      await Firebase.initializeApp();
      
      // クリーンアップ: テストドキュメントを削除
      //await FirebaseFirestore.instance.collection(testCollection).doc(testDocId).delete();
    });

    // 📌 テスト後のクリーンアップを確実にするための tearDownAll も追加できます
    /*
    tearDownAll(() async {
      await FirebaseFirestore.instance.collection(testCollection).doc(testDocId).delete();
    });
    */

    test('実環境のFirestoreへの書き込みと読み込み、値の検証', () async {
      final firestore = FirebaseFirestore.instance;

      // ----------------- 書き込みテスト -----------------
      await firestore.collection(testCollection).doc(testDocId).set(initialTestData);
      print('✅ 書き込み成功');

      // ----------------- 読み込みテスト -----------------
      final docSnapshot = await firestore.collection(testCollection).doc(testDocId).get();

      // ----------------- 検証 (Assert) -----------------
      
      // 1. ドキュメントが存在することを確認
      expect(docSnapshot.exists, isTrue);
      
      // 2. 読み込んだデータを取り出す
      final readData = docSnapshot.data();
      expect(readData, isNotNull); // データがnullでないことを確認

      // 3. 各フィールドの値が書き込んだ値と一致するかを検証
      expect(readData!['test_string'], equals(initialTestData['test_string']));
      expect(readData['test_number'], equals(initialTestData['test_number']));
      expect(readData['is_active'], equals(initialTestData['is_active']));

      print('✅ 読み込んだデータが書き込んだデータと完全に一致することを確認しました。');
    });
  });
}
