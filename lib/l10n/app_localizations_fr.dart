// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Application Calendrier';

  @override
  String get today => 'Aujourd\'hui';

  @override
  String todayButton(String date) {
    return 'Aujourd\'hui $date';
  }

  @override
  String get settings => 'Paramètres';

  @override
  String get weekStartsOn => 'La semaine commence';

  @override
  String get sunday => 'Dimanche';

  @override
  String get monday => 'Lundi';

  @override
  String get tuesday => 'Mardi';

  @override
  String get wednesday => 'Mercredi';

  @override
  String get thursday => 'Jeudi';

  @override
  String get friday => 'Vendredi';

  @override
  String get saturday => 'Samedi';

  @override
  String get sundayShort => 'Dim';

  @override
  String get mondayShort => 'Lun';

  @override
  String get tuesdayShort => 'Mar';

  @override
  String get wednesdayShort => 'Mer';

  @override
  String get thursdayShort => 'Jeu';

  @override
  String get fridayShort => 'Ven';

  @override
  String get saturdayShort => 'Sam';

  @override
  String get manageItems => 'Gérer les éléments';

  @override
  String get language => 'Langue';

  @override
  String get selectLanguage => 'Sélectionner la langue';

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
  String get colorBlue => 'Bleu';

  @override
  String get colorOrange => 'Orange';

  @override
  String get colorGreen => 'Vert';

  @override
  String get colorRed => 'Rouge';

  @override
  String get colorPurple => 'Violet';

  @override
  String get colorBrown => 'Marron';

  @override
  String get colorPink => 'Rose';

  @override
  String get colorLimeGreen => 'Citron vert';

  @override
  String get colorCyan => 'Cyan';

  @override
  String get colorLightBlue => 'Bleu clair';

  @override
  String get colorLightOrange => 'Orange clair';

  @override
  String get addRecordTitle => 'Ajouter un enregistrement pour aujourd\'hui';

  @override
  String get cancelButton => 'Annuler';

  @override
  String get saveButton => 'Enregistrer';

  @override
  String get continuousRecords => 'Enregistrements continus';

  @override
  String get itemName => 'Nom de l\'élément';

  @override
  String get continuousMonths => 'Mois consécutifs';

  @override
  String get continuousWeeks => 'Semaines consécutives';

  @override
  String get continuousDays => 'Jours consécutifs';

  @override
  String get dayShort => 'Jours';

  @override
  String get weekShort => 'Sem';

  @override
  String get monthShort => 'Mois';

  @override
  String get editItem => 'Modifier';

  @override
  String get itemNameLabel => 'Nom';

  @override
  String get itemOrderLabel => 'Ordre';

  @override
  String get itemColorLabel => 'Couleur';

  @override
  String get itemEnabledLabel => 'Activé';

  @override
  String get changeDisplayOrder => 'Modifier l\'ordre d\'affichage';

  @override
  String get newItem => 'Nouvel élément';

  @override
  String get congratulations => 'Félicitations !';

  @override
  String get recordSavedSuccessfully =>
      'Enregistrement sauvegardé avec succès !';

  @override
  String get okButton => 'OK';

  @override
  String get confirmation => 'Confirmation';

  @override
  String addRecordConfirmation(Object itemName) {
    return 'Voulez-vous ajouter un enregistrement pour $itemName ?';
  }

  @override
  String removeRecordConfirmation(Object itemName) {
    return 'Voulez-vous supprimer l\'enregistrement pour $itemName ?';
  }

  @override
  String get yesButton => 'Oui';

  @override
  String get noButton => 'Non';
}
