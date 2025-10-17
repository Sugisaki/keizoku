import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../models/calendar_item.dart';
import '../models/language_settings.dart';
import '../providers/calendar_provider.dart';
import 'edit_item_screen.dart';

// 設定画面のUI
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Providerから現在の状態を取得し、変更を監視
    final provider = context.watch<CalendarProvider>();
    final currentStartOfWeek = provider.settings.startOfWeek;
    final items = provider.items;
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.settings),
      ),
      body: ListView(
        children: <Widget>[
          // 週の開始曜日設定
          ListTile(
            title: Text(localizations.weekStartsOn),
            subtitle: Text(currentStartOfWeek == DateTime.sunday ? localizations.sunday : localizations.monday),
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text(localizations.weekStartsOn),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        RadioListTile<int>(
                          title: Text(localizations.sunday),
                          value: DateTime.sunday,
                          groupValue: currentStartOfWeek,
                          onChanged: (int? value) {
                            if (value != null) {
                              context.read<CalendarProvider>().updateStartOfWeek(value);
                              Navigator.of(context).pop();
                            }
                          },
                        ),
                        RadioListTile<int>(
                          title: Text(localizations.monday),
                          value: DateTime.monday,
                          groupValue: currentStartOfWeek,
                          onChanged: (int? value) {
                            if (value != null) {
                              context.read<CalendarProvider>().updateStartOfWeek(value);
                              Navigator.of(context).pop();
                            }
                          },
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
          const Divider(),
          // 言語設定
          ListTile(
            title: Text(localizations.language),
            subtitle: Text(_getCurrentLanguageName(provider.languageSettings.selectedLocale, localizations)),
            onTap: () {
              _showLanguageDialog(context, provider, localizations);
            },
          ),
          const Divider(),
          // 事柄の管理セクション
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              localizations.manageItems,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          // 事柄リスト
          ...items.map((item) {
            return ListTile(
              leading: Container(
                width: 24,
                height: 24,
                color: item.getEffectiveColor(provider.settings),
              ),
              title: Text(kDebugMode ? '${item.name} (${item.id})' : item.name),
              trailing: Icon(
                item.isEnabled ? Icons.check_circle : Icons.cancel,
                color: item.isEnabled ? Colors.green : Colors.grey,
              ),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => EditItemScreen(item: item),
                  ),
                );
              },
            );
          }).toList(),
        ],
      ),
    );
  }

  String _getCurrentLanguageName(Locale? selectedLocale, AppLocalizations localizations) {
    if (selectedLocale == null) {
      final deviceLocale = WidgetsBinding.instance.platformDispatcher.locale;
      final defaultLocale = LanguageSettings.getDefaultLocale(deviceLocale);
      return _getLanguageDisplayName(defaultLocale, localizations);
    }
    
    switch (selectedLocale.toString()) {
      case 'en':
        return localizations.english;
      case 'ja':
        return localizations.japanese;
      case 'zh':
        return localizations.chineseSimplified;
      case 'zh_TW':
        return localizations.chineseTraditional;
      case 'ko':
        return localizations.korean;
      case 'fr':
        return localizations.french;
      case 'de':
        return localizations.german;
      case 'es':
        return localizations.spanish;
      case 'hi':
        return localizations.hindi;
      case 'id':
        return localizations.indonesian;
      case 'pt':
        return localizations.portuguese;
      case 'ar':
        return localizations.arabic;
      default:
        return selectedLocale.toString();
    }
  }

  void _showLanguageDialog(BuildContext context, CalendarProvider provider, AppLocalizations localizations) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(localizations.selectLanguage),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              ...LanguageSettings.supportedLocales.map((locale) {
                return RadioListTile<Locale?>(
                  title: Text(_getLanguageDisplayName(locale, localizations)),
                  value: locale,
                  groupValue: provider.languageSettings.selectedLocale,
                  onChanged: (Locale? value) {
                    provider.updateLanguage(value);
                    Navigator.of(context).pop();
                  },
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  String _getLanguageDisplayName(Locale locale, AppLocalizations localizations) {
    switch (locale.toString()) {
      case 'en':
        return localizations.english;
      case 'ja':
        return localizations.japanese;
      case 'zh':
        return localizations.chineseSimplified;
      case 'zh_TW':
        return localizations.chineseTraditional;
      case 'ko':
        return localizations.korean;
      case 'fr':
        return localizations.french;
      case 'de':
        return localizations.german;
      case 'es':
        return localizations.spanish;
      case 'hi':
        return localizations.hindi;
      case 'id':
        return localizations.indonesian;
      case 'pt':
        return localizations.portuguese;
      case 'ar':
        return localizations.arabic;
      default:
        return locale.toString();
    }
  }


}
