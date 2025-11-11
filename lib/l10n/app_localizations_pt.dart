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
  String todayButton(String date, String icon) {
    return '$date $icon Adicionar';
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
  String get colorBlue => 'Azul';

  @override
  String get colorOrange => 'Laranja';

  @override
  String get colorGreen => 'Verde';

  @override
  String get colorRed => 'Vermelho';

  @override
  String get colorPurple => 'Roxo';

  @override
  String get colorBrown => 'Marrom';

  @override
  String get colorPink => 'Rosa';

  @override
  String get colorLimeGreen => 'Verde Lima';

  @override
  String get colorCyan => 'Ciano';

  @override
  String get colorLightBlue => 'Azul Claro';

  @override
  String get colorLightOrange => 'Laranja Claro';

  @override
  String get addRecordTitle => 'Adicionar';

  @override
  String get addItem => 'Adicionar';

  @override
  String get yesterday => 'Ontem';

  @override
  String get cancelButton => 'Cancelar';

  @override
  String get saveButton => 'Salvar';

  @override
  String get continuousRecords => 'Registros';

  @override
  String get itemName => 'Nome do Item';

  @override
  String get continuousMonths => 'Último';

  @override
  String get continuousWeeks => 'Total';

  @override
  String get continuousDays => 'Contínuo';

  @override
  String get unsavedChangesWarning =>
      'As alterações não foram salvas. Se você sair da tela, elas serão perdidas. Tem certeza?';

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

  @override
  String get changeDisplayOrder => 'Alterar Ordem de Exibição';

  @override
  String get newItem => 'Novo Item';

  @override
  String get congratulations => 'Parabéns!';

  @override
  String get recordSavedSuccessfully => 'Registro salvo com sucesso!';

  @override
  String get okButton => 'OK';

  @override
  String get confirmation => 'Confirmação';

  @override
  String addRecordConfirmation(Object itemName) {
    return 'Deseja adicionar um registro para $itemName?';
  }

  @override
  String removeRecordConfirmation(Object itemName) {
    return 'Deseja remover o registro para $itemName?';
  }

  @override
  String get yesButton => 'Sim';

  @override
  String get noButton => 'Não';

  @override
  String get googleAccount => 'Conta do Google';

  @override
  String get notLoggedIn => 'Não conectado';

  @override
  String loggedInAs(String displayName) {
    return 'Conectado como $displayName';
  }

  @override
  String loginFailed(String error) {
    return 'Falha no login do Google: $error';
  }

  @override
  String get loggedIn => 'Conectado';

  @override
  String get loginButton => 'Entrar';

  @override
  String get logoutButton => 'Sair';

  @override
  String get loggedOut => 'Logout realizado com sucesso.';

  @override
  String logoutFailed(String error) {
    return 'Falha no logout: $error';
  }

  @override
  String get checkingLoginStatus => 'Verificando...';

  @override
  String get deleteFirestoreData => 'Excluir Dados da Nuvem';

  @override
  String get deleteFirestoreDataDescription =>
      'Excluir permanentemente todos os seus dados armazenados na nuvem. Isso não excluirá os dados locais.';

  @override
  String get deleteButton => 'Excluir';

  @override
  String get confirmDelete => 'Confirmar Exclusão';

  @override
  String get deleteFirestoreDataConfirmation =>
      'Tem certeza de que deseja excluir permanentemente todos os seus dados armazenados na nuvem? Esta ação não pode ser desfeita.';

  @override
  String get firestoreDataDeletedSuccessfully =>
      'Todos os dados armazenados na nuvem foram excluídos com sucesso.';

  @override
  String firestoreDataDeletionFailed(String error) {
    return 'Falha ao excluir todos os dados armazenados na nuvem: $error';
  }
}
