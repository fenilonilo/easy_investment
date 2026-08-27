import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/agent_event.dart';
import '../models/ai_chat_models.dart';
import 'api_endpoints.dart';
import 'dio_client.dart';

/// Acesso aos endpoints `/ai` do Consultor de Ativos.
class AiAgentRemoteDataSource {
  final Dio _dio;

  AiAgentRemoteDataSource(this._dio);

  /// O agente encadeia ferramentas: 30 s+ é normal na rota não-streaming.
  static const _chatTimeout = Duration(seconds: 120);

  // ------------------------------------------------------------------ chat

  Future<AiChatResponse> chat({
    required String message,
    String? sessionId,
  }) async {
    try {
      final r = await _dio.post(
        ApiEndpoints.aiChat,
        data: _chatBody(message, sessionId),
        options: Options(receiveTimeout: _chatTimeout),
      );
      return AiChatResponse.fromJson(r.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw await _toApiException(e);
    }
  }

  /// Stream SSE. Erros de verdade (401/404/422) chegam **antes** do stream
  /// abrir e viram [AiApiException]; falha posterior chega como [ErrorEvent].
  Stream<AgentEvent> chatStream({
    required String message,
    String? sessionId,
  }) async* {
    final Response<ResponseBody> response;
    try {
      response = await _dio.post<ResponseBody>(
        ApiEndpoints.aiChatStream,
        data: _chatBody(message, sessionId),
        options: Options(
          responseType: ResponseType.stream,
          headers: {'Accept': 'text/event-stream'},
          // Duration.zero desliga o timeout do dio: a espera entre eventos é
          // controlada pelo chamador, com timeout por evento.
          //
          // connectTimeout também precisa ir a zero POR CAUSA DA WEB: o adapter
          // faz `xhr.timeout = connectTimeout + receiveTimeout`, e esse é um
          // prazo TOTAL do request, que não reseta a cada evento recebido.
          // Deixar só o connectTimeout do BaseOptions (15 s) matava qualquer
          // resposta que encadeasse ferramentas por mais que isso, no meio do
          // stream, com DioExceptionType.receiveTimeout.
          connectTimeout: Duration.zero,
          receiveTimeout: Duration.zero,
        ),
      );
    } on DioException catch (e) {
      throw await _toApiException(e);
    }

    // utf8.decoder como transformer guarda estado entre chunks: um caractere
    // acentuado partido entre dois pacotes é remontado corretamente.
    final linhas = response.data!.stream
        .cast<List<int>>()
        .transform(utf8.decoder)
        .transform(const LineSplitter());

    String? nomeEvento;
    final linhasDeDados = <String>[];

    AgentEvent? fecharFrame() {
      if (nomeEvento == null || linhasDeDados.isEmpty) return null;
      final evento = AgentEvent.parse(nomeEvento!, linhasDeDados.join('\n'));
      nomeEvento = null;
      linhasDeDados.clear();
      return evento;
    }

    await for (final linha in linhas) {
      if (linha.isEmpty) {
        final evento = fecharFrame();
        if (evento != null) yield evento;
        continue;
      }
      if (linha.startsWith(':')) continue; // keep-alive
      if (linha.startsWith('event:')) {
        nomeEvento = linha.substring(6).trim();
      } else if (linha.startsWith('data:')) {
        // Um único espaço após 'data:' faz parte do protocolo e é descartado;
        // qualquer outro espaço é conteúdo.
        var valor = linha.substring(5);
        if (valor.startsWith(' ')) valor = valor.substring(1);
        linhasDeDados.add(valor);
      }
    }

    // Frame final sem linha em branco no fim: emite mesmo assim.
    final ultimo = fecharFrame();
    if (ultimo != null) yield ultimo;
  }

  // --------------------------------------------------------------- sessões

  Future<List<AiSessionInfo>> listSessions({int limit = 50}) async {
    try {
      final r = await _dio.get(
        ApiEndpoints.aiSessions,
        queryParameters: {'limit': limit},
      );
      return (r.data as List)
          .map((e) => AiSessionInfo.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw await _toApiException(e);
    }
  }

  /// Devolve só o que vai para a tela — `system` e `tool` ficam de fora.
  Future<List<AiHistoryMessage>> history(String sessionId) async {
    try {
      final r = await _dio.get(ApiEndpoints.aiSession(sessionId));
      final json = r.data as Map<String, dynamic>;
      return (json['messages'] as List? ?? const [])
          .map((e) => AiHistoryMessage.fromJson(e as Map<String, dynamic>))
          .where((m) => m.exibivel)
          .toList();
    } on DioException catch (e) {
      throw await _toApiException(e);
    }
  }

  Future<AiSessionSummary> summary(String sessionId) async {
    try {
      final r = await _dio.get(ApiEndpoints.aiSessionSummary(sessionId));
      return AiSessionSummary.fromJson(r.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw await _toApiException(e);
    }
  }

  /// Responde 204 sem corpo — não decodifique a resposta.
  Future<void> deleteSession(String sessionId) async {
    try {
      await _dio.delete(ApiEndpoints.aiSession(sessionId));
    } on DioException catch (e) {
      throw await _toApiException(e);
    }
  }

  // ---------------------------------------------------------------- helpers

  Map<String, dynamic> _chatBody(String message, String? sessionId) => {
        'message': message,
        // Omitido quando null: a API rejeita session_id nulo explícito.
        'session_id': ?sessionId,
      };

  Future<AiApiException> _toApiException(DioException e) async {
    final status = e.response?.statusCode;
    if (status == null) {
      return AiApiException(null, _mensagemDeRede(e));
    }
    return AiApiException.fromDetail(status, await _corpoDoErro(e.response));
  }

  /// Com `ResponseType.stream` o corpo do erro vem como [ResponseBody] e
  /// precisa ser drenado à mão antes de virar JSON.
  Future<dynamic> _corpoDoErro(Response? response) async {
    final data = response?.data;
    if (data is ResponseBody) {
      try {
        final bytes = await data.stream
            .cast<List<int>>()
            .fold<List<int>>(<int>[], (acc, chunk) => acc..addAll(chunk));
        if (bytes.isEmpty) return null;
        return jsonDecode(utf8.decode(bytes));
      } catch (_) {
        return null;
      }
    }
    if (data is String) {
      try {
        return jsonDecode(data);
      } catch (_) {
        return data;
      }
    }
    return data;
  }

  String _mensagemDeRede(DioException e) => switch (e.type) {
        DioExceptionType.connectionTimeout ||
        DioExceptionType.sendTimeout ||
        DioExceptionType.receiveTimeout =>
          'O assistente demorou demais para responder. Tente de novo.',
        DioExceptionType.cancel => 'Resposta cancelada.',
        _ => 'Não foi possível falar com o assistente. Verifique sua conexão.',
      };
}

final aiAgentRemoteDataSourceProvider = Provider<AiAgentRemoteDataSource>(
  (ref) => AiAgentRemoteDataSource(ref.read(dioClientProvider)),
);
