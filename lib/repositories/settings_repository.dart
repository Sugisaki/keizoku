import '../models/calendar_settings.dart';

// 設定データの永続化に関する操作を定義する抽象クラス（インターフェース）
abstract class SettingsRepository {
  // 設定を読み込む
  Future<CalendarSettings> loadSettings();

  // 設定を保存する
  Future<void> saveSettings(CalendarSettings settings);
}
