import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:easy_finance/data/models/agent_event.dart';
import 'package:easy_finance/data/models/ai_chat_models.dart';
import 'package:easy_finance/domain/repositories/chat_repository.dart';

/// Adapter do Dio sem rede: responde roteiro fixo ou pendura para sempre.
class T3ScriptedAdapter implements HttpClientAdapter {
  T3ScriptedAdapter(this.handler);

  /// Requisição que nunca responde (simula backend/proxy pendurado).
  T3ScriptedAdapter.hanging() : handler = null;

  final Future<ResponseBody> Function(RequestOptions o)? handler;
  final hang = Completer<ResponseBody>();

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    final h = handler;
    return h == null ? hang.future : h(options);
  }

  @override
  void close({bool force = false}) {}

  static ResponseBody json(Object body, {int status = 200}) =>
      ResponseBody.fromString(
        jsonEncode(body),
        status,
        headers: {
          Headers.contentTypeHeader: ['application/json'],
        },
      );
}

Dio t3Dio(HttpClientAdapter adapter) =>
    Dio(BaseOptions(baseUrl: 'http://fake.local'))..httpClientAdapter = adapter;

/// ChatRepository fake com sessões listáveis e registro de chamadas.
class T3FakeChatRepository implements ChatRepository {
  T3FakeChatRepository({
    this.eventos = const [],
    this.historico = const [],
    this.sessoes = const [],
  });

  List<AgentEvent> eventos;
  List<AiHistoryMessage> historico;
  List<AiSessionInfo> sessoes;
  String? ultimaSessionIdEnviada;
  final List<String> apagadas = [];

  @override
  Stream<AgentEvent> streamMessage({
    required String message,
    String? sessionId,
  }) async* {
    ultimaSessionIdEnviada = sessionId;
    for (final e in eventos) {
      yield e;
    }
  }

  @override
  Future<List<AiSessionInfo>> listSessions({int limit = 50}) async => sessoes;

  @override
  Future<List<AiHistoryMessage>> loadHistory(String sessionId) async =>
      historico;

  @override
  Future<void> deleteSession(String sessionId) async => apagadas.add(sessionId);

  @override
  Future<AiChatResponse> sendMessage({
    required String message,
    String? sessionId,
  }) => throw UnimplementedError();

  @override
  Future<AiSessionSummary> summary(String sessionId) =>
      throw UnimplementedError();
}
