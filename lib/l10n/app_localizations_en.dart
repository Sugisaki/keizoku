// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Calendar App';

  @override
  String get today => 'Today';

  @override
  String todayButton(String date, String icon) {
    return '$date $icon Add';
  }

  @override
  String get settings => 'Settings';

  @override
  String get weekStartsOn => 'Week starts on';

  @override
  String get sunday => 'Sunday';

  @override
  String get monday => 'Monday';

  @override
  String get tuesday => 'Tuesday';

  @override
  String get wednesday => 'Wednesday';

  @override
  String get thursday => 'Thursday';

  @override
  String get friday => 'Friday';

  @override
  String get saturday => 'Saturday';

  @override
  String get sundayShort => 'Sun';

  @override
  String get mondayShort => 'Mon';

  @override
  String get tuesdayShort => 'Tue';

  @override
  String get wednesdayShort => 'Wed';

  @override
  String get thursdayShort => 'Thu';

  @override
  String get fridayShort => 'Fri';

  @override
  String get saturdayShort => 'Sat';

  @override
  String get manageItems => 'Manage Items';

  @override
  String get language => 'Language';

  @override
  String get selectLanguage => 'Select Language';

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
  String get colorBlue => 'Blue';

  @override
  String get colorOrange => 'Orange';

  @override
  String get colorGreen => 'Green';

  @override
  String get colorRed => 'Red';

  @override
  String get colorPurple => 'Purple';

  @override
  String get colorBrown => 'Brown';

  @override
  String get colorPink => 'Pink';

  @override
  String get colorLimeGreen => 'Lime Green';

  @override
  String get colorCyan => 'Cyan';

  @override
  String get colorLightBlue => 'Light Blue';

  @override
  String get colorLightOrange => 'Light Orange';

  @override
  String get addRecordTitle => 'Add';

  @override
  String get addItem => 'Add';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get cancelButton => 'Cancel';

  @override
  String get saveButton => 'Save';

  @override
  String get continuousRecords => 'Records';

  @override
  String get itemName => 'Item Name';

  @override
  String get continuousMonths => 'Last';

  @override
  String get continuousWeeks => 'Total';

  @override
  String get continuousDays => 'Streak';

  @override
  String get unsavedChangesWarning =>
      'Changes have not been saved. If you leave the screen, they will be lost. Are you sure?';

  @override
  String get dayShort => 'Days';

  @override
  String get weekShort => 'Weeks';

  @override
  String get monthShort => 'Months';

  @override
  String get editItem => 'Edit';

  @override
  String get itemNameLabel => 'Name';

  @override
  String get itemOrderLabel => 'Order';

  @override
  String get itemColorLabel => 'Color';

  @override
  String get itemEnabledLabel => 'Enabled';

  @override
  String get changeDisplayOrder => 'Change Display Order';

  @override
  String get newItem => 'New Item';

  @override
  String get congratulations => 'Congratulations!';

  @override
  String get recordSavedSuccessfully => 'Record saved successfully!';

  @override
  String get okButton => 'OK';

  @override
  String get confirmation => 'Confirmation';

  @override
  String addRecordConfirmation(Object itemName) {
    return 'Do you want to add a record for $itemName?';
  }

  @override
  String removeRecordConfirmation(Object itemName) {
    return 'Do you want to remove the record for $itemName?';
  }

  @override
  String get yesButton => 'Yes';

  @override
  String get noButton => 'No';

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
  String get checkingLoginStatus => 'Checking...';
}
