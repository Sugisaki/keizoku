// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'تطبيق التقويم';

  @override
  String get today => 'اليوم';

  @override
  String todayButton(String date) {
    return 'اليوم $date';
  }

  @override
  String get settings => 'الإعدادات';

  @override
  String get weekStartsOn => 'تبدأ الأسبوع';

  @override
  String get sunday => 'الأحد';

  @override
  String get monday => 'الاثنين';

  @override
  String get tuesday => 'الثلاثاء';

  @override
  String get wednesday => 'الأربعاء';

  @override
  String get thursday => 'الخميس';

  @override
  String get friday => 'الجمعة';

  @override
  String get saturday => 'السبت';

  @override
  String get sundayShort => 'أحد';

  @override
  String get mondayShort => 'اثن';

  @override
  String get tuesdayShort => 'ثلا';

  @override
  String get wednesdayShort => 'أرب';

  @override
  String get thursdayShort => 'خمي';

  @override
  String get fridayShort => 'جمع';

  @override
  String get saturdayShort => 'سبت';

  @override
  String get manageItems => 'إدارة العناصر';

  @override
  String get language => 'اللغة';

  @override
  String get selectLanguage => 'اختر اللغة';

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
  String get portuguese => 'البرتغالية';

  @override
  String get arabic => 'العربية';

  @override
  String get addRecordTitle => 'إضافة سجل اليوم';

  @override
  String get cancelButton => 'إلغاء';

  @override
  String get saveButton => 'حفظ';

  @override
  String get continuousRecords => 'السجلات المستمرة';

  @override
  String get itemName => 'اسم العنصر';

  @override
  String get continuousMonths => 'أشهر متتالية';

  @override
  String get continuousWeeks => 'أسابيع متتالية';

  @override
  String get continuousDays => 'أيام متتالية';

  @override
  String get dayShort => 'يوم';

  @override
  String get weekShort => 'أسبوع';

  @override
  String get monthShort => 'شهر';
}
