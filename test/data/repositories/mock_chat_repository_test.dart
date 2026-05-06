import 'package:flutter_test/flutter_test.dart';
import 'package:easy_finance/data/repositories/mock_chat_repository.dart';

void main() {
  group('MockChatRepository', () {
    late MockChatRepository repository;

    setUp(() {
      repository = MockChatRepository();
    });

    test('message containing preço returns non-empty string', () async {
      final result = await repository.sendMessage('qual o preço do AAPL?');
      expect(result, isNotEmpty);
    });

    test('message containing etf returns non-empty string', () async {
      final result = await repository.sendMessage('o que é um etf?');
      expect(result, isNotEmpty);
    });

    test('message with no keywords returns non-empty string (fallback)', () async {
      final result = await repository.sendMessage('hello');
      expect(result, isNotEmpty);
    });

    test('sendMessage always completes without throwing', () async {
      expect(() async => repository.sendMessage('any message here'), returnsNormally);
      final result = await repository.sendMessage('any message here');
      expect(result, isA<String>());
    });

    test('message containing tendência returns non-empty string', () async {
      final result = await repository.sendMessage('qual a tendência do mercado?');
      expect(result, isNotEmpty);
    });

    test('message containing dividendo returns non-empty string', () async {
      final result = await repository.sendMessage('como funcionam os dividendos?');
      expect(result, isNotEmpty);
    });

    test('empty string returns non-empty string (fallback)', () async {
      final result = await repository.sendMessage('');
      expect(result, isNotEmpty);
    });
  });
}
