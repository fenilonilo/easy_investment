import '../../data/models/agent_event.dart';
import '../../data/models/ai_chat_models.dart';

/// Consultor de Ativos — agente de IA do backend (`/ai`).
///
/// O servidor guarda o histórico por sessão: envie apenas a mensagem nova.
/// Omitir [sessionId] começa uma conversa; o id criado volta no `start`.
abstract class ChatRepository {
  /// Conversa em streaming. Trate `done` como único terminador legítimo.
  Stream<AgentEvent> streamMessage({
    required String message,
    String? sessionId,
  });

  /// Conversa em JSON, resposta completa de uma vez.
  Future<AiChatResponse> sendMessage({
    required String message,
    String? sessionId,
  });

  Future<List<AiSessionInfo>> listSessions({int limit});

  /// Já filtrado: só `user` e `assistant` com conteúdo.
  Future<List<AiHistoryMessage>> loadHistory(String sessionId);

  Future<AiSessionSummary> summary(String sessionId);

  Future<void> deleteSession(String sessionId);
}
