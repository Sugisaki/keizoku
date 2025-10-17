import 'package:shared_preferences/shared_preferences.dart';
import '../../constants/color_constants.dart';
import '../../models/calendar_settings.dart';
import '../settings_repository.dart';

// SharedPreferencesを使用して設定を永続化するクラス
class LocalSettingsRepository implements SettingsRepository {
  static const String _startOfWeekKey = 'startOfWeek';

  @override
  Future<CalendarSettings> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final startOfWeek = prefs.getInt(_startOfWeekKey) ?? ColorConstants.defaultStartOfWeek;

    // 現在、永続化するのは週の開始曜日のみ
    return CalendarSettings(startOfWeek: startOfWeek);
  }

  @override
  Future<void> saveSettings(CalendarSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_startOfWeekKey, settings.startOfWeek);
  }
}
