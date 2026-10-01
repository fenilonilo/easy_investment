# QA - Síntese (Easy Finance, branch feat/ai-agent-chat)

Data: 2026-10-01. Fontes: qa-inicio.md, qa-perfil.md, qa-ia-chat.md, qa-config.md (evidências em `docs/qa/evidence/<aba>/`), código em `lib/` e curl no backend local.
Convenção de certeza: **Confirmado** = li o código e/ou reproduzi com curl nesta síntese; **Reportado** = só consta no relatório do agente de QA (screenshot/console/rede dele), não reexecutado por mim.
Sobre o log do app: `$TEMP/flutter_web.log` contém apenas o boot do `flutter run -d web-server` (porta 8080, debug service). Confirmado: nenhuma linha de runtime. Por isso "log do aplicativo" = console do browser e rede capturados pelos agentes.

## 1. Resumo executivo

Placar por aba (por funcionalidade testada):

| Aba | ✅ | ⚠️ | ❌ | Observação |
|---|---|---|---|---|
| Início | 7 | 4 | 4 | +1 não aplicável (dividendos/financials não existem na Home) |
| Perfil | 2 | 3 | 2 | 7 funcionalidades; watchlist e logout OK, dados do usuário e edição quebrados |
| IA Chat | 8 | 8 | 4 | +1 não testável (follow-up, cota Gemini) |
| Config | 5 | 2 | 1 | logout trava a tela |
| **Total** | **22** | **17** | **11** | |

Veredito geral: **não pronto para release**. Navegação, tema, watchlist (CRUD), gráficos 1W/1M/1Y/ALL e o chat quando o Gemini responde funcionam. Mas o logout não funciona, o Perfil não mostra nem salva dados do usuário, e o chat falha de forma silenciosa quando o provedor de IA erra (e ele está errando agora).

Riscos principais:
1. Logout (Config) derruba a tela e nunca desloga (APP, crítica).
2. Perfil vazio e "salvar" que não salva mas mostra sucesso (APP, alta).
3. Chat: erro do Gemini vira bolha vazia (APP + BACK); cota free tier de 20 req/dia/modelo esgotada (BACK/infra).
4. 401 não redireciona ao login (APP, uma causa só, aparece em 3 abas).
5. Home inteira cai por erro em 1 ativo; "estável" exibido como "Baixa" (APP).

## 2. O que está funcionando

| Aba | Funciona |
|---|---|
| Início | Carga da watchlist com cards e gráficos (1W/1M/1Y/ALL); tooltip do gráfico; refresh por botão; estado vazio com botão para Perfil; shimmer de loading; erro 500/offline com "Tentar novamente"; histórico/notícias vazios sem quebrar; reordenar por drag com persistência local |
| Perfil | Listar watchlist (chips) e persistir após reload; busca com debounce e caracteres especiais; adicionar e remover ativo (POST add/remove 200); validação de e-mail inválido; logout pelo ícone da AppBar e guard de rota |
| IA Chat | Saudação/layout; bloqueio de mensagem vazia; limite 4000 (backend 422); texto/emoji/HTML do usuário seguro; markdown (tabelas, listas, links, negrito); botão Stop; bloqueio de 2º envio durante resposta; nova conversa; abrir/listar/apagar sessão; invalidação da watchlist após tool (simulada); auth nas rotas `/ai` (401 sem token/token inválido); respostas reais corretas quando o Gemini respondeu (AAPL P/L 38,15, PETR4) |
| Config | Tema escuro/claro imediato e persistente; idioma persiste (a escolha); itens estáticos; guard de rota sem token redireciona ao login |

## 3. O que NÃO está funcionando

| ID | Aba | Sev. | Descrição | Origem | Causa raiz (arquivo:linha) | Evidência | Certeza |
|---|---|---|---|---|---|---|---|
| B01 | Config | Crítica | Clicar em qualquer botão do diálogo "Sair" deixa a tela branca; logout nunca executa; token permanece | APP | `lib/presentation/views/config/config_view.dart:104` `builder: (_)` ignora o contexto do diálogo; `:108` e `:113` chamam `Navigator.pop(context, ...)` com o contexto da tela, o que remove a última página do go_router; o `await showDialog` nunca completa e `logout()`/`context.go('/login')` (`:118-121`) não rodam | Console: `Assertion failed: go_router-14.8.1/lib/src/delegate.dart:162:7 currentConfiguration.isNotEmpty "You have popped the last page..."` em `config_view.dart 113:52`; `12-crash-white-screen.png` | Confirmado por código; efeito Reportado |
| B02 | Perfil | Alta | Nome, nascimento e e-mail vazios; perfil mostra "Conservador" só pelo default | APP (agravante BACK) | `ProfileNotifier._init` lê `readUser()` (`profile_viewmodel.dart:70`); `saveUser` só é chamado em `profile_viewmodel.dart:170` (dentro de `updateProfile`); login nunca grava o usuário. Back não tem endpoint de "dados do usuário logado" (login só devolve token) | Rede: só `POST /auth/login` e `GET /profile/watchlist`, nenhum fetch de usuário; `03_perfil.png` | Confirmado (grep: `saveUser` só em `:170`); ausência de GET /me no OpenAPI Reportado (não consegui abrir `openapi.json` no caminho informado) |
| B03 | Perfil | Alta | Salvar e-mail/perfil não envia PUT e mostra "Watchlist atualizada!" | APP | `profile_viewmodel.dart:149` `if (user == null) return;` silencioso (consequência de B02); `saveChanges` (`:114-138`) zera `error/successMessage` (`:115`) e define sempre `'Watchlist atualizada!'` (`:137`) | Rede vazia ao salvar; snackbar verde, `21_valid_email_save_a.png` | Confirmado por código; efeito Reportado |
| B04 | Perfil | Média | Erro de `updateProfile` é sobrescrito por `saveChanges`; erro de salvar sempre genérico "Erro ao salvar." (400 duplicado, 404 etc.) | APP | `profile_viewmodel.dart:115,137,140`; chamada em sequência em `profile_view.dart:123-128` | Análise de código dos agentes + curl (400/404 do back) | Confirmado por código |
| B05 | Chat | Alta | Erro do Gemini (503/429) vira bolha vazia do assistente, sem aviso nem retry | APP + BACK | APP: `chat_viewmodel.dart:154-169` `DoneEvent` marca `terminouLimpo = true` e adiciona `ChatMessage(text: '')` mesmo com `content` vazio e `streamingText` vazio; `ultimoErro` (`:174`) é ignorado em `onDone` (`:188-193`). BACK: emite `done` com `content:""` logo após `error` fatal | curl nesta síntese (`POST /ai/chat/stream {"message":"ok"}`): `event: error data: {"detail":"{ \"error\": { \"code\": 503, \"message\": \"The service is currently unavailable.\" ...` seguido de `event: done data: {... "content": ""}`; `04-watchlist-f09.png` | Confirmado (código + curl) |
| B06 | Chat | Alta | Cota free tier do Gemini estourada (`limit: 20`, `gemini-3.5-flash`); depois de ~20 req todo chat falha | BACK / infra | Plano/cota do provedor; sem fallback (Groq) | curl do relatório: `Quota exceeded ... generate_content_free_tier_requests, limit: 20 ... Please retry in 40s`; hoje o curl devolve 503 | Reportado (cota) / Confirmado (503 atual) |
| B07 | Chat | Média | Timeout de 90 s nunca dispara; "Pensando..." por 145 s sem erro | APP | `ai_agent_remote_datasource.dart:47` `await _dio.post<ResponseBody>` do `async*` com `connectTimeout/receiveTimeout = Duration.zero` (`:62-63`); o `.timeout(_semEventos)` (`chat_viewmodel.dart:134`) só vale depois que o stream existe | `18-timeout-97s.png`, `18b-t145.png` (rede pendurada simulada) | Confirmado por código; efeito Reportado |
| B08 | Chat | Média | Histórico expõe `<additional context>{nome_do_usuario, perfil, watchlist}</additional context>` na bolha do usuário | BACK (mitigável no APP) | Backend persiste/expõe o contexto injetado em `GET /ai/sessions/{id}` | `08-session-opened.png`; curl do relatório | Reportado (não reexecutado) |
| B09 | Chat | Média | Recarregar a página perde a conversa atual | APP | `sessionId` só em memória no `ChatNotifier` | `12-after-reload.png` | Reportado |
| B10 | Chat | Média | `FloatingIAAvatar` é código morto | APP | `lib/presentation/views/shared/floating_ia_avatar.dart:6`, sem uso em nenhum outro arquivo | grep: só a própria declaração | Confirmado |
| B11 | Chat | Baixa | Markdown: blockquote com contraste ruim, `---` como barra branca grossa, code block sem estilo, LaTeX `$$..$$` cru | APP (+BACK prompt emite LaTeX) | `MarkdownStyleSheet` em `chat_view.dart` só ajusta p/strong/table | `15-special-chars-md-top.png`, `03-aapl-final.png` | Reportado |
| B12 | Chat | Baixa | Banner mostra JSON cru do provedor; HTTP 500 só "Erro 500"; truncamento silencioso em 4000; apagar sessão sem confirmação | APP + BACK | `detail` cru vindo do back (`ErrorEvent`, `chat_viewmodel.dart:173-174`); `maxLength` do campo | `13-err-partial.png`, `13-err-500html.png`, `16-long-input.png` | Reportado |
| B13 | Chat | Baixa | Chip de ferramenta e streaming token a token não observados na UI real (só pontinhos até o fim) | Indeterminado (suspeita XHR buffering na web) | Não isolado (cota acabou) | `03-aapl-t3.png`/`t4` vs curl com `tool` aos ~11 s | Reportado, indeterminado |
| B14 | Chat | Baixa | Resumos de sessão null ("Nova conversa") ou em inglês; sessões falhas aparecem no histórico; `/ai/chat` não-stream devolve 200 com o JSON de erro em `content` | BACK | Geração de `summary` e tratamento de erro no back | `07-history-sheet.png`; curl do relatório | Reportado |
| B15 | Todas (Início, Config, Chat) | Alta | 401 (token expirado/inválido) não redireciona ao login; Início mostra "Erro ao carregar dados.", Chat mostra "Sua sessão expirou" e fica na tela | APP (uma causa só) | `dio_client.dart:7` `logoutCallbackProvider` com default no-op e nunca sobrescrito (grep: só `:7` e `:22`); `AuthInterceptor.onError` chama o no-op. Router só olha existência do token | `21-401.png`, `20-garbage.png`, `21-tamper-nav.png`, `13-err-401.png`; back correto: `401 {"detail":"Token inválido ou expirado"}` | Confirmado por código; back Reportado e coerente com curl sem token (401 reproduzido) |
| B16 | Início | Média | "estável" aparece como "Baixa" vermelho com seta para baixo | APP | `asset_card_widget.dart:16`, `historical_chart_card.dart:27`, `core/utils/formatters.dart:29`: só testam `== 'subindo'` | curl nesta síntese: `GET /assets/PETR4.SA` -> `"direction":"estável"`; `01-home.png` | Confirmado (código + curl) |
| B17 | Início | Média | Uma cotação 404 ou um histórico 500 derruba a Home inteira | APP | `Future.wait` no `home_viewmodel.dart` sem tolerância por ativo | `21-quote404.png`, `21-hist500.png` (mocks Playwright) | Reportado (código citado, não relido) |
| B18 | Início | Média | Gráfico 1D em branco (só rótulo de preço) | BACK + APP | BACK: `history?period=1d` devolve 1 ponto; APP: não trata < 2 pontos | curl nesta síntese: `[{"date":"2026-09-30","close":333.0199890136719}]`; `10-period-1D.png` | Confirmado (curl), APP Reportado |
| B19 | Config | Média | Troca de idioma só muda o subtítulo; UI continua em português | APP | `config_view.dart` com strings literais; `app.dart` não registra `AppLocalizations.delegate` embora `lib/l10n/*` exista | `06-lang-en.png`, `08-home-en.png` | Reportado |
| B20 | Início | Baixa | Cards de notícia não clicáveis; seção vazia sem mensagem; falha de notícias/`setPeriod` silenciosa (`catch (_)`) | APP | Campo `link` não usado; `catchError` por ticker | `20-newsempty.png` | Reportado |
| B21 | Início | Baixa | Sem detalhe do ativo (tap no card não faz nada); dividends/financials sem consumidor | APP | Router só tem `/home`; `AssetCardWidget.onTap` sem callback | `11-tap-card.png` | Reportado |
| B22 | Início/Perfil | Baixa | Favicons do Google bloqueados por CORS na web (ícones caem para letra) | APP/web | `CachedNetworkImage` com `icon_url` de `google.com/s2/favicons` | Console: `Access to image at 'https://www.google.com/s2/favicons?domain=apple.com&sz=128' ... blocked by CORS policy` / `net::ERR_FAILED` | Reportado por 3 agentes (consistente) |
| B23 | Início | Baixa | Preço sempre com `$` (campo `price_usd`); PETR4.SA mostra `$49.12` (provável BRL) | Indeterminado (BACK pode devolver BRL em `price_usd`) | Campo/moeda do back; formatação fixa no app | curl nesta síntese: `"price_usd":49.12` para PETR4.SA | Confirmado o dado; moeda real não verificada |
| B24 | Perfil | Média | `POST /profile/watchlist/add` aceita ticker inexistente (200 `added_count:1`); add com lista vazia retorna 400 com mensagem de "já existem" | BACK | Sem validação contra `/assets` | curl reportado (`ZZZZ99X`) | Reportado |
| B25 | Início | Baixa | Back devolve 200 `[]` para `period=bad` e ticker inexistente em history (sem 4xx); notícias sem relação com o ativo | BACK | Validação/relevância no back | curl reportado | Reportado |
| B26 | Perfil | Baixa | Busca sem resultado sem mensagem; erro de busca engolido; erro de carga do perfil sem retry | APP | `SearchResultsList` devolve `SizedBox.shrink()`; `catch (_)` | `32_noresults.png` | Reportado |
| B27 | Config | Baixa | Versão "1.0.0" hardcoded; texto de privacidade ("dados apenas neste dispositivo") impreciso; `logout()` não limpa `user_data`; subtítulo "Ativo (OLED)" com fundo `#121212` | APP | `config_view.dart`, `auth_viewmodel.dart` | Relatório Config | Reportado |
| B28 | Início | Baixa | Refresh com back offline troca a tela inteira por erro, descartando dados; handle de reordenar duplicado; rótulos do eixo Y sobrepostos | APP | HomeViewModel / ReorderableListView / fl_chart | `21-offline-refresh.png`, `14-reorder.png`, `01-home.png` | Reportado |

Observação de segurança (BACK, a revisar): `session_id` inexistente enviado pelo cliente criou sessão com contexto; não foi testado acesso cruzado entre usuários (só existe um usuário).

## 4. Problemas no BACK (para o time de backend)

1. **SSE `POST /ai/chat/stream` emite `done` vazio após `error` fatal.** Request: `{"message":"ok"}` com Bearer. Resposta observada (reproduzida): `event: start` -> `event: error data: {"detail":"{ \"error\": { \"code\": 503, ... \"status\": \"UNAVAILABLE\" } }", "request_id": "..."}` -> `event: done data: {"session_id":"...","content":""}`. Esperado: não mandar `done` após erro fatal; `detail` legível (sem JSON do Google); usar fallback para Groq.
2. **Cota Gemini free tier (20 req, gemini-3.5-flash) esgotada** (429 `Quota exceeded ... Please retry in 40s`, reportado). Revisar plano/cota e fallback.
3. **`POST /ai/chat` (não-stream) retorna 200 com o JSON do erro 429 em `content`** (reportado). Deve ser 5xx/429 com `detail`.
4. **`GET /ai/sessions/{id}` expõe `<additional context>{nome_do_usuario, perfil_de_investidor, watchlist}</additional context>`** dentro da mensagem do usuário (reportado). Não persistir/expor.
5. **Sessões**: `summary` null na maioria e em inglês quando existe; sessões que falharam ficam no histórico; `session_id` inexistente é aceito e cria sessão; `DELETE` de sessão inexistente: 204 na 1ª vez, 404 depois (reportado). Revisar autorização por dono da sessão.
6. **`GET /assets/{t}/history?period=1d`** devolve 1 único ponto (reproduzido: `[{"date":"2026-09-30","close":333.01...}]`), sem intraday. `period=bad` e ticker inexistente retornam 200 `[]` (reportado).
7. **`GET /assets/PETR4.SA`** traz `"price_usd":49.12` (reproduzido) para ativo da B3: confirmar se é BRL; `direction` tem 3 valores ("subindo", "descendo", "estável"), documentar no contrato.
8. **`POST /profile/watchlist/add`** aceita ticker inexistente (200, `added_count:1`) e lista vazia dá 400 "Todos os ativos já estão na sua lista." (reportado).
9. **Sem endpoint para dados do usuário logado** (login devolve só token; OpenAPI só tem register/update/delete, segundo o agente do Perfil): necessário para corrigir B02 (alternativa: login devolver o usuário).
10. Notícias de `/assets/{t}/news` sem relação com o ativo (ex.: Qualcomm para AAPL) (reportado). Latência do agente 10-60 s e respostas longas demais para perguntas simples (prompt).

Back que está correto: 401 com `{"detail":"Not authenticated"}` / `"Token inválido ou expirado"` (sem token reproduzido: 401), 422 para mensagem vazia/>4000, 404 para ativo inexistente em `/assets/{t}`.

## 5. Problemas no APP (para o time Flutter)

| ID | Arquivo:linha | Correção sugerida |
|---|---|---|
| B01 | `config_view.dart:104,108,113` | `builder: (ctx) => ...` e `Navigator.pop(ctx, true/false)`. |
| B15 | `dio_client.dart:7,22` | Sobrescrever `logoutCallbackProvider` (ex.: no `ProviderScope`/`app.dart`) para limpar sessão e `router.go('/login')`; mensagem "sessão expirada". |
| B02/B03 | `profile_viewmodel.dart:70,149,170`; `auth_repository_impl.dart` | Gravar o usuário no login (ou buscar do back) via `saveUser`; se `user == null`, mostrar erro em vez de `return` silencioso. |
| B04 | `profile_viewmodel.dart:115,137,140` | Não zerar `successMessage/error` em `saveChanges`; mensagem por tipo de alteração; mapear 400/404 do back. |
| B05 | `chat_viewmodel.dart:154-169,188-193` | Se `DoneEvent.content` e `streamingText` vazios, tratar como erro (`ultimoErro`) e oferecer "Tentar de novo"; traduzir 429/503 para mensagem amigável. |
| B07 | `ai_agent_remote_datasource.dart:47-63` | Envolver `_dio.post` em `Future.timeout` (ou `sendTimeout`/timeout nos cabeçalhos) para valer o limite de 90 s. |
| B09 | `chat_viewmodel.dart` | Persistir `sessionId` e reabrir a última conversa; confirmar antes de apagar sessão. |
| B10 | `floating_ia_avatar.dart` | Remover ou instanciar no shell. |
| B11/B12 | `chat_view.dart` (`MarkdownStyleSheet`) | Estilizar blockquote/hr/code; remover bloco `<additional context>` ao exibir histórico; avisar ao atingir 4000. |
| B16 | `asset_card_widget.dart:16`, `historical_chart_card.dart:27`, `formatters.dart:29` | Tratar 3 estados: subindo/descendo/estável (neutro, sem seta vermelha). |
| B17 | `home_viewmodel.dart` (`Future.wait`) | Falha por ativo: `catchError` individual e card com erro, mantendo os demais. |
| B18 | gráfico da Home | Se `< 2` pontos, exibir "Sem dados" (ou fallback de período). |
| B19 | `config_view.dart`, `app.dart` | Registrar `AppLocalizations.delegate` e trocar literais por `AppLocalizations`. |
| B20/B21/B26/B28 | Home/Perfil | Abrir `link` das notícias; mensagens de vazio/erro; manter dados antigos em falha de refresh. |
| B22 | widget de ícone | Na web, usar proxy do back ou `Image.network` com fallback; manter letra inicial. |
| B27 | `config_view.dart`, `auth_viewmodel.dart` | Ler versão do `package_info_plus`; limpar `user_data` no logout; ajustar texto de privacidade. |

## 6. Causas-raiz compartilhadas

| Causa raiz | Sintomas agrupados |
|---|---|
| `logoutCallbackProvider` no-op (`dio_client.dart:7`) | B15: 401 sem redirect em Início, Config (token adulterado) e Chat. Uma correção resolve os três. |
| Usuário nunca gravado no login | B02 + B03 (Perfil vazio, salvar não envia PUT, falso sucesso) + B27 (`user_data` não limpo no logout). |
| Contexto de navegação errado no diálogo | B01 (logout) e, por consequência, impossibilidade de testar logout real. |
| Falha silenciosa por `catch (_)` / retorno vazio | B05 (bolha vazia), B20 (notícias/`setPeriod`), B26 (busca/carga), B03 (return silencioso). |
| Back trata erro de provedor como fluxo normal (`error` + `done` vazio, 200 com erro no `content`) | B05, B12, B14. |
| `'subindo'` como único estado reconhecido | B16 (card, gráfico e `formatters.dart`). |
| Falha total em vez de parcial (`Future.wait`) | B17 e erro do refresh offline (B28). |
| Gemini sem cota/fallback | B05, B06, lacunas de teste do chat. |

## 7. Lacunas de cobertura e pendências de limpeza

Não testado:
- Chat com resposta real após a cota: follow-up com contexto (B18 do relatório), tool real `adicionar_a_watchlist` no back, chip de ferramenta e streaming real no browser (cota Gemini esgotada; hoje o back devolve 503). Cenários de erro/markdown/stop foram feitos com SSE simulado por `page.route`.
- Logout real e limpeza de token/`user_data` (bloqueado por B01); PUT `/user/update/{id}` (não exercitável pela UI por B02; não executado por curl para não alterar o e-mail da conta); dropdown de perfil ponta a ponta.
- Esvaziar a watchlist inteira; pull-to-refresh (canvas/mouse); carga/erro do Perfil (`getWatchlist` falhando) só por código.
- Aparelho/emulador mobile e `flutter run -d chrome` (testes só em web-server com Chromium headless; ícones CORS podem funcionar em mobile); acesso cruzado entre usuários (só há um usuário); acessibilidade (UI em canvas, sem semântica).
- Erros de Início (500, 404, offline, 401, vazio) e de Chat foram simulados com mocks, o back real não falha sob demanda.
- Nesta síntese: não abri `D:\Projetos\Projetos_Marcelo\openapi.json` (arquivo não encontrado no caminho informado), então a ausência de `GET /user/me` é Reportada.

Pendências de limpeza (conta de teste compartilhada):
- ~17 sessões de chat de teste em `/ai/sessions` (ids como a1d9c46a, 451847cb...), mais as criadas por curl, inclusive 1 nova criada por esta síntese (`a41f209f...`) e 1 de chamada anterior com erro de parse não criada. A limpeza em lote foi bloqueada pelo classificador; apagar pelo app ou via `DELETE /ai/sessions/{id}`.
- Watchlist da conta: AAPL e PETR4.SA (adicionados pelo QA; MSFT e ZZZZ99X já removidos). Remover manualmente se não forem desejados.
- E-mail/senha da conta não foram alterados.

## 8. Ordem de correção recomendada

1. B01 logout (APP, 1 linha, bloqueia saída da conta e testes seguintes).
2. B15 `logoutCallbackProvider` (APP, resolve 401 em 3 abas).
3. B05 + back (`error` sem `done` vazio) e B06 cota/fallback Gemini; sem isso o chat não é utilizável.
4. B02/B03/B04 Perfil: gravar usuário no login (alinhar com back sobre endpoint/resposta de login) e corrigir feedback de salvar.
5. B16 "estável" e B17 falha parcial na Home.
6. B07 timeout real do chat; B08 `additional context` no histórico; B09 persistir sessão.
7. B18 gráfico 1D; B24/B25 validações do back.
8. B19 i18n, B11/B12 markdown e mensagens, B20/B21/B22/B26/B27/B28 e limpeza (B10, itens da seção 7).
