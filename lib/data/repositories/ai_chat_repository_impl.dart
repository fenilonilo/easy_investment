import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/repositories/chat_repository.dart';
import '../datasources/ai_agent_remote_datasource.dart';
import '../models/agent_event.dart';
import '../models/ai_chat_models.dart';

class AiChatRepositoryImpl implements ChatRepository {
  final AiAgentRemoteDataSource _remote;

  AiChatRepositoryImpl(this._remote);

  @override
  Stream<AgentEvent> streamMessage({
    required String message,
    String? sessionId,
  }) =>
      _remote.chatStream(message: message, sessionId: sessionId);

  @override
  Future<AiChatResponse> sendMessage({
    required String message,
    String? sessionId,
  }) =>
      _remote.chat(message: message, sessionId: sessionId);

  @override
  Future<List<AiSessionInfo>> listSessions({int limit = 50}) =>
      _remote.listSessions(limit: limit);

  @override
  Future<List<AiHistoryMessage>> loadHistory(String sessionId) =>
      _remote.history(sessionId);

  @override
  Future<AiSessionSummary> summary(String sessionId) =>
      _remote.summary(sessionId);

  @override
  Future<void> deleteSession(String sessionId) =>
      _remote.deleteSession(sessionId);
}

final chatRepositoryProvider = Provider<ChatRepository>(
  (ref) => AiChatRepositoryImpl(ref.read(aiAgentRemoteDataSourceProvider)),
);
