import 'package:flutter/material.dart';

class LanguageSettings {
  final Locale? selectedLocale;

  const LanguageSettings({
    this.selectedLocale,
  });

  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('ja'),
    Locale('zh'),
    Locale('zh', 'TW'),
    Locale('ko'),
    Locale('fr'),
    Locale('de'),
    Locale('es'),
    Locale('hi'),
    Locale('id'),
    Locale('pt'),
    Locale('ar'),
  ];

  // 端末の言語がサポートされているかチェックし、適切なデフォルト言語を返す
  static Locale getDefaultLocale(Locale deviceLocale) {
    // 完全一致をチェック（例: zh_TW）
    for (final supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == deviceLocale.languageCode &&
          supportedLocale.countryCode == deviceLocale.countryCode) {
        return supportedLocale;
      }
    }
    
    // 言語コードのみの一致をチェック（例: zh）
    for (final supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == deviceLocale.languageCode &&
          supportedLocale.countryCode == null) {
        return supportedLocale;
      }
    }
    
    // サポートされていない場合は英語をデフォルトに
    return const Locale('en');
  }

  static String getLanguageName(Locale locale, String Function(String) localizations) {
    switch (locale.toString()) {
      case 'en':
        return localizations('english');
      case 'ja':
        return localizations('japanese');
      case 'zh':
        return localizations('chineseSimplified');
      case 'zh_TW':
        return localizations('chineseTraditional');
      case 'ko':
        return localizations('korean');
      default:
        return locale.toString();
    }
  }

  LanguageSettings copyWith({
    Locale? selectedLocale,
  }) {
    return LanguageSettings(
      selectedLocale: selectedLocale ?? this.selectedLocale,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'selectedLocale': selectedLocale?.toString(),
    };
  }

  static LanguageSettings fromJson(Map<String, dynamic> json) {
    final localeString = json['selectedLocale'] as String?;
    Locale? locale;
    if (localeString != null) {
      final parts = localeString.split('_');
      if (parts.length == 1) {
        locale = Locale(parts[0]);
      } else if (parts.length == 2) {
        locale = Locale(parts[0], parts[1]);
      }
    }
    
    return LanguageSettings(
      selectedLocale: locale,
    );
  }
}