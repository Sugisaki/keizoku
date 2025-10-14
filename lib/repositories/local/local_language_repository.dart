import 'package:flutter/widgets.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../language_repository.dart';
import '../../models/language_settings.dart';

class LocalLanguageRepository implements LanguageRepository {
  static const String _languageKey = 'language_settings';

  @override
  Future<LanguageSettings> loadLanguageSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_languageKey);
      
      if (jsonString != null) {
        final jsonMap = json.decode(jsonString) as Map<String, dynamic>;
        return LanguageSettings.fromJson(jsonMap);
      }
      
      final deviceLocale = WidgetsBinding.instance.platformDispatcher.locale;
      final defaultLocale = LanguageSettings.getDefaultLocale(deviceLocale);
      return LanguageSettings(selectedLocale: defaultLocale);
    } catch (e) {
      print('Error loading language settings: $e');
      return const LanguageSettings();
    }
  }

  @override
  Future<void> saveLanguageSettings(LanguageSettings settings) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = json.encode(settings.toJson());
      await prefs.setString(_languageKey, jsonString);
      print('Language settings saved: $jsonString');
    } catch (e) {
      print('Error saving language settings: $e');
    }
  }
}