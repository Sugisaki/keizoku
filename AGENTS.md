# アプリケーション仕様書

このドキュメントは、現在のカレンダーアプリケーションの技術的な仕様をまとめたものです。

## 1. 全体アーキテクチャ

このアプリケーションは、UI、状態管理、データ操作の関心を分離する設計を採用しています。

-   **UI (View) 層:** Flutterのウィジェットで構築された画面です。
-   **状態管理 (State Management) 層:** `provider`パッケージの`ChangeNotifier`を利用して、UIの状態を一元管理します。
-   **データ (Repository) 層:** 「リポジトリパターン」を採用し、データの永続化ロジックを抽象化しています。これにより、将来的にローカル保存からクラウド保存への切り替えが容易になります。

## 2. データモデル (`lib/models/`)

アプリケーション内で使用される主要なデータ構造です。

-   `CalendarSettings`: カレンダーの表示設定（週の開始曜日、カラーパレットなど）を管理します。
-   `CalendarItem`: 記録する「事柄」の定義（ID, 名称, 色, アイコン）です。
-   `CalendarRecords`: 日付(`DateTime`)と、その日に記録された事柄IDのリスト(`List<int>`)を紐付けるマップを管理します。

## 3. 永続化 (`lib/repositories/`)

データのリポジトリパターンに基づいた実装です。

-   **インターフェース:**
    -   `SettingsRepository`: 設定の保存・読み込み操作を定義します。
    -   `RecordsRepository`: 記録の保存・読み込み操作を定義します。
-   **ローカル実装 (`lib/repositories/local/`):**
    -   `LocalSettingsRepository`: `shared_preferences` を使用して設定データをデバイスに保存します。
    -   `LocalRecordsRepository`: `path_provider` を使用して取得したパスに、記録データをJSONファイルとして保存します。

## 4. 状態管理 (`lib/providers/`)

-   `CalendarProvider`: `ChangeNotifier`を継承したクラス。リポジトリを通じてデータをロード・セーブし、UIの更新を`notifyListeners()`で通知します。アプリケーション全体の状態（設定、事柄リスト、記録）を保持します。

## 5. UIコンポーネント (`lib/widgets/`)

-   `CalendarWidget`:
    -   カレンダー全体の表示を担うメインウィジェットです。
    -   縦スクロールが可能で、最も古い記録がある月まで遡ることができます。
    -   初期表示では、今月の最終週が一番下に表示されます。
    -   画面上部に表示されている週に応じて、AppBarのタイトル（年月）が動的に更新されます。
-   `WeekRowWidget`: 1週間分の行を描画します。7日分の`DayCellWidget`と、その週に記録があった事柄を示すラインで構成されます。
-   `DayCellWidget`: 1日分のセルを描画します。日付、および記録された事柄のアイコンを3x3のグリッドで表示します。スクロール中は表示月以外の日の文字色が通常色になります。

## 6. 画面 (`lib/screens/` & `lib/main.dart`)

-   `MyHomePage`: カレンダー画面のメインとなるScaffoldです。`CalendarWidget`を表示し、AppBarやフローティングアクションボタンを配置します。
-   `SettingsScreen`: 週の開始曜日などを設定する画面です。
-   `AddRecordDialog`: その日の事柄を記録するためのモーダルダイアログです。

## 7. 高さ制限

-   `main.dart`にて、`MediaQuery`で画面サイズを取得し、1週あたりの高さを動的に計算します。
-   画面の縦サイズの半分を超えない、最大の行数（整数）を算出し、その高さでカレンダー領域を制限しています。
