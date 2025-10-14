// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Kalender App';

  @override
  String get today => 'Heute';

  @override
  String todayButton(String date) {
    return 'Heute $date';
  }

  @override
  String get settings => 'Einstellungen';

  @override
  String get weekStartsOn => 'Woche beginnt am';

  @override
  String get sunday => 'Sonntag';

  @override
  String get monday => 'Montag';

  @override
  String get tuesday => 'Dienstag';

  @override
  String get wednesday => 'Mittwoch';

  @override
  String get thursday => 'Donnerstag';

  @override
  String get friday => 'Freitag';

  @override
  String get saturday => 'Samstag';

  @override
  String get sundayShort => 'So';

  @override
  String get mondayShort => 'Mo';

  @override
  String get tuesdayShort => 'Di';

  @override
  String get wednesdayShort => 'Mi';

  @override
  String get thursdayShort => 'Do';

  @override
  String get fridayShort => 'Fr';

  @override
  String get saturdayShort => 'Sa';

  @override
  String get manageItems => 'Elemente verwalten';

  @override
  String get language => 'Sprache';

  @override
  String get selectLanguage => 'Sprache auswählen';

  @override
  String get english => 'English';

  @override
  String get japanese => '日本語';

  @override
  String get chineseSimplified => '简体中文';

  @override
  String get chineseTraditional => '繁體中文';

  @override
  String get korean => '한국어';

  @override
  String get french => 'Français';

  @override
  String get german => 'Deutsch';

  @override
  String get spanish => 'Español';

  @override
  String get hindi => 'हिन्दी';

  @override
  String get indonesian => 'Bahasa Indonesia';

  @override
  String get portuguese => 'Português';

  @override
  String get arabic => 'العربية';

  @override
  String get addRecordTitle => 'Eintrag für heute hinzufügen';

  @override
  String get cancelButton => 'Abbrechen';

  @override
  String get saveButton => 'Speichern';

  @override
  String get continuousRecords => 'Fortlaufende Aufzeichnungen';

  @override
  String get itemName => 'Elementname';

  @override
  String get continuousMonths => 'Monate in Folge';

  @override
  String get continuousWeeks => 'Wochen in Folge';

  @override
  String get continuousDays => 'Tage in Folge';

  @override
  String get dayShort => 'Tage';

  @override
  String get weekShort => 'Wo';

  @override
  String get monthShort => 'Mon';
}
