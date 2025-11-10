// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => '日历应用';

  @override
  String get today => '今天';

  @override
  String todayButton(String date, String icon) {
    return '$date $icon 添加';
  }

  @override
  String get settings => '设置';

  @override
  String get weekStartsOn => '周的开始';

  @override
  String get sunday => '星期日';

  @override
  String get monday => '星期一';

  @override
  String get tuesday => '星期二';

  @override
  String get wednesday => '星期三';

  @override
  String get thursday => '星期四';

  @override
  String get friday => '星期五';

  @override
  String get saturday => '星期六';

  @override
  String get sundayShort => '日';

  @override
  String get mondayShort => '一';

  @override
  String get tuesdayShort => '二';

  @override
  String get wednesdayShort => '三';

  @override
  String get thursdayShort => '四';

  @override
  String get fridayShort => '五';

  @override
  String get saturdayShort => '六';

  @override
  String get manageItems => '管理项目';

  @override
  String get language => '语言';

  @override
  String get selectLanguage => '选择语言';

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
  String get hindi => '印地语';

  @override
  String get indonesian => '印度尼西亚语';

  @override
  String get portuguese => '葡萄牙语';

  @override
  String get arabic => '阿拉伯语';

  @override
  String get colorBlue => '蓝色';

  @override
  String get colorOrange => '橙色';

  @override
  String get colorGreen => '绿色';

  @override
  String get colorRed => '红色';

  @override
  String get colorPurple => '紫色';

  @override
  String get colorBrown => '棕色';

  @override
  String get colorPink => '粉色';

  @override
  String get colorLimeGreen => '黄绿色';

  @override
  String get colorCyan => '青色';

  @override
  String get colorLightBlue => '浅蓝色';

  @override
  String get colorLightOrange => '浅橙色';

  @override
  String get addRecordTitle => '添加';

  @override
  String get addItem => '添加';

  @override
  String get yesterday => '昨天';

  @override
  String get cancelButton => '取消';

  @override
  String get saveButton => '保存';

  @override
  String get continuousRecords => '记录';

  @override
  String get itemName => '项目名称';

  @override
  String get continuousMonths => '最后';

  @override
  String get continuousWeeks => '总数';

  @override
  String get continuousDays => '连续';

  @override
  String get unsavedChangesWarning => '更改尚未保存。如果离开屏幕，将会丢失。确定吗？';

  @override
  String get dayShort => '天数';

  @override
  String get weekShort => '周数';

  @override
  String get monthShort => '月数';

  @override
  String get editItem => '编辑';

  @override
  String get itemNameLabel => '名称';

  @override
  String get itemOrderLabel => '顺序';

  @override
  String get itemColorLabel => '颜色';

  @override
  String get itemEnabledLabel => '启用';

  @override
  String get changeDisplayOrder => '更改显示顺序';

  @override
  String get newItem => '新建项目';

  @override
  String get congratulations => '恭喜';

  @override
  String get recordSavedSuccessfully => '记录已成功保存！';

  @override
  String get okButton => 'OK';

  @override
  String get confirmation => '确认';

  @override
  String addRecordConfirmation(Object itemName) {
    return '您要为 $itemName 添加记录吗？';
  }

  @override
  String removeRecordConfirmation(Object itemName) {
    return '您要删除 $itemName 的记录吗？';
  }

  @override
  String get yesButton => '是';

  @override
  String get noButton => '否';

  @override
  String get googleAccount => 'Google Account';

  @override
  String get notLoggedIn => 'Not logged in';

  @override
  String loggedInAs(String displayName) {
    return 'Logged in as $displayName';
  }

  @override
  String loginFailed(String error) {
    return 'Google login failed: $error';
  }

  @override
  String get loggedIn => 'Logged in';

  @override
  String get loginButton => 'Login';

  @override
  String get logoutButton => 'Logout';

  @override
  String get loggedOut => 'Logged out successfully.';

  @override
  String logoutFailed(String error) {
    return 'Logout failed: $error';
  }

  @override
  String get checkingLoginStatus => '检查中...';
}

/// The translations for Chinese, as used in Taiwan (`zh_TW`).
class AppLocalizationsZhTw extends AppLocalizationsZh {
  AppLocalizationsZhTw() : super('zh_TW');

  @override
  String get appTitle => '日曆應用';

  @override
  String get today => '今天';

  @override
  String todayButton(String date, String icon) {
    return '$date $icon 新增';
  }

  @override
  String get settings => '設定';

  @override
  String get weekStartsOn => '週的開始';

  @override
  String get sunday => '星期日';

  @override
  String get monday => '星期一';

  @override
  String get tuesday => '星期二';

  @override
  String get wednesday => '星期三';

  @override
  String get thursday => '星期四';

  @override
  String get friday => '星期五';

  @override
  String get saturday => '星期六';

  @override
  String get sundayShort => '日';

  @override
  String get mondayShort => '一';

  @override
  String get tuesdayShort => '二';

  @override
  String get wednesdayShort => '三';

  @override
  String get thursdayShort => '四';

  @override
  String get fridayShort => '五';

  @override
  String get saturdayShort => '六';

  @override
  String get manageItems => '管理項目';

  @override
  String get language => '語言';

  @override
  String get selectLanguage => '選擇語言';

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
  String get hindi => '印地語';

  @override
  String get indonesian => '印度尼西亞語';

  @override
  String get portuguese => '葡萄牙語';

  @override
  String get arabic => '阿拉伯語';

  @override
  String get colorBlue => '藍色';

  @override
  String get colorOrange => '橙色';

  @override
  String get colorGreen => '綠色';

  @override
  String get colorRed => '紅色';

  @override
  String get colorPurple => '紫色';

  @override
  String get colorBrown => '棕色';

  @override
  String get colorPink => '粉色';

  @override
  String get colorLimeGreen => '黃綠色';

  @override
  String get colorCyan => '青色';

  @override
  String get colorLightBlue => '淺藍色';

  @override
  String get colorLightOrange => '淺橙色';

  @override
  String get addRecordTitle => '新增';

  @override
  String get addItem => '新增';

  @override
  String get cancelButton => '取消';

  @override
  String get saveButton => '儲存';

  @override
  String get continuousRecords => '記錄';

  @override
  String get itemName => '項目名稱';

  @override
  String get continuousMonths => '最後';

  @override
  String get continuousWeeks => '總數';

  @override
  String get continuousDays => '連續';

  @override
  String get unsavedChangesWarning => '變更尚未儲存。如果離開畫面，將會遺失。確定嗎？';

  @override
  String get dayShort => '天數';

  @override
  String get weekShort => '週數';

  @override
  String get monthShort => '月數';

  @override
  String get editItem => '編輯';

  @override
  String get itemNameLabel => '名稱';

  @override
  String get itemOrderLabel => '順序';

  @override
  String get itemColorLabel => '顏色';

  @override
  String get itemEnabledLabel => '啟用';

  @override
  String get changeDisplayOrder => '更改顯示順序';

  @override
  String get newItem => '新建項目';

  @override
  String get congratulations => '恭喜';

  @override
  String get recordSavedSuccessfully => '記錄已成功保存';

  @override
  String get okButton => 'OK';

  @override
  String get confirmation => '確認';

  @override
  String addRecordConfirmation(Object itemName) {
    return '您要為 $itemName 新增記錄嗎？';
  }

  @override
  String removeRecordConfirmation(Object itemName) {
    return '您要刪除 $itemName 的記錄嗎？';
  }

  @override
  String get yesButton => '是';

  @override
  String get noButton => '否';

  @override
  String get checkingLoginStatus => '檢查中...';
}
