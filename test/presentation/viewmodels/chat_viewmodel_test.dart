import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:easy_finance/data/models/agent_event.dart';
import 'package:easy_finance/data/models/ai_chat_models.dart';
import 'package:easy_finance/data/repositories/ai_chat_repository_impl.dart';
import 'package:easy_finance/domain/repositories/chat_repository.dart';
import 'package:easy_finance/presentation/viewmodels/chat_viewmodel.dart';

/// Repositório de teste que devolve uma sequência de eventos SSE controlada.
class FakeChatRepository implements ChatRepository {
  FakeChatRepository({
    this.eventos = const [],
    this.erroAoAbrir,
    this.historico = const [],
  });

  List<AgentEvent> eventos;
  Object? erroAoAbrir;
  List<AiHistoryMessage> historico;

  String? ultimaSessionIdEnviada;
  String? ultimaMensagem;
  final List<String> apagadas = [];

  @override
  Stream<AgentEvent> streamMessage({
    required String message,
    String? sessionId,
  }) async* {
    ultimaMensagem = message;
    ultimaSessionIdEnviada = sessionId;
    if (erroAoAbrir != null) throw erroAoAbrir!;
    for (final e in eventos) {
      yield e;
    }
  }

  @override
  Future<AiChatResponse> sendMessage({
    required String message,
    String? sessionId,
  }) =>
      throw UnimplementedError();

  @override
  Future<List<AiSessionInfo>> listSessions({int limit = 50}) async => const [];

  @override
  Future<List<AiHistoryMessage>> loadHistory(String sessionId) async =>
      historico;

  @override
  Future<AiSessionSummary> summary(String sessionId) =>
      throw UnimplementedError();

  @override
  Future<void> deleteSession(String sessionId) async =>
      apagadas.add(sessionId);
}

const _start = StartEvent(
  sessionId: 'sess-1',
  provider: 'gemini',
  model: 'gemini-3.5-flash',
);

const _done = DoneEvent(
  sessionId: 'sess-1',
  provider: 'gemini',
  model: 'gemini-3.5-flash',
  content: 'Resposta completa',
);

void main() {
  late FakeChatRepository fake;

  setUp(() => fake = FakeChatRepository());

  ProviderContainer buildContainer() {
    final container = ProviderContainer(
      overrides: [chatRepositoryProvider.overrideWithValue(fake)],
    );
    addTearDown(container.dispose);
    return container;
  }

  group('ChatNotifier', () {
    test('estado inicial tem a saudação e não está digitando', () {
      final state = buildContainer().read(chatNotifierProvider);
      expect(state.messages.length, 1);
      expect(state.messages.first.isUser, false);
      expect(state.typing, false);
      expect(state.sessionId, isNull);
    });

    test('send vazio não altera o estado', () async {
      final container = buildContainer();
      final antes = container.read(chatNotifierProvider).messages.length;

      await container.read(chatNotifierProvider.notifier).send('   ');

      expect(container.read(chatNotifierProvider).messages.length, antes);
    });

    test('send acima de 4000 caracteres não chama a API e reporta erro',
        () async {
      final container = buildContainer();

      await container
          .read(chatNotifierProvider.notifier)
          .send('a' * (kChatMaxMessageLength + 1));

      final state = container.read(chatNotifierProvider);
      expect(fake.ultimaMensagem, isNull);
      expect(state.error, isNotNull);
      expect(state.typing, false);
    });

    test('stream completo anexa mensagem do usuário e a resposta do done',
        () async {
      fake.eventos = [_start, const TokenEvent('Res'), _done];
      final container = buildContainer();

      await container.read(chatNotifierProvider.notifier).send('oi');

      final state = container.read(chatNotifierProvider);
      expect(state.typing, false);
      expect(state.messages.length, 3);
      expect(state.messages[1].isUser, true);
      expect(state.messages[1].text, 'oi');
      // done é a fonte da verdade, não a concatenação de tokens.
      expect(state.messages.last.text, 'Resposta completa');
      expect(state.streamingText, isEmpty);
      expect(state.error, isNull);
    });

    test('session_id vem do evento start e é reenviado na mensagem seguinte',
        () async {
      fake.eventos = [_start, _done];
      final container = buildContainer();
      final notifier = container.read(chatNotifierProvider.notifier);

      await notifier.send('primeira');
      expect(container.read(chatNotifierProvider).sessionId, 'sess-1');
      expect(fake.ultimaSessionIdEnviada, isNull);

      await notifier.send('segunda');
      expect(fake.ultimaSessionIdEnviada, 'sess-1');
    });

    test('evento tool vira rótulo de progresso', () async {
      final labels = <String?>[];
      fake.eventos = [_start, const ToolEvent('cotacao_atual'), _done];
      final container = buildContainer();
      container.listen(
        chatNotifierProvider,
        (_, next) => labels.add(next.toolLabel),
        fireImmediately: false,
      );

      await container.read(chatNotifierProvider.notifier).send('preço da PETR4');

      expect(labels, contains('Consultando cotação…'));
      expect(container.read(chatNotifierProvider).toolLabel, isNull);
    });

    test('stream que fecha sem done reporta o último erro', () async {
      fake.eventos = [_start, const ErrorEvent(detail: 'modelo caiu')];
      final container = buildContainer();

      await container.read(chatNotifierProvider.notifier).send('oi');

      final state = container.read(chatNotifierProvider);
      expect(state.typing, false);
      expect(state.error, 'modelo caiu');
    });

    test('stream que fecha sem done preserva o texto parcial recebido',
        () async {
      fake.eventos = [_start, const TokenEvent('metade da '), const TokenEvent('resposta')];
      final container = buildContainer();

      await container.read(chatNotifierProvider.notifier).send('oi');

      final state = container.read(chatNotifierProvider);
      expect(state.messages.last.text, 'metade da resposta');
      expect(state.error, 'A resposta foi interrompida.');
      expect(state.typing, false);
    });

    test('erro HTTP antes do stream vira mensagem amigável', () async {
      fake.erroAoAbrir = const AiApiException(401, 'Not authenticated');
      final container = buildContainer();

      await container.read(chatNotifierProvider.notifier).send('oi');

      final state = container.read(chatNotifierProvider);
      expect(state.typing, false);
      expect(state.error, 'Sua sessão expirou. Entre novamente.');
    });

    test('send é ignorado enquanto há resposta em andamento', () async {
      final container = buildContainer();
      final notifier = container.read(chatNotifierProvider.notifier);

      fake.eventos = [_start, _done];
      final primeira = notifier.send('primeira');
      expect(container.read(chatNotifierProvider).typing, true);

      await notifier.send('segunda');
      expect(fake.ultimaMensagem, 'primeira');

      await primeira;
    });

    test('clear zera mensagens e a sessão', () async {
      fake.eventos = [_start, _done];
      final container = buildContainer();
      final notifier = container.read(chatNotifierProvider.notifier);

      await notifier.send('oi');
      expect(container.read(chatNotifierProvider).sessionId, 'sess-1');

      notifier.clear();

      final state = container.read(chatNotifierProvider);
      expect(state.messages, isEmpty);
      expect(state.sessionId, isNull);
      expect(state.typing, false);
    });

    test('abrirConversa carrega o histórico filtrado da sessão', () async {
      fake.historico = [
        AiHistoryMessage(role: 'user', content: 'o que é ROE?', createdAt: null),
        AiHistoryMessage(
            role: 'assistant', content: '**ROE**…', createdAt: null),
      ];
      final container = buildContainer();

      await container.read(chatNotifierProvider.notifier).abrirConversa('s-9');

      final state = container.read(chatNotifierProvider);
      expect(state.sessionId, 's-9');
      expect(state.messages.length, 2);
      expect(state.messages.first.isUser, true);
      expect(state.typing, false);
    });

    test('apagarConversa da sessão atual limpa a tela', () async {
      fake.eventos = [_start, _done];
      final container = buildContainer();
      final notifier = container.read(chatNotifierProvider.notifier);

      await notifier.send('oi');
      await notifier.apagarConversa('sess-1');

      expect(fake.apagadas, ['sess-1']);
      expect(container.read(chatNotifierProvider).messages, isEmpty);
    });
  });
}
