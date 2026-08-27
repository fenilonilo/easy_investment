/// Modelos do agente de IA (`/ai/*`).
///
/// Escritos à mão de propósito: o contrato tem duas convenções de data
/// diferentes e campos que mudam de tipo conforme o erro, o que code-gen
/// resolveria mal.
library;

/// Resposta de `POST /ai/chat`.
class AiChatResponse {
  final String sessionId;
  final String? runId;

  /// Markdown.
  final String content;

  /// `gemini` ou `groq`.
  final String provider;
  final String modelUsed;
  final List<String> toolsUsed;

  const AiChatResponse({
    required this.sessionId,
    required this.runId,
    required this.content,
    required this.provider,
    required this.modelUsed,
    required this.toolsUsed,
  });

  factory AiChatResponse.fromJson(Map<String, dynamic> json) => AiChatResponse(
        sessionId: json['session_id'] as String? ?? '',
        runId: json['run_id'] as String?,
        content: json['content'] as String? ?? '',
        provider: json['provider'] as String? ?? '',
        modelUsed: json['model_used'] as String? ?? '',
        toolsUsed:
            (json['tools_used'] as List?)?.cast<String>() ?? const <String>[],
      );

  bool get alterouWatchlist => toolsUsed.any(AiTools.alteraWatchlist);
}

/// Item de `GET /ai/sessions`. Timestamps são inteiros unix em segundos.
class AiSessionInfo {
  final String sessionId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int runsCount;
  final String? summary;
  final List<String> topics;

  const AiSessionInfo({
    required this.sessionId,
    required this.createdAt,
    required this.updatedAt,
    required this.runsCount,
    required this.summary,
    required this.topics,
  });

  static DateTime? fromUnix(dynamic v) => v is int
      ? DateTime.fromMillisecondsSinceEpoch(v * 1000, isUtc: true).toLocal()
      : null;

  factory AiSessionInfo.fromJson(Map<String, dynamic> json) => AiSessionInfo(
        sessionId: json['session_id'] as String? ?? '',
        createdAt: fromUnix(json['created_at']),
        updatedAt: fromUnix(json['updated_at']),
        runsCount: json['runs_count'] as int? ?? 0,
        summary: json['summary'] as String?,
        topics: (json['topics'] as List?)?.cast<String>() ?? const <String>[],
      );

  /// `summary` vem null em conversas curtas — sempre com fallback.
  String get titulo => (summary != null && summary!.trim().isNotEmpty)
      ? summary!
      : 'Nova conversa';
}

/// Mensagem de `GET /ai/sessions/{id}`.
class AiHistoryMessage {
  /// `user`, `assistant`, `system` ou `tool`.
  final String role;
  final String content;
  final DateTime? createdAt;

  const AiHistoryMessage({
    required this.role,
    required this.content,
    required this.createdAt,
  });

  factory AiHistoryMessage.fromJson(Map<String, dynamic> json) =>
      AiHistoryMessage(
        role: json['role'] as String? ?? '',
        content: json['content'] as String? ?? '',
        createdAt: AiSessionInfo.fromUnix(json['created_at']),
      );

  bool get ehDoUsuario => role == 'user';

  /// `system` e `tool` são internos do agente — nunca vão para a tela.
  bool get exibivel =>
      (role == 'user' || role == 'assistant') && content.trim().isNotEmpty;
}

/// Resposta de `GET /ai/sessions/{id}/summary`.
class AiSessionSummary {
  final String sessionId;
  final String? summary;
  final List<String> topics;
  final DateTime? updatedAt;

  const AiSessionSummary({
    required this.sessionId,
    required this.summary,
    required this.topics,
    required this.updatedAt,
  });

  factory AiSessionSummary.fromJson(Map<String, dynamic> json) =>
      AiSessionSummary(
        sessionId: json['session_id'] as String? ?? '',
        summary: json['summary'] as String?,
        topics: (json['topics'] as List?)?.cast<String>() ?? const <String>[],
        // Aqui updated_at é ISO 8601 (string), não unix — diferente de
        // AiSessionInfo. Reaproveitar o mesmo parser quebra em runtime.
        updatedAt: json['updated_at'] is String
            ? DateTime.tryParse(json['updated_at'] as String)
            : null,
      );
}

/// Nomes de ferramentas do agente e os rótulos exibidos durante a execução.
class AiTools {
  const AiTools._();

  static bool alteraWatchlist(String? name) =>
      name == 'adicionar_a_watchlist' || name == 'remover_da_watchlist';

  /// `name` pode vir null no evento `tool` — daí o fallback genérico.
  static String rotulo(String? name) => switch (name) {
        'cotacao_atual' || 'get_current_stock_price' => 'Consultando cotação…',
        'historico_precos' ||
        'get_historical_stock_prices' =>
          'Buscando histórico…',
        'resumo_financeiro' ||
        'get_stock_fundamentals' ||
        'get_key_financial_ratios' =>
          'Lendo indicadores…',
        'historico_dividendos' => 'Verificando dividendos…',
        'noticias_do_ativo' || 'get_company_news' => 'Lendo notícias…',
        'buscar_ativos' => 'Procurando o ativo…',
        'adicionar_a_watchlist' ||
        'remover_da_watchlist' =>
          'Atualizando sua watchlist…',
        _ => 'Pesquisando…',
      };
}

/// Erro do agente já traduzido para mensagem de tela.
class AiApiException implements Exception {
  final int? statusCode;
  final String message;

  const AiApiException(this.statusCode, this.message);

  /// `detail` é string em 401/404/502 e **lista** em 422 (validação FastAPI).
  factory AiApiException.fromDetail(int? status, dynamic body) {
    String detalhe;
    final d = body is Map ? body['detail'] : body;
    if (d is String && d.trim().isNotEmpty) {
      detalhe = d;
    } else if (d is List && d.isNotEmpty) {
      final primeiro = d.first;
      detalhe = primeiro is Map ? '${primeiro['msg']}' : d.toString();
    } else {
      detalhe = body == null ? 'Erro $status' : body.toString();
    }
    return AiApiException(status, detalhe);
  }

  String get mensagemAmigavel => switch (statusCode) {
        401 => 'Sua sessão expirou. Entre novamente.',
        404 => 'Conversa não encontrada.',
        422 => 'Mensagem inválida: $message',
        502 => 'O assistente está indisponível. Tente em alguns instantes.',
        _ => message,
      };

  @override
  String toString() => 'AiApiException($statusCode): $message';
}
