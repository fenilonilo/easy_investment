// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Finance Pro';

  @override
  String get login => 'Entrar';

  @override
  String get register => 'Cadastrar';

  @override
  String get email => 'E-mail';

  @override
  String get password => 'Senha';

  @override
  String get name => 'Nome';

  @override
  String get birthDate => 'Data de Nascimento';

  @override
  String get investorProfile => 'Perfil de Investidor';

  @override
  String get conservative => 'Conservador';

  @override
  String get moderate => 'Moderado';

  @override
  String get aggressive => 'Agressivo';

  @override
  String get home => 'Início';

  @override
  String get profile => 'Perfil';

  @override
  String get chat => 'Chat';

  @override
  String get settings => 'Configurações';

  @override
  String get watchlist => 'Watchlist';

  @override
  String get searchAssets => 'Buscar ativos...';

  @override
  String get saveChanges => 'Salvar Alterações';

  @override
  String get logout => 'Sair';

  @override
  String get theme => 'Tema';

  @override
  String get language => 'Idioma';

  @override
  String get darkMode => 'Modo Escuro';

  @override
  String get addFirstAsset => 'Adicionar seu primeiro ativo';

  @override
  String get noAssetsSubtitle =>
      'Busque ativos na aba Perfil e adicione-os à sua watchlist.';

  @override
  String get loading => 'Carregando...';

  @override
  String get retry => 'Tentar novamente';

  @override
  String get error => 'Erro';

  @override
  String get period1D => '1D';

  @override
  String get period1W => '1S';

  @override
  String get period1M => '1M';

  @override
  String get period1Y => '1A';

  @override
  String get periodAll => 'MAX';

  @override
  String get news => 'Notícias';

  @override
  String get dividends => 'Dividendos';

  @override
  String get financials => 'Financeiros';

  @override
  String get typeMessage => 'Digite uma mensagem...';

  @override
  String get aiAssistant => 'IA Financeira';

  @override
  String get configTab => 'Config';

  @override
  String get aiChat => 'IA Chat';

  @override
  String get appearance => 'Aparência';

  @override
  String get darkModeOn => 'Ativo (OLED)';

  @override
  String get darkModeOff => 'Inativo';

  @override
  String get about => 'Sobre';

  @override
  String get version => 'Versão';

  @override
  String get privacy => 'Privacidade';

  @override
  String get privacyDesc =>
      'Seu token e perfil ficam salvos de forma segura neste dispositivo';

  @override
  String get languageName => 'Português (BR)';

  @override
  String get logoutAccount => 'Sair da conta';

  @override
  String get logoutConfirm => 'Deseja realmente sair da sua conta?';

  @override
  String get cancel => 'Cancelar';

  @override
  String get emptyWatchlist => 'Sua watchlist está vazia';

  @override
  String get quoteError => 'Erro ao carregar cotação';

  @override
  String get charts => 'Gráficos';

  @override
  String get profileError => 'Erro ao carregar perfil.';

  @override
  String get searchAssetsHint => 'Buscar ativos (ex: AAPL, BTC)...';

  @override
  String get noAssetsFound => 'Nenhum ativo encontrado.';

  @override
  String get welcomeBack => 'Bem-vindo de volta';

  @override
  String get loginToContinue => 'Faça login para continuar';

  @override
  String get noAccount => 'Não tem conta? ';

  @override
  String get signUp => 'Cadastre-se';

  @override
  String get createAccount => 'Criar Conta';

  @override
  String get yourInfo => 'Suas informações';

  @override
  String get fullName => 'Nome completo';

  @override
  String get selectBirthDate => 'Selecione sua data de nascimento';

  @override
  String get haveAccount => 'Já tem conta? ';

  @override
  String get assetAdvisor => 'Consultor de Ativos';

  @override
  String get liveMarketData => 'Dados de mercado ao vivo';

  @override
  String get thinking => 'Pensando…';

  @override
  String get previousChats => 'Conversas anteriores';

  @override
  String get newChat => 'Nova conversa';

  @override
  String get askAboutAsset => 'Pergunte sobre um ativo...';

  @override
  String charLimitReached(int max) {
    return 'Limite de $max caracteres atingido';
  }

  @override
  String get retryAgain => 'Tentar de novo';

  @override
  String get delete => 'Apagar';

  @override
  String get deleteChat => 'Apagar conversa';

  @override
  String get deleteChatTitle => 'Apagar conversa?';

  @override
  String get deleteChatBody =>
      'Esta conversa será apagada e não poderá ser recuperada.';

  @override
  String get deleteFailed => 'Falha ao apagar.';

  @override
  String get loadChatsFailed => 'Não foi possível carregar suas conversas.';

  @override
  String get noChatsYet => 'Nenhuma conversa por aqui ainda.';

  @override
  String exchanges(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count trocas',
      one: '$count troca',
    );
    return '$_temp0';
  }

  @override
  String get splashTagline => 'Seus investimentos, sob controle.';

  @override
  String get chartError => 'Erro ao carregar o gráfico';

  @override
  String get noData => 'Sem dados';

  @override
  String get dirUp => 'Alta';

  @override
  String get dirFlat => 'Estável';

  @override
  String get dirDown => 'Baixa';

  @override
  String get field => 'Campo';

  @override
  String fieldRequired(String label) {
    return '$label obrigatório';
  }

  @override
  String get emailRequired => 'Email obrigatório';

  @override
  String get emailInvalid => 'Email inválido';

  @override
  String get passwordRequired => 'Senha obrigatória';

  @override
  String get passwordMin => 'Mínimo 6 caracteres';

  @override
  String get chatGreeting =>
      'Olá! Sou seu Consultor de Ativos. Posso analisar sua watchlist, buscar cotações, dividendos e notícias ao vivo, e explicar indicadores. O que deseja saber?';

  @override
  String get personalInfo => 'Informações';

  @override
  String get watchlistHint =>
      'Busque e selecione os ativos que deseja monitorar.';
}
