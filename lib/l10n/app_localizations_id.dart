// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get appTitle => 'Aplikasi Kalender';

  @override
  String get today => 'Hari ini';

  @override
  String todayButton(String date, String icon) {
    return '$date $icon Tambahkan';
  }

  @override
  String get settings => 'Pengaturan';

  @override
  String get weekStartsOn => 'Minggu dimulai pada';

  @override
  String get sunday => 'Minggu';

  @override
  String get monday => 'Senin';

  @override
  String get tuesday => 'Selasa';

  @override
  String get wednesday => 'Rabu';

  @override
  String get thursday => 'Kamis';

  @override
  String get friday => 'Jumat';

  @override
  String get saturday => 'Sabtu';

  @override
  String get sundayShort => 'Min';

  @override
  String get mondayShort => 'Sen';

  @override
  String get tuesdayShort => 'Sel';

  @override
  String get wednesdayShort => 'Rab';

  @override
  String get thursdayShort => 'Kam';

  @override
  String get fridayShort => 'Jum';

  @override
  String get saturdayShort => 'Sab';

  @override
  String get manageItems => 'Kelola item';

  @override
  String get language => 'Bahasa';

  @override
  String get selectLanguage => 'Pilih bahasa';

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
  String get portuguese => 'Portugis';

  @override
  String get arabic => 'Arab';

  @override
  String get colorBlue => 'Biru';

  @override
  String get colorOrange => 'Oranye';

  @override
  String get colorGreen => 'Hijau';

  @override
  String get colorRed => 'Merah';

  @override
  String get colorPurple => 'Ungu';

  @override
  String get colorBrown => 'Coklat';

  @override
  String get colorPink => 'Merah Muda';

  @override
  String get colorLimeGreen => 'Hijau Limau';

  @override
  String get colorCyan => 'Sian';

  @override
  String get colorLightBlue => 'Biru Muda';

  @override
  String get colorLightOrange => 'Oranye Muda';

  @override
  String get addRecordTitle => 'Tambahkan Catatan Hari Ini';

  @override
  String get addItem => 'Tambahkan';

  @override
  String get cancelButton => 'Batal';

  @override
  String get saveButton => 'Simpan';

  @override
  String get continuousRecords => 'Catatan Berkelanjutan';

  @override
  String get itemName => 'Nama Item';

  @override
  String get continuousMonths => 'Bulan Berkelanjutan';

  @override
  String get continuousWeeks => 'Minggu Berkelanjutan';

  @override
  String get continuousDays => 'Hari Berkelanjutan';

  @override
  String get dayShort => 'Hari';

  @override
  String get weekShort => 'Minggu';

  @override
  String get monthShort => 'Bulan';

  @override
  String get editItem => 'Edit';

  @override
  String get itemNameLabel => 'Nama';

  @override
  String get itemOrderLabel => 'Urutan';

  @override
  String get itemColorLabel => 'Warna';

  @override
  String get itemEnabledLabel => 'Aktif';

  @override
  String get changeDisplayOrder => 'Ubah Urutan Tampilan';

  @override
  String get newItem => 'Item Baru';

  @override
  String get congratulations => 'Selamat!';

  @override
  String get recordSavedSuccessfully => 'Rekaman berhasil disimpan!';

  @override
  String get okButton => 'OK';

  @override
  String get confirmation => 'Konfirmasi';

  @override
  String addRecordConfirmation(Object itemName) {
    return 'Apakah Anda ingin menambahkan catatan untuk $itemName?';
  }

  @override
  String removeRecordConfirmation(Object itemName) {
    return 'Apakah Anda ingin menghapus catatan untuk $itemName?';
  }

  @override
  String get yesButton => 'Ya';

  @override
  String get noButton => 'Tidak';
}
