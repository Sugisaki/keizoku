import '../models/language_settings.dart';

abstract class LanguageRepository {
  Future<LanguageSettings> loadLanguageSettings();
  Future<void> saveLanguageSettings(LanguageSettings settings);
}