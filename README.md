# KEIZOKU

## 本番ビルド
### 本番ビルドでの問題

`integration_test`プラグインは開発時には必要ですが、本番ビルド時には以下の問題を引き起こします：
- `GeneratedPluginRegistrant.java`でのコンパイルエラー
- 「パッケージdev.flutter.plugins.integration_testは存在しません」エラー

### 解決方法
integration_testを無効化してリリースビルドを実行

1. pubspec.yamlでintegration_testをコメントアウト
```
diff --git a/pubspec.yaml b/pubspec.yaml
index 8f60c83..08ea0ef 100644
--- a/pubspec.yaml
+++ b/pubspec.yaml
@@ -47,7 +47,7 @@ dev_dependencies:
   flutter_lints: ^2.0.0
   mockito: ^5.5.1
   build_runner: ^2.4.8 # Add this line
-  # 統合テストの実行に必要
-  integration_test:
-    sdk: flutter
+  # 統合テストの実行に必要（本番ビルドでは無効化）
+  # integration_test:
+  #   sdk: flutter
```
2. 依存関係を更新 (`flutter pub get`)
3. ビルドキャッシュをクリア (`flutter clean`)
4. リリースビルド
5. ビルド後、pubspec.yamlを開発用に復元

