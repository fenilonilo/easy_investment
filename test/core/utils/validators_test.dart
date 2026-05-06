import 'package:flutter_test/flutter_test.dart';
import 'package:easy_finance/core/utils/validators.dart';

void main() {
  group('Validators.email', () {
    test('retorna erro para valor null', () {
      expect(Validators.email(null), 'Email obrigatório');
    });

    test('retorna erro para string vazia', () {
      expect(Validators.email(''), 'Email obrigatório');
    });

    test('retorna null para email válido', () {
      expect(Validators.email('user@example.com'), isNull);
    });

    test('retorna erro para email sem @', () {
      expect(Validators.email('userexample.com'), 'Email inválido');
    });

    test('retorna erro para email sem domínio', () {
      expect(Validators.email('user@'), 'Email inválido');
    });

    test('retorna erro para email sem TLD', () {
      expect(Validators.email('user@example'), 'Email inválido');
    });

    test('retorna erro para TLD com menos de 2 caracteres', () {
      expect(Validators.email('user@example.c'), 'Email inválido');
    });

    test('retorna null para email com TLD de 2 caracteres', () {
      expect(Validators.email('user@example.br'), isNull);
    });
  });

  group('Validators.password', () {
    test('retorna erro para valor null', () {
      expect(Validators.password(null), 'Senha obrigatória');
    });

    test('retorna erro para string vazia', () {
      expect(Validators.password(''), 'Senha obrigatória');
    });

    test('retorna erro para senha com menos de 6 caracteres', () {
      expect(Validators.password('abc'), 'Mínimo 6 caracteres');
    });

    test('retorna erro para senha com 5 caracteres', () {
      expect(Validators.password('abcde'), 'Mínimo 6 caracteres');
    });

    test('retorna null para senha com exatamente 6 caracteres', () {
      expect(Validators.password('abcdef'), isNull);
    });

    test('retorna null para senha longa', () {
      expect(Validators.password('abcdefghij1234'), isNull);
    });
  });

  group('Validators.required', () {
    test('retorna erro para valor null', () {
      expect(Validators.required(null), 'Campo obrigatório');
    });

    test('retorna erro para string vazia', () {
      expect(Validators.required(''), 'Campo obrigatório');
    });

    test('retorna erro para string somente com espaços', () {
      expect(Validators.required('   '), 'Campo obrigatório');
    });

    test('retorna null para valor válido', () {
      expect(Validators.required('algum valor'), isNull);
    });

    test('usa label customizado no erro', () {
      expect(Validators.required(null, 'Nome'), 'Nome obrigatório');
    });

    test('usa label customizado com valor vazio', () {
      expect(Validators.required('', 'Email'), 'Email obrigatório');
    });
  });
}
