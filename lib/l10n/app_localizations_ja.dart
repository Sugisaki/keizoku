// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'カレンダーアプリ';

  @override
  String get today => '今日';

  @override
  String todayButton(String date, String icon) {
    return '$date日 $icon 追加';
  }

  @override
  String get settings => '設定';

  @override
  String get weekStartsOn => '週の始まり';

  @override
  String get sunday => '日曜日';

  @override
  String get monday => '月曜日';

  @override
  String get tuesday => '火曜日';

  @override
  String get wednesday => '水曜日';

  @override
  String get thursday => '木曜日';

  @override
  String get friday => '金曜日';

  @override
  String get saturday => '土曜日';

  @override
  String get sundayShort => '日';

  @override
  String get mondayShort => '月';

  @override
  String get tuesdayShort => '火';

  @override
  String get wednesdayShort => '水';

  @override
  String get thursdayShort => '木';

  @override
  String get fridayShort => '金';

  @override
  String get saturdayShort => '土';

  @override
  String get manageItems => '項目の管理';

  @override
  String get language => '言語';

  @override
  String get selectLanguage => '言語を選択';

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
  String get colorBlue => 'ブルー';

  @override
  String get colorOrange => 'オレンジ';

  @override
  String get colorGreen => 'グリーン';

  @override
  String get colorRed => 'レッド';

  @override
  String get colorPurple => 'パープル';

  @override
  String get colorBrown => 'ブラウン';

  @override
  String get colorPink => 'ピンク';

  @override
  String get colorLimeGreen => '黄緑';

  @override
  String get colorCyan => 'シアン';

  @override
  String get colorLightBlue => '薄ブルー';

  @override
  String get colorLightOrange => '薄オレンジ';

  @override
  String get addRecordTitle => '追加';

  @override
  String get addItem => '追加';

  @override
  String get yesterday => '昨日';

  @override
  String get cancelButton => 'キャンセル';

  @override
  String get saveButton => '保存';

  @override
  String get continuousRecords => '記録';

  @override
  String get itemName => '項目名';

  @override
  String get continuousMonths => '最後';

  @override
  String get continuousWeeks => '総数';

  @override
  String get continuousDays => '連続';

  @override
  String get unsavedChangesWarning => '変更内容が保存されていません。画面を離れると失われますが、よろしいですか？';

  @override
  String get dayShort => '日数';

  @override
  String get weekShort => '週数';

  @override
  String get monthShort => '月数';

  @override
  String get editItem => '編集';

  @override
  String get itemNameLabel => '名称';

  @override
  String get itemOrderLabel => '順番';

  @override
  String get itemColorLabel => '色';

  @override
  String get itemEnabledLabel => '有効';

  @override
  String get changeDisplayOrder => '表示順番を変更';

  @override
  String get newItem => '新規項目';

  @override
  String get congratulations => 'おめでとう';

  @override
  String get recordSavedSuccessfully => '記録が正常に保存されました！';

  @override
  String get okButton => 'OK';

  @override
  String get confirmation => '確認';

  @override
  String addRecordConfirmation(Object itemName) {
    return '$itemNameの記録を追加しますか？';
  }

  @override
  String removeRecordConfirmation(Object itemName) {
    return '$itemNameの記録を削除しますか？';
  }

  @override
  String get yesButton => 'はい';

  @override
  String get noButton => 'いいえ';
}
