# Reteste aba Início (Fase 2)

Data: 2026-10-01. App http://localhost:8080 (código corrigido), back http://localhost:8000. Chromium próprio (Playwright, contexto novo por cenário), viewport 929x965. Screenshots em `docs/qa/evidence/retest/inicio/`. Falhas simuladas com `page.route` (404 cotação, 500 histórico/notícias, `[]`, conexão recusada), como no relatório original.
Dados: nenhum dado criado nem alterado no back (watchlist segue AAPL, PETR4.SA). A ordem de reordenar fica só no storage do contexto descartável; desfeita também na UI (`33-restored.png`).

## Resultado por ID
| ID | Status | Evidência |
|---|---|---|
| B16 estável neutro | ✅ corrigido | PETR4.SA (back real: `direction":"estável"`) mostra "— Estável" cinza no card, no badge e na linha/preço do gráfico; AAPL segue "Alta" verde. `01-home.png` |
| B17 falha isolada por ativo | ✅ corrigido | Cotação 404 de PETR4.SA: AAPL (card + gráfico + notícias) segue normal; PETR4.SA vira linha "Erro ao carregar cotação" + "Tentar de novo" (`20-quote404.png`). Histórico 500 de AAPL: card AAPL mostra "Erro ao carregar o gráfico", PETR4.SA normal, também ao trocar para 1Y (`21-hist500-1Y.png`). Rede: `NET 404 /assets/PETR4.SA`, `NET 500 /assets/AAPL/history?period=1mo|1y`. |
| B18 1D com 1 ponto | ✅ corrigido | Mock com 1 ponto em `period=1d`: "Sem dados" nos 2 cards (`11-1d-1ponto.png`). Obs.: o back agora devolve intraday real (~78 pontos de 5 min) para AAPL e o 1D desenha bem (`10-period-1D.png`), então o lado BACK parece corrigido. |
| B20 notícias vazias/erro | ✅ corrigido (mensagens) | Vazio: "Nenhuma notícia disponível no momento." (`22-news-vazio.png`). 500 em todas: "Não foi possível carregar as notícias." (`22-news-500.png`). |
| B20 link das notícias | ❌ não implementado | Clique no card de notícia real: URL segue `#/home`, nenhuma aba nova (`22-news-click.png`). Reportado conforme pedido; o time F4 não implementou. |
| B20 falha silenciosa do `setPeriod` | ✅ corrigido | Histórico 500 ao trocar para 1Y agora vira "Erro ao carregar o gráfico" no card em vez de manter o gráfico antigo (`21-hist500-1Y.png`). |
| B28 refresh offline | ✅ corrigido | Com tudo recusado, clicar refresh mantém watchlist e gráficos e mostra "Erro ao carregar dados." em vermelho no topo (`30-offline-refresh.png`); voltando o back, novo refresh limpa o aviso (`30-offline-refresh-recovered.png`). Rede: `NETFAIL /profile/watchlist ERR_CONNECTION_REFUSED`. |
| B28 handle de reordenar | ✅ corrigido | Um único "=" por card (`01-home.png`). |
| B28 eixo Y | ✅ corrigido | Rótulos legíveis, sem sobreposição, em 1M/1D/1Y (`01-home.png`, `10-period-*.png`). |

## Regressão (itens que estavam ✅)
- Carga + cards + gráficos + notícias: OK (`01-home.png`); console só com o CORS dos favicons Google (B22, fora de escopo), sem `pageerror`.
- Períodos 1D/1W/1M/1Y/ALL: todos desenham, sem erros de rede (`10-period-*.png`).
- Tooltip do gráfico: NÃO reverificado (arrasto de mouse headless não o acionou, `32-tooltip.png` sem tooltip; o original usou toque). Sem exceções no console.
- Estado vazio: mock `[]` mostra "Sua watchlist está vazia" e o botão leva a `#/profile` (`31-empty.png`, `31-empty-btn.png`).
- Reordenar + persistência: arrastar o handle de AAPL inverte ordem de cards e gráficos, persiste após reload (`33-reorder.png`, `33-reorder-after-reload.png`), e voltar à ordem original funciona (`33-restored.png`).
- Refresh normal (botão): recarrega dados sem problema (`30-offline-refresh-recovered.png`).

## Novas regressões / observações
- Nenhuma regressão funcional encontrada.
- Observação: PETR4.SA continua com `$49.12`; o back agora devolve `"currency":"BRL"` em `/assets/PETR4.SA`, mas o app ainda formata sempre com `$` (pendência de moeda, ainda não coberta pelas IDs B16-B28).
- Observação: erro do refresh aparece como texto vermelho simples no topo, sem botão de retry (aceitável, o botão de refresh do AppBar serve).
- Não retestado: 401 na Home (item 15 do QA original, fora das IDs deste reteste).
