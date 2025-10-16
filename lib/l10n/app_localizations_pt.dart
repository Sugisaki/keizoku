// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Aplicativo de Calendário';

  @override
  String get today => 'Hoje';

  @override
  String todayButton(String date) {
    return 'Hoje $date';
  }

  @override
  String get settings => 'Configurações';

  @override
  String get weekStartsOn => 'A semana começa';

  @override
  String get sunday => 'Domingo';

  @override
  String get monday => 'Segunda-feira';

  @override
  String get tuesday => 'Terça-feira';

  @override
  String get wednesday => 'Quarta-feira';

  @override
  String get thursday => 'Quinta-feira';

  @override
  String get friday => 'Sexta-feira';

  @override
  String get saturday => 'Sábado';

  @override
  String get sundayShort => 'Dom';

  @override
  String get mondayShort => 'Seg';

  @override
  String get tuesdayShort => 'Ter';

  @override
  String get wednesdayShort => 'Qua';

  @override
  String get thursdayShort => 'Qui';

  @override
  String get fridayShort => 'Sex';

  @override
  String get saturdayShort => 'Sáb';

  @override
  String get manageItems => 'Gerenciar itens';

  @override
  String get language => 'Idioma';

  @override
  String get selectLanguage => 'Selecionar idioma';

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
  String get hindi => 'Hindi';

  @override
  String get indonesian => 'Indonésio';

  @override
  String get portuguese => 'Português';

  @override
  String get arabic => 'Árabe';

  @override
  String get addRecordTitle => 'Adicionar Registro para Hoje';

  @override
  String get cancelButton => 'Cancelar';

  @override
  String get saveButton => 'Salvar';

  @override
  String get continuousRecords => 'Registros Contínuos';

  @override
  String get itemName => 'Nome do Item';

  @override
  String get continuousMonths => 'Meses Contínuos';

  @override
  String get continuousWeeks => 'Semanas Contínuas';

  @override
  String get continuousDays => 'Dias Contínuos';

  @override
  String get dayShort => 'Dias';

  @override
  String get weekShort => 'Sem';

  @override
  String get monthShort => 'Meses';

  @override
  String get editItem => 'Editar';

  @override
  String get itemNameLabel => 'Nome';

  @override
  String get itemOrderLabel => 'Ordem';

  @override
  String get itemColorLabel => 'Cor';

  @override
  String get itemEnabledLabel => 'Ativado';
}
