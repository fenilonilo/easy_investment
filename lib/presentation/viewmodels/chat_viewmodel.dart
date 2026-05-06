import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/mock_chat_repository.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  const ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

class ChatState {
  final List<ChatMessage> messages;
  final bool typing;

  const ChatState({this.messages = const [], this.typing = false});

  ChatState copyWith({List<ChatMessage>? messages, bool? typing}) =>
      ChatState(
        messages: messages ?? this.messages,
        typing: typing ?? this.typing,
      );
}

class ChatNotifier extends StateNotifier<ChatState> {
  final Ref _ref;

  ChatNotifier(this._ref)
      : super(
          ChatState(
            messages: [
              ChatMessage(
                text:
                    'Olá! Sou seu assistente financeiro. Posso te ajudar com análise de ativos, conceitos de investimento e interpretação de dados da sua watchlist. O que deseja saber?',
                isUser: false,
                timestamp: DateTime.now(),
              ),
            ],
          ),
        );

  Future<void> send(String text) async {
    if (text.trim().isEmpty) return;

    final userMsg = ChatMessage(
      text: text.trim(),
      isUser: true,
      timestamp: DateTime.now(),
    );
    state = state.copyWith(
      messages: [...state.messages, userMsg],
      typing: true,
    );

    try {
      final repo = _ref.read(chatRepositoryProvider);
      final reply = await repo.sendMessage(text);
      final aiMsg = ChatMessage(
        text: reply,
        isUser: false,
        timestamp: DateTime.now(),
      );
      state = state.copyWith(
        messages: [...state.messages, aiMsg],
        typing: false,
      );
    } catch (_) {
      final errMsg = ChatMessage(
        text: 'Erro ao processar resposta. Tente novamente.',
        isUser: false,
        timestamp: DateTime.now(),
      );
      state = state.copyWith(
        messages: [...state.messages, errMsg],
        typing: false,
      );
    }
  }

  void clear() {
    state = const ChatState();
  }
}

final chatNotifierProvider =
    StateNotifierProvider<ChatNotifier, ChatState>((ref) => ChatNotifier(ref));
