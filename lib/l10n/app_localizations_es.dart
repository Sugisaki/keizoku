// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Aplicación de Calendario';

  @override
  String get today => 'Hoy';

  @override
  String todayButton(String date, String icon) {
    return '$date $icon Añadir';
  }

  @override
  String get settings => 'Configuración';

  @override
  String get weekStartsOn => 'La semana comienza';

  @override
  String get sunday => 'Domingo';

  @override
  String get monday => 'Lunes';

  @override
  String get tuesday => 'Martes';

  @override
  String get wednesday => 'Miércoles';

  @override
  String get thursday => 'Jueves';

  @override
  String get friday => 'Viernes';

  @override
  String get saturday => 'Sábado';

  @override
  String get sundayShort => 'Dom';

  @override
  String get mondayShort => 'Lun';

  @override
  String get tuesdayShort => 'Mar';

  @override
  String get wednesdayShort => 'Mié';

  @override
  String get thursdayShort => 'Jue';

  @override
  String get fridayShort => 'Vie';

  @override
  String get saturdayShort => 'Sáb';

  @override
  String get manageItems => 'Gestionar elementos';

  @override
  String get language => 'Idioma';

  @override
  String get selectLanguage => 'Seleccionar idioma';

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
  String get colorBlue => 'Azul';

  @override
  String get colorOrange => 'Naranja';

  @override
  String get colorGreen => 'Verde';

  @override
  String get colorRed => 'Rojo';

  @override
  String get colorPurple => 'Púrpura';

  @override
  String get colorBrown => 'Marrón';

  @override
  String get colorPink => 'Rosa';

  @override
  String get colorLimeGreen => 'Verde lima';

  @override
  String get colorCyan => 'Cian';

  @override
  String get colorLightBlue => 'Azul claro';

  @override
  String get colorLightOrange => 'Naranja claro';

  @override
  String get addRecordTitle => 'Añadir';

  @override
  String get addItem => 'Añadir';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get cancelButton => 'Cancelar';

  @override
  String get saveButton => 'Guardar';

  @override
  String get continuousRecords => 'Registros continuos';

  @override
  String get itemName => 'Nombre del elemento';

  @override
  String get continuousMonths => 'Meses continuos';

  @override
  String get continuousWeeks => 'Semanas continuas';

  @override
  String get continuousDays => 'Días continuos';

  @override
  String get dayShort => 'Días';

  @override
  String get weekShort => 'Sem';

  @override
  String get monthShort => 'Meses';

  @override
  String get editItem => 'Editar';

  @override
  String get itemNameLabel => 'Nombre';

  @override
  String get itemOrderLabel => 'Orden';

  @override
  String get itemColorLabel => 'Color';

  @override
  String get itemEnabledLabel => 'Habilitado';

  @override
  String get changeDisplayOrder => 'Cambiar orden de visualización';

  @override
  String get newItem => 'Nuevo elemento';

  @override
  String get congratulations => '¡Felicidades!';

  @override
  String get recordSavedSuccessfully => '¡Registro guardado exitosamente!';

  @override
  String get okButton => 'OK';

  @override
  String get confirmation => 'Confirmación';

  @override
  String addRecordConfirmation(Object itemName) {
    return '¿Desea agregar un registro para $itemName?';
  }

  @override
  String removeRecordConfirmation(Object itemName) {
    return '¿Desea eliminar el registro para $itemName?';
  }

  @override
  String get yesButton => 'Sí';

  @override
  String get noButton => 'No';
}
