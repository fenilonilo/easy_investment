# QA aba Início (Home / watchlist)

Data: 2026-10-01. App web em http://localhost:8080, backend http://localhost:8000. Chromium próprio (Playwright, contexto novo), viewport 929x965. Screenshots em `docs/qa/evidence/inicio/`.
Código analisado: `lib/presentation/views/home/*`, `viewmodels/home_viewmodel.dart`, `data/repositories/{asset,watchlist}_repository_impl.dart`, `core/router/app_router.dart`, `data/datasources/auth_interceptor.dart`.

## Funcionalidades existentes na aba (pelo código)
Watchlist (cards com ícone, ticker, nome, preço, Alta/Baixa), reordenar por drag (persistido em SharedPreferences), gráficos históricos por ativo com seletor de período (1D/1W/1M/1Y/ALL, global) e tooltip, notícias (carrossel auto-rotativo), botão refresh + pull-to-refresh, estados loading (shimmer), vazio, erro (retry).
NÃO existem na Home: detalhe do ativo, dividendos, financials, adicionar ativo (só via aba Perfil). `AssetCardWidget.onTap` existe mas `HomeView` não passa callback.

## Resumo
| # | Funcionalidade | Status | Origem |
|---|---|---|---|
| 1 | Carga da watchlist + cards | ⚠️ Parcial | APP / indeterminado |
| 2 | Variação (Alta/Baixa) | ❌ Falha | APP |
| 3 | Gráficos 1W / 1M / 1Y / ALL | ✅ OK | - |
| 4 | Gráfico 1D | ❌ Falha | BACK + APP |
| 5 | Tooltip do gráfico | ✅ OK | - |
| 6 | Notícias | ⚠️ Parcial | APP (+BACK dado) |
| 7 | Refresh (botão) | ✅ OK | - |
| 8 | Reordenar + persistência | ⚠️ Parcial | APP (cosmético) |
| 9 | Tap no card / detalhe do ativo | ❌ Ausente | APP |
| 10 | Estado vazio + botão | ✅ OK | - |
| 11 | Loading (shimmer) | ✅ OK | - |
| 12 | Erro watchlist 500 / offline + retry | ✅ OK | - |
| 13 | Erro parcial (1 cotação 404, history 500) | ❌ Falha | APP |
| 14 | Histórico vazio / notícias vazias / notícias 500 | ✅ OK | - |
| 15 | 401 (token expirado) | ⚠️ Parcial | APP |
| 16 | Dividendos / Financials | ⏭️ Não presentes na Home | - |

## Detalhes

### 1. Carga da watchlist e cards — ⚠️
Passos: login, abrir #/home. Esperado: cards + gráficos + notícias. Obtido: OK (`01-home.png`). Rede: `GET /profile/watchlist`, `/assets/{t}`, `/assets/{t}/history?period=1mo`, `/assets/{t}/news`, todos 200.
Problemas:
- Ícones nunca carregam na web: console `Access to image at 'https://www.google.com/s2/favicons?domain=apple.com&sz=128' ... blocked by CORS policy` + `NETFAIL ... net::ERR_FAILED`. O app cai no fallback (letra inicial), não quebra. Origem: indeterminado (limitação CORS do host de ícones com CachedNetworkImage em web; em mobile provavelmente funciona).
- Preço sempre com `$` (campo `price_usd`). PETR4.SA (B3) mostra `$49.12` embora provavelmente seja BRL (`GET /assets/PETR4.SA` -> `"price_usd":49.12`). Origem: indeterminado (BACK pode devolver BRL sob nome price_usd).
- Rótulos do eixo Y sobrepostos no topo do gráfico ($341.07 sobre $340.00, `01-home.png`). APP cosmético (fl_chart).

### 2. Variação — ❌ (APP)
Backend retorna `direction` com 3 valores: "subindo", "descendo", "estável" (`GET /assets/PETR4.SA` -> `"direction":"estável"`). O app só testa `== 'subindo'` (`asset_card_widget.dart:16`, `historical_chart_card.dart:27`), então "estável" aparece como "Baixa" vermelho com seta para baixo (`01-home.png`). Também não mostra variação percentual/absoluta.

### 3/4. Gráficos e períodos
Passos: clicar 1D/1W/1M/1Y/ALL. Rede: `history?period=1d|5d|1mo|1y|max` (ambos ativos), todos 200. 1W, 1M, 1Y, ALL desenham corretamente (`10-period-*.png`; ALL de AAPL com ~11k pontos renderiza OK; 1.2s no back). Seletor é global (troca todos os cards).
1D: ❌ gráfico em branco, só o rótulo `$333.02` (`10-period-1D.png`). `curl /assets/AAPL/history?period=1d` -> 1 único ponto `[{"date":"2026-09-30","close":333.02}]` (sem intraday). Origem: BACK (1 ponto para 1d) + APP (não trata <2 pontos; "Sem dados" só aparece para lista vazia).
Back também devolve `[]` com 200 para ticker inexistente e para `period=bad` (sem validação 4xx).
Falha silenciosa: `setPeriod` engole exceções (`catch (_) {}`): se o histórico falhar ao trocar período, o botão muda mas o gráfico mantém dados antigos sem aviso. APP (lido no código; não reproduzido via UI).

### 5. Tooltip — ✅
Pressionar/arrastar no gráfico mostra `$332.41 16/09/2026` (`12-chart-touch.png`).

### 6. Notícias — ⚠️
Carrossel carrega, ordena por data, auto-rotaciona a cada 4s (`03-home-scroll2.png`). Cards NÃO são clicáveis (campo `link` vem do back mas não é usado). Aparecem notícias sem relação com o ativo (ex.: "Qualcomm" para AAPL/PETR4.SA): dado do BACK. Lista vazia: seção fica só com o título "Notícias", sem mensagem (`20-newsempty.png`). Notícias 500: falha silenciosa (`catchError` por ticker), seção em branco sem feedback.

### 7. Refresh — ✅
Botão no AppBar refaz watchlist, quotes, histórico, notícias (200). Pull-to-refresh não testado (canvas/mouse).

### 8. Reordenar — ⚠️
Arrastar o handle de AAPL para baixo inverte a ordem; gráficos seguem a ordem e persiste após reload (`14-reorder.png`, `15-after-reload.png`). Cosmético: handle duplicado/sobreposto (dois "=" à direita dos cards): ícone custom + handle padrão do ReorderableListView em web/desktop. APP. Obs: ordem fica só em SharedPreferences local (não por usuário).

### 9. Tap no card / detalhe — ❌ (APP, ausente)
Clicar no card não faz nada (URL permanece `#/home`, `11-tap-card.png`). Router só tem `/home`, sem rota de detalhe. Endpoints de dividends/financials existem no repositório mas nada os consome.

### 10. Estado vazio — ✅
Mock `GET /profile/watchlist -> []`: "Sua watchlist está vazia" + botão "Adicionar seu primeiro ativo" (`20-empty.png`); botão leva a `#/profile` (`21-empty-btn.png`).

### 11. Loading — ✅
Respostas atrasadas 8s: 3 placeholders shimmer (`21-slow-shimmer.png`), depois conteúdo.

### 12. Erro watchlist 500 / offline — ✅
Mock 500 e conexão recusada: "Erro ao carregar dados." + "Tentar novamente" (`20-wl500.png`, `20-offline.png`). Retry com backend normal recupera a lista (`21-wl500-retry.png`). Mensagem genérica (não distingue offline de 500). Refresh com backend offline substitui TODA a tela por erro, descartando dados já exibidos (`21-offline-refresh.png`): APP (poderia manter dados antigos + aviso).

### 13. Erro parcial — ❌ (APP)
Se UMA cotação falha (mock 404 em `/assets/PETR4.SA`; o back real devolve 404 `{"detail":"Ativo X não encontrado"}` para ticker inválido) ou QUALQUER histórico retorna 500, `Future.wait` falha e a Home inteira mostra "Erro ao carregar dados." (`21-quote404.png`, `21-hist500.png`). Usuário perde acesso aos demais ativos e não consegue remover o problemático. Rede: `NET 404 GET /assets/PETR4.SA`, `NET 500 GET /assets/AAPL/history?period=1mo`. Falta tolerância por ativo.

### 14. Histórico vazio — ✅
200 `[]` mostra "Sem dados" em cada card (`21-histempty.png`). Notícias vazias/500 não quebram a tela.

### 15. 401 — ⚠️ (APP)
Mock 401 na watchlist: `AuthInterceptor` limpa token e chama `onLogout`, mas a tela permanece em `#/home` com "Erro ao carregar dados." (`21-401.png`). Redirecionamento ao login só ocorre na próxima navegação. Esperado: ir ao login imediatamente.

## Logs
Console: únicas mensagens de erro nas execuções normais são os CORS dos favicons Google; `[DOM] Password field is not contained in a form` (verbose, login). Sem `pageerror`/exceções Dart. `flutter_web.log` não consultado (nenhum erro de runtime no console).
curl (token do login via `POST /auth/login` form-urlencoded): watchlist `[]` 200 antes de eu adicionar dados; `assets/AAPL` 200; `assets/INVALIDXYZ` 404; `history?period=bad` 200 `[]`; `/profile/watchlist` sem token 401 `{"detail":"Not authenticated"}`; dividends/financials/news 200.
Observação metodológica: mocks de erro feitos com `page.route` do Playwright (watchlist/quote/history/news), pois o back real não falha sob demanda.

## Dados criados
Conta compartilhada: adicionei AAPL e PETR4.SA via `POST /profile/watchlist/add` (tickers não aceitam prefixo "QA-Inicio"). Não removi pois outros agentes usam a mesma watchlist (MSFT de outro teste também apareceu). Remover manualmente se necessário.
