// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appTitle => '달력 앱';

  @override
  String get today => '오늘';

  @override
  String todayButton(String date, String icon) {
    return '$date $icon 추가';
  }

  @override
  String get settings => '설정';

  @override
  String get weekStartsOn => '주 시작일';

  @override
  String get sunday => '일요일';

  @override
  String get monday => '월요일';

  @override
  String get tuesday => '화요일';

  @override
  String get wednesday => '수요일';

  @override
  String get thursday => '목요일';

  @override
  String get friday => '금요일';

  @override
  String get saturday => '토요일';

  @override
  String get sundayShort => '일';

  @override
  String get mondayShort => '월';

  @override
  String get tuesdayShort => '화';

  @override
  String get wednesdayShort => '수';

  @override
  String get thursdayShort => '목';

  @override
  String get fridayShort => '금';

  @override
  String get saturdayShort => '토';

  @override
  String get manageItems => '항목 관리';

  @override
  String get language => '언어';

  @override
  String get selectLanguage => '언어 선택';

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
  String get portuguese => '포르투갈어';

  @override
  String get arabic => '아랍어';

  @override
  String get colorBlue => '파란색';

  @override
  String get colorOrange => '주황색';

  @override
  String get colorGreen => '녹색';

  @override
  String get colorRed => '빨간색';

  @override
  String get colorPurple => '보라색';

  @override
  String get colorBrown => '갈색';

  @override
  String get colorPink => '분홍색';

  @override
  String get colorLimeGreen => '라임그린';

  @override
  String get colorCyan => '청색';

  @override
  String get colorLightBlue => '밝은 파랑';

  @override
  String get colorLightOrange => '밝은 오렌지';

  @override
  String get addRecordTitle => '추가';

  @override
  String get addItem => '추가';

  @override
  String get yesterday => '어제';

  @override
  String get cancelButton => '취소';

  @override
  String get saveButton => '저장';

  @override
  String get continuousRecords => '기록';

  @override
  String get itemName => '항목 이름';

  @override
  String get continuousMonths => '마지막';

  @override
  String get continuousWeeks => '총수';

  @override
  String get continuousDays => '연속';

  @override
  String get unsavedChangesWarning =>
      '변경 사항이 저장되지 않았습니다. 화면을 나가면 사라집니다. 계속하시겠습니까?';

  @override
  String get dayShort => '일';

  @override
  String get weekShort => '주';

  @override
  String get monthShort => '월';

  @override
  String get editItem => '편집';

  @override
  String get itemNameLabel => '이름';

  @override
  String get itemOrderLabel => '순서';

  @override
  String get itemColorLabel => '색상';

  @override
  String get itemEnabledLabel => '활성화';

  @override
  String get changeDisplayOrder => '표시 순서 변경';

  @override
  String get newItem => '새 항목';

  @override
  String get congratulations => '축하합니다';

  @override
  String get recordSavedSuccessfully => '기록이 성공적으로 저장되었습니다!';

  @override
  String get okButton => 'OK';

  @override
  String get confirmation => '확인';

  @override
  String addRecordConfirmation(Object itemName) {
    return '$itemName에 대한 기록을 추가하시겠습니까?';
  }

  @override
  String removeRecordConfirmation(Object itemName) {
    return '$itemName에 대한 기록을 삭제하시겠습니까?';
  }

  @override
  String get yesButton => '예';

  @override
  String get noButton => '아니오';

  @override
  String get googleAccount => 'Google 계정';

  @override
  String get notLoggedIn => '로그인하지 않음';

  @override
  String loggedInAs(String displayName) {
    return '$displayName으로 로그인됨';
  }

  @override
  String loginFailed(String error) {
    return 'Google 로그인 실패: $error';
  }

  @override
  String get loggedIn => '로그인됨';

  @override
  String get loginButton => '로그인';

  @override
  String get logoutButton => '로그아웃';

  @override
  String get loggedOut => '성공적으로 로그아웃했습니다.';

  @override
  String logoutFailed(String error) {
    return '로그아웃 실패: $error';
  }

  @override
  String get checkingLoginStatus => '확인 중...';

  @override
  String get deleteFirestoreData => '클라우드 데이터 삭제';

  @override
  String get deleteFirestoreDataDescription =>
      '클라우드에 저장된 모든 데이터를 영구적으로 삭제합니다. 로컬 데이터는 삭제되지 않습니다.';

  @override
  String get deleteButton => '삭제';

  @override
  String get confirmDelete => '삭제 확인';

  @override
  String get deleteFirestoreDataConfirmation =>
      '클라우드에 저장된 모든 데이터를 영구적으로 삭제하시겠습니까? 이 작업은 실행 취소할 수 없습니다.';

  @override
  String get firestoreDataDeletedSuccessfully =>
      '클라우드에 저장된 모든 데이터가 성공적으로 삭제되었습니다.';

  @override
  String firestoreDataDeletionFailed(String error) {
    return '클라우드에 저장된 모든 데이터 삭제 실패: $error';
  }
}
