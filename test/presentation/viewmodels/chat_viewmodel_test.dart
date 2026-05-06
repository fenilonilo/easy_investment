import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:easy_finance/presentation/viewmodels/chat_viewmodel.dart';
import 'package:easy_finance/domain/repositories/chat_repository.dart';
import 'package:easy_finance/data/repositories/mock_chat_repository.dart';

class MockChatRepository extends Mock implements ChatRepository {}

void main() {
  late MockChatRepository mockChatRepo;

  setUp(() {
    mockChatRepo = MockChatRepository();
  });

  ProviderContainer buildContainer() {
    final container = ProviderContainer(
      overrides: [
        chatRepositoryProvider.overrideWithValue(mockChatRepo),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  group('ChatNotifier', () {
    test('initial state has 1 message and typing is false', () {
      final container = buildContainer();
      final state = container.read(chatNotifierProvider);
      expect(state.messages.length, 1);
      expect(state.typing, false);
      expect(state.messages.first.isUser, false);
    });

    test('send empty string does not change state', () async {
      final container = buildContainer();
      final initialState = container.read(chatNotifierProvider);

      await container.read(chatNotifierProvider.notifier).send('');

      final state = container.read(chatNotifierProvider);
      expect(state.messages.length, initialState.messages.length);
    });

    test('send whitespace only does not change state', () async {
      final container = buildContainer();
      final initialState = container.read(chatNotifierProvider);

      await container.read(chatNotifierProvider.notifier).send('   ');

      final state = container.read(chatNotifierProvider);
      expect(state.messages.length, initialState.messages.length);
    });

    test('send hello appends user message and AI reply, typing false after', () async {
      final container = buildContainer();

      when(() => mockChatRepo.sendMessage(any()))
          .thenAnswer((_) async => 'AI response');

      await container.read(chatNotifierProvider.notifier).send('hello');

      final state = container.read(chatNotifierProvider);
      expect(state.typing, false);
      expect(state.messages.length, 3);

      final secondToLast = state.messages[state.messages.length - 2];
      final last = state.messages.last;

      expect(secondToLast.isUser, true);
      expect(secondToLast.text, 'hello');
      expect(last.isUser, false);
      expect(last.text, 'AI response');
    });

    test('send hello while in progress sets typing to true', () async {
      final container = buildContainer();

      final completer = Future.delayed(const Duration(milliseconds: 100), () => 'AI response');
      when(() => mockChatRepo.sendMessage(any())).thenAnswer((_) => completer);

      final sendFuture = container.read(chatNotifierProvider.notifier).send('hello');

      expect(container.read(chatNotifierProvider).typing, true);

      await sendFuture;
    });

    test('clear resets state to empty ChatState', () async {
      final container = buildContainer();

      when(() => mockChatRepo.sendMessage(any()))
          .thenAnswer((_) async => 'AI response');

      await container.read(chatNotifierProvider.notifier).send('hello');
      expect(container.read(chatNotifierProvider).messages.length, greaterThan(1));

      container.read(chatNotifierProvider.notifier).clear();

      final state = container.read(chatNotifierProvider);
      expect(state.messages, isEmpty);
      expect(state.typing, false);
    });

    test('when repo throws exception send appends error message', () async {
      final container = buildContainer();

      when(() => mockChatRepo.sendMessage(any()))
          .thenThrow(Exception('Network error'));

      await container.read(chatNotifierProvider.notifier).send('hello');

      final state = container.read(chatNotifierProvider);
      expect(state.typing, false);
      expect(state.messages.length, 3);
      final last = state.messages.last;
      expect(last.isUser, false);
      expect(last.text, 'Erro ao processar resposta. Tente novamente.');
    });
  });
}
