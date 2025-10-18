// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appTitle => 'कैलेंडर एप्प';

  @override
  String get today => 'आज';

  @override
  String todayButton(String date) {
    return 'आज $date';
  }

  @override
  String get settings => 'सेटिंग्स';

  @override
  String get weekStartsOn => 'सप्ताह की शुरुआत';

  @override
  String get sunday => 'रविवार';

  @override
  String get monday => 'सोमवार';

  @override
  String get tuesday => 'मंगलवार';

  @override
  String get wednesday => 'बुधवार';

  @override
  String get thursday => 'गुरुवार';

  @override
  String get friday => 'शुक्रवार';

  @override
  String get saturday => 'शनिवार';

  @override
  String get sundayShort => 'रवि';

  @override
  String get mondayShort => 'सोम';

  @override
  String get tuesdayShort => 'मंगल';

  @override
  String get wednesdayShort => 'बुध';

  @override
  String get thursdayShort => 'गुरु';

  @override
  String get fridayShort => 'शुक्र';

  @override
  String get saturdayShort => 'शनि';

  @override
  String get manageItems => 'आइटम प्रबंधित करें';

  @override
  String get language => 'भाषा';

  @override
  String get selectLanguage => 'भाषा चुनें';

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
  String get portuguese => 'पुर्तगाली';

  @override
  String get arabic => 'अरबी';

  @override
  String get colorBlue => 'नीला';

  @override
  String get colorOrange => 'नारंगी';

  @override
  String get colorGreen => 'हरा';

  @override
  String get colorRed => 'लाल';

  @override
  String get colorPurple => 'बैंगनी';

  @override
  String get colorBrown => 'भूरा';

  @override
  String get colorPink => 'गुलाबी';

  @override
  String get colorLimeGreen => 'चूना हरा';

  @override
  String get colorCyan => 'सियान';

  @override
  String get colorLightBlue => 'हल्का नीला';

  @override
  String get colorLightOrange => 'हल्का नारंगी';

  @override
  String get addRecordTitle => 'आज का रिकॉर्ड जोड़ें';

  @override
  String get cancelButton => 'रद्द करें';

  @override
  String get saveButton => 'सहेजें';

  @override
  String get continuousRecords => 'लगातार रिकॉर्ड';

  @override
  String get itemName => 'आइटम का नाम';

  @override
  String get continuousMonths => 'लगातार महीने';

  @override
  String get continuousWeeks => 'लगातार सप्ताह';

  @override
  String get continuousDays => 'लगातार दिन';

  @override
  String get dayShort => 'दिन';

  @override
  String get weekShort => 'सप्ताह';

  @override
  String get monthShort => 'महीने';

  @override
  String get editItem => 'संपादित करें';

  @override
  String get itemNameLabel => 'नाम';

  @override
  String get itemOrderLabel => 'क्रम';

  @override
  String get itemColorLabel => 'रंग';

  @override
  String get itemEnabledLabel => 'सक्षम';

  @override
  String get changeDisplayOrder => 'प्रदर्शन क्रम बदलें';

  @override
  String get newItem => 'नया आइटम';

  @override
  String get congratulations => 'बधाई हो!';

  @override
  String get recordSavedSuccessfully => 'रिकॉर्ड सफलतापूर्वक सहेजा गया!';

  @override
  String get okButton => 'OK';

  @override
  String get confirmation => 'पुष्टि';

  @override
  String addRecordConfirmation(Object itemName) {
    return 'क्या आप $itemName के लिए एक रिकॉर्ड जोड़ना चाहते हैं?';
  }

  @override
  String removeRecordConfirmation(Object itemName) {
    return 'क्या आप $itemName के लिए रिकॉर्ड हटाना चाहते हैं?';
  }

  @override
  String get yesButton => 'हाँ';

  @override
  String get noButton => 'नहीं';
}
