import 'dart:convert';

import 'ai_chat_models.dart';

/// Eventos do stream SSE de `POST /ai/chat/stream`.
sealed class AgentEvent {
  const AgentEvent();

  /// Retorna null para frame malformado ou evento desconhecido — o servidor
  /// pode ganhar eventos novos e o chat não deve cair por causa disso.
  static AgentEvent? parse(String evento, String dados) {
    final Map<String, dynamic> j;
    try {
      final decoded = jsonDecode(dados);
      if (decoded is! Map<String, dynamic>) return null;
      j = decoded;
    } catch (_) {
      return null;
    }
    return switch (evento) {
      'start' => StartEvent(
          sessionId: j['session_id'] as String? ?? '',
          provider: j['provider'] as String? ?? '',
          model: j['model'] as String? ?? '',
        ),
      'token' => TokenEvent(j['content'] as String? ?? ''),
      'tool' => ToolEvent(j['name'] as String?),
      'done' => DoneEvent(
          sessionId: j['session_id'] as String? ?? '',
          provider: j['provider'] as String? ?? '',
          model: j['model'] as String? ?? '',
          content: j['content'] as String? ?? '',
        ),
      'error' => ErrorEvent(
          detail: j['detail'] as String? ?? 'Erro desconhecido',
          sessionId: j['session_id'] as String?,
        ),
      _ => null,
    };
  }
}

/// Sempre o primeiro evento. Traz o `session_id` — persista aqui, não no done.
class StartEvent extends AgentEvent {
  final String sessionId;
  final String provider;
  final String model;

  const StartEvent({
    required this.sessionId,
    required this.provider,
    required this.model,
  });
}

/// Pedaço de texto. Concatene na ordem de chegada.
class TokenEvent extends AgentEvent {
  final String content;
  const TokenEvent(this.content);
}

/// O agente começou a executar uma ferramenta. `name` pode vir null.
class ToolEvent extends AgentEvent {
  final String? name;
  const ToolEvent(this.name);

  String get rotulo => AiTools.rotulo(name);

  bool get alteraWatchlist => AiTools.alteraWatchlist(name);
}

/// Único terminador legítimo. `content` traz a resposta inteira.
class DoneEvent extends AgentEvent {
  final String sessionId;
  final String provider;
  final String model;
  final String content;

  const DoneEvent({
    required this.sessionId,
    required this.provider,
    required this.model,
    required this.content,
  });
}

/// Falha. Pode ser fatal (stream fecha sem `done`) ou parcial (stream segue).
class ErrorEvent extends AgentEvent {
  final String detail;
  final String? sessionId;
  const ErrorEvent({required this.detail, this.sessionId});
}
