import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/agent_event.dart';
import '../../data/models/ai_chat_models.dart';
import '../../data/repositories/ai_chat_repository_impl.dart';
import 'home_viewmodel.dart';

const String kChatGreeting =
    'Olá! Sou seu Consultor de Ativos. Posso analisar sua watchlist, buscar '
    'cotações, dividendos e notícias ao vivo, e explicar indicadores. '
    'O que deseja saber?';

/// Limite do backend: fora de 1–4000 caracteres a API devolve 422.
const int kChatMaxMessageLength = 4000;

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final bool isError;

  const ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.isError = false,
  });
}

class ChatState {
  final List<ChatMessage> messages;

  /// Há uma resposta em andamento (aguardando ou recebendo tokens).
  final bool typing;

  /// Texto recebido até agora na resposta em andamento.
  final String streamingText;

  /// Rótulo da ferramenta em execução, ex. "Consultando cotação…".
  final String? toolLabel;

  /// Conversa atual no servidor. Null enquanto nenhuma foi criada.
  final String? sessionId;

  /// Erro da última tentativa, para exibir um aviso reenviável.
  final String? error;

  const ChatState({
    this.messages = const [],
    this.typing = false,
    this.streamingText = '',
    this.toolLabel,
    this.sessionId,
    this.error,
  });

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? typing,
    String? streamingText,
    String? toolLabel,
    String? sessionId,
    String? error,
    bool clearToolLabel = false,
    bool clearError = false,
  }) =>
      ChatState(
        messages: messages ?? this.messages,
        typing: typing ?? this.typing,
        streamingText: streamingText ?? this.streamingText,
        toolLabel: clearToolLabel ? null : (toolLabel ?? this.toolLabel),
        sessionId: sessionId ?? this.sessionId,
        error: clearError ? null : (error ?? this.error),
      );
}

class ChatNotifier extends StateNotifier<ChatState> {
  final Ref _ref;
  StreamSubscription<AgentEvent>? _sub;

  ChatNotifier(this._ref)
      : super(
          ChatState(
            messages: [
              ChatMessage(
                text: kChatGreeting,
                isUser: false,
                timestamp: DateTime.now(),
              ),
            ],
          ),
        );

  /// Sem nenhum evento por 90 s a conexão está morta. Não limita a duração
  /// total da resposta, que pode passar de 30 s legitimamente.
  static const _semEventos = Duration(seconds: 90);

  Future<void> send(String text) async {
    final mensagem = text.trim();
    if (mensagem.isEmpty || state.typing) return;

    if (mensagem.length > kChatMaxMessageLength) {
      state = state.copyWith(
        error: 'Mensagem longa demais '
            '(${mensagem.length}/$kChatMaxMessageLength caracteres).',
      );
      return;
    }

    final userMsg = ChatMessage(
      text: mensagem,
      isUser: true,
      timestamp: DateTime.now(),
    );
    state = state.copyWith(
      messages: [...state.messages, userMsg],
      typing: true,
      streamingText: '',
      clearToolLabel: true,
      clearError: true,
    );

    final concluida = Completer<void>();
    // done é o ÚNICO terminador legítimo: fechar sem ele = erro fatal.
    var terminouLimpo = false;
    String? ultimoErro;
    var watchlistMudou = false;

    _sub = _ref
        .read(chatRepositoryProvider)
        .streamMessage(message: mensagem, sessionId: state.sessionId)
        .timeout(_semEventos)
        .listen(
      (evento) {
        switch (evento) {
          case StartEvent(sessionId: final novoId):
            // Persiste já: se o app fechar no meio, a conversa não se perde.
            if (novoId.isNotEmpty) {
              state = state.copyWith(sessionId: novoId);
            }

          case TokenEvent(:final content):
            state = state.copyWith(
              streamingText: state.streamingText + content,
              clearToolLabel: true,
            );

          case ToolEvent():
            if (evento.alteraWatchlist) watchlistMudou = true;
            state = state.copyWith(toolLabel: evento.rotulo);

          case DoneEvent(:final content):
            // content traz a resposta inteira — mais confiável que a
            // concatenação dos tokens.
            final texto = content.isNotEmpty ? content : state.streamingText;
            terminouLimpo = true;
            state = state.copyWith(
              messages: [
                ...state.messages,
                ChatMessage(
                  text: texto,
                  isUser: false,
                  timestamp: DateTime.now(),
                ),
              ],
              streamingText: '',
              clearToolLabel: true,
            );

          case ErrorEvent(:final detail):
            // Pode ser parcial: o stream ainda pode terminar com done.
            ultimoErro = detail;
        }
      },
      onError: (Object e) {
        _finalizar(
          erro: e is AiApiException
              ? e.mensagemAmigavel
              : e is TimeoutException
                  ? 'O assistente parou de responder. Tente de novo.'
                  : 'Falha de conexão com o assistente.',
        );
        if (!concluida.isCompleted) concluida.complete();
      },
      onDone: () {
        if (terminouLimpo) {
          _finalizar();
          if (watchlistMudou) _invalidarWatchlist();
        } else {
          // Fechou sem done: o último error era fatal.
          _finalizar(erro: ultimoErro ?? 'A resposta foi interrompida.');
        }
        if (!concluida.isCompleted) concluida.complete();
      },
      cancelOnError: true,
    );

    return concluida.future;
  }

  /// Encerra a resposta em andamento preservando o texto já recebido.
  void _finalizar({String? erro}) {
    final parcial = state.streamingText;
    state = state.copyWith(
      messages: parcial.isEmpty
          ? state.messages
          : [
              ...state.messages,
              ChatMessage(
                text: parcial,
                isUser: false,
                timestamp: DateTime.now(),
              ),
            ],
      typing: false,
      streamingText: '',
      clearToolLabel: true,
      error: erro,
      clearError: erro == null,
    );
  }

  /// O agente pode escrever na watchlist — o cache local fica velho.
  void _invalidarWatchlist() {
    try {
      _ref.read(homeNotifierProvider.notifier).load(refresh: true);
    } catch (_) {
      // Home ainda não montada: nada a invalidar.
    }
  }

  /// Interrompe a resposta atual sem perder o que já chegou.
  void cancelar() {
    if (!state.typing) return;
    _sub?.cancel();
    _sub = null;
    _finalizar();
  }

  /// Zera a tela e começa uma conversa nova no servidor.
  void clear() {
    _sub?.cancel();
    _sub = null;
    state = const ChatState();
  }

  Future<List<AiSessionInfo>> listarConversas({int limit = 50}) =>
      _ref.read(chatRepositoryProvider).listSessions(limit: limit);

  /// Abre uma conversa existente e carrega o histórico dela na tela.
  Future<void> abrirConversa(String sessionId) async {
    _sub?.cancel();
    _sub = null;
    state = ChatState(sessionId: sessionId, typing: true);
    try {
      final historico =
          await _ref.read(chatRepositoryProvider).loadHistory(sessionId);
      state = ChatState(
        sessionId: sessionId,
        messages: historico
            .map((m) => ChatMessage(
                  text: m.content,
                  isUser: m.ehDoUsuario,
                  timestamp: m.createdAt ?? DateTime.now(),
                ))
            .toList(),
      );
    } catch (e) {
      state = ChatState(
        sessionId: sessionId,
        error: e is AiApiException
            ? e.mensagemAmigavel
            : 'Não foi possível carregar a conversa.',
      );
    }
  }

  Future<void> apagarConversa(String sessionId) async {
    await _ref.read(chatRepositoryProvider).deleteSession(sessionId);
    if (state.sessionId == sessionId) clear();
  }

  void limparErro() {
    if (state.error != null) state = state.copyWith(clearError: true);
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

final chatNotifierProvider =
    StateNotifierProvider<ChatNotifier, ChatState>((ref) => ChatNotifier(ref));
