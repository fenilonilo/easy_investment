import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/chat_repository.dart';

// TODO: swap MockChatRepository with real AI backend when available.
class MockChatRepository implements ChatRepository {
  static const _responses = {
    'preço': [
      'O preço de um ativo reflete o valor de mercado atual. Verifique a aba **Início** para preços em tempo real da sua watchlist.',
      'Preços de ativos variam segundo oferta e demanda. Para ativos na sua watchlist, você vê o preço ao vivo na Home.',
    ],
    'tendência': [
      'A tendência de curto prazo é indicada pela seta verde (alta) ou vermelha (baixa) em cada card.\n\nPara análise mais profunda, observe o gráfico de **1Y** ou **ALL**.',
      'Tendências são confirmadas em múltiplos períodos. Compare os gráficos de **1M** e **1Y** para ver consistência.',
    ],
    'dividendo': [
      '**Dividendos** são distribuições de lucro aos acionistas.\n\n- Dividend yield acima de 5% é considerado alto no mercado americano.\n- Analise histórico antes de investir.',
      'Empresas que pagam dividendos consistentes tendem a ser mais maduras. Verifique o P/E Ratio junto ao dividend yield.',
    ],
    'recomendação': [
      '**Atenção:** Não sou um consultor financeiro registrado. Minha análise é educacional.\n\nPara decisões de investimento, consulte um especialista certificado.',
      'Recomendo diversificação entre setores. Não concentre mais de 20% em um único ativo. Esta é uma orientação geral, não consultoria financeira.',
    ],
    'crypto': [
      'Criptomoedas são ativos de **alta volatilidade**. Invista apenas o que pode perder.\n\nAlguns pontos:\n- Bitcoin e Ethereum são mais consolidados.\n- Altcoins têm risco maior.\n- Guarde em cold wallet para grandes quantias.',
    ],
    'ação': [
      'Ações representam participação em empresas. Para análise, observe:\n\n| Métrica | O que indica |\n|---------|-------|\n| P/E Ratio | Valorização vs lucro |\n| Dividend Yield | Renda passiva |\n| Market Cap | Tamanho da empresa |',
    ],
    'perfil': [
      '**Perfis de investidor:**\n\n- **Conservador** — Prioriza segurança. Foco em renda fixa e dividendos.\n- **Moderado** — Equilibra crescimento e segurança.\n- **Agressivo** — Aceita volatilidade em busca de alto retorno.',
    ],
    'watchlist': [
      'Sua watchlist está na aba **Início**. Para adicionar ativos, vá em **Perfil** → busque pelo ticker (ex: AAPL, BTC-USD) → adicione → salve.',
    ],
    'etf': [
      '**ETFs** (Exchange Traded Funds) são fundos que rastreiam índices ou setores.\n\nVantagens:\n- Diversificação automática\n- Baixo custo de gestão\n- Alta liquidez\n\nExemplos: **SPY** (S&P 500), **QQQ** (Nasdaq), **VTI** (mercado total EUA).',
    ],
  };

  static const _fallbacks = [
    'Boa pergunta! Infelizmente não tenho dados suficientes para responder com precisão. Tente perguntar sobre **preço**, **tendência**, **dividendos**, **ETFs** ou **perfil de investidor**.',
    'Posso te ajudar com análises de ativos da sua watchlist, conceitos de investimento e interpretação de métricas financeiras. O que deseja saber?',
    'Para uma resposta mais precisa, mencione o nome do ativo ou o tópico específico (ex: dividendos, análise técnica, ETFs).',
  ];

  @override
  Future<String> sendMessage(String userMessage) async {
    final delay = 800 + Random().nextInt(700);
    await Future.delayed(Duration(milliseconds: delay));

    final lower = userMessage.toLowerCase();
    for (final entry in _responses.entries) {
      if (lower.contains(entry.key)) {
        final list = entry.value;
        return list[Random().nextInt(list.length)];
      }
    }
    return _fallbacks[Random().nextInt(_fallbacks.length)];
  }
}

final chatRepositoryProvider = Provider<ChatRepository>(
  (_) => MockChatRepository(),
);
