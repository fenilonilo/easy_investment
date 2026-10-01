# QA - Aba IA Chat (branch feat/ai-agent-chat)

Data: 2026-10-01. Ambiente: Flutter web debug em `localhost:8080`, backend FastAPI em `localhost:8000`, Chromium headless próprio (Playwright, viewport 929x965), usuário de teste do CLAUDE.md.
Evidências em `docs/qa/evidence/ia-chat/` (screenshots numerados, mais `curl-sse-*.txt`).

Observação sobre logs: o `flutter_web.log` (modo web-server) só contém o boot do servidor, nada do runtime do app. Os dados de runtime vêm do console do browser e da rede capturados pelo Playwright.

## Resumo executivo

| # | Severidade | Problema | Origem |
|---|---|---|---|
| 1 | Alta | Gemini devolve 503/429 e o stream termina com `error` + `done` de `content:""`. O app mostra uma bolha vazia e engole o erro, sem aviso nem retry. Reproduzido 6 vezes no app e 6 vezes via curl. | BACK (emite done vazio e despeja JSON cru do provedor) + APP (não valida `content` vazio) |
| 2 | Alta | Cota free tier do Gemini estourada (`limit: 20 ... gemini-3.5-flash`). Depois de ~20 requisições, todo chat falha. | BACK / infra |
| 3 | Média | O timeout de 90 s sem eventos nunca disparou: com a rede pendurada, o app ficou em "Pensando..." por 145 s sem erro. | APP |
| 4 | Média | O histórico (`GET /ai/sessions/{id}`) devolve a mensagem do usuário com o bloco `<additional context>{...}</additional context>` injetado pelo backend. A UI exibe esse bloco na bolha do usuário. | BACK (vaza contexto interno), APP poderia filtrar |
| 5 | Média | Recarregar a página perde a conversa atual (`sessionId` só em memória). O app volta à saudação e o usuário precisa achar a conversa no histórico. | APP |
| 6 | Média | `FloatingIAAvatar` é código morto: não é instanciado em nenhuma tela. O botão flutuante não existe. | APP |
| 7 | Baixa | Resposta com LaTeX (`$$P/L = \frac{...}$$`) aparece como texto cru. O markdown não renderiza LaTeX. | APP (limitação) + BACK (prompt deixa o modelo emitir LaTeX) |
| 8 | Baixa | Blockquote com fundo azul claro e texto branco (contraste ruim). Régua `---` vira barra branca grossa. Bloco de código sem estilo. | APP |
| 9 | Baixa | Banner de erro mostra o JSON cru do provedor quando vem `error` parcial. HTTP 500 mostra só "Erro 500". | APP + BACK |
| 10 | Baixa | Resumos de sessão em inglês. A maioria das sessões fica "Nova conversa" (summary null). Sessões que falharam aparecem no histórico só com a pergunta. | BACK |
| 11 | Baixa | `POST /ai/chat` (não-stream) responde 200 com o JSON do erro 429 dentro de `content`. O app não usa essa rota (`sendMessage` sem chamadas). | BACK |
| 12 | Baixa | Apagar conversa sem confirmação. Após 401 o app mostra "Sua sessão expirou" mas não redireciona para o login (`logoutCallbackProvider` é no-op). Mensagem acima de 4000 caracteres é truncada em silêncio pelo `maxLength`. | APP |

Latências do backend: o primeiro evento `tool` chega ~10-11 s após `start`. A resposta final leva ~20-60 s. Até uma mensagem trivial ("Responda só ok") levou 13-16 s.

Limitação de teste: depois que a cota do Gemini acabou, só consegui reproduzir respostas reais do agente nas primeiras requisições (AAPL P/L OK, PETR4 dividend yield OK). Cenários de UI (erros, markdown, stop, watchlist) foram cobertos com `page.route` simulando o SSE.

## Funcionalidades mapeadas (código)

`ChatView` + `ChatNotifier` (SSE `/ai/chat/stream`), `SessionHistorySheet` (`/ai/sessions`, `GET`/`DELETE` `/{id}`), `TypingIndicator`, `_ToolChip`, `_ErrorBanner`, botão stop/enviar, botão nova conversa, botão histórico, `FloatingIAAvatar`, invalidação da watchlist quando a ferramenta `adicionar_a_watchlist`/`remover_da_watchlist` roda. Existem também `summary()` e `sendMessage()` no repositório, sem uso na UI.

## Resultados por funcionalidade

### 1. Tela inicial (saudação, layout) - ✅ OK
- Passos: login, clicar em IA Chat na barra inferior.
- Esperado/obtido: AppBar "Consultor de Ativos / Dados de mercado ao vivo", saudação do assistente, campo "Pergunte sobre um ativo...", botão enviar, ícones de histórico e nova conversa.
- Evidência: `02-chat-empty.png`. Rede: nenhuma chamada `/ai` ao abrir a aba.

### 2. Enviar mensagem e receber resposta (pergunta real sobre ativo) - ⚠️ Parcial
- Passos: "Qual a cotação atual da AAPL e como está o P/L dela?".
- Obtido (1ª tentativa, Gemini disponível): resposta correta e completa (USD 333,02, P/L 38,15), em markdown, adaptada ao perfil conservador. Dados batem com o card da Home. Tempo total ~59 s. Evidência: `03-aapl-final.png`, `curl-sse-aapl-success.txt`.
- Problemas: a resposta é longa demais para uma pergunta simples (aula sobre P/L, BACK/prompt). O texto chega de uma vez ou em poucos blocos e a bolha só aparece no fim (cada `token` do curl traz um pedaço, mas no app vi só os pontinhos até o fim, ver item 5). Aparece LaTeX cru (item 7 do resumo).
- Pergunta de watchlist ("Como está minha watchlist hoje?") e a sequência PETR4 + follow-up: falharam por 503/429 do Gemini (ver item 3 abaixo). Origem: BACK.

### 3. Erro do provedor de IA (503 / 429) - ❌ Falha (APP + BACK)
- Passos: enviar qualquer mensagem enquanto o Gemini está sobrecarregado ou sem cota.
- Esperado: mensagem de erro amigável e possibilidade de reenviar.
- Obtido: bolha vazia do assistente (pequena pílula escura) e nenhum aviso. Evidência: `04-watchlist-f09.png`, `05-petr4-q1.png`, `05-petr4-q2-followup.png`, `14-stream-a1-f03.png` (4 de 4 tentativas seguidas ficaram assim).
- Curl da mesma chamada (`curl-sse-503-then-empty-done.txt`):
```
event: start  data: {"session_id": "ba310877-...", "provider": "gemini", ...}
event: error  data: {"detail": "{\n \"error\": {\n \"code\": 503, \"message\": \"This model is currently experiencing high demand...\", \"status\": \"UNAVAILABLE\" ...", "request_id": "6dfc7aee525b"}
event: done   data: {"session_id": "ba310877-...", "content": ""}
```
  e depois, com cota esgotada: `"code": 429 ... Quota exceeded for metric: ...generate_content_free_tier_requests, limit: 20, model: gemini-3.5-flash. Please retry in 40s`.
- Causa:
  - BACK: o contrato diz que `done` é o terminador legítimo, mas o backend envia `done` com `content:""` depois de um `error` fatal. O `detail` é o JSON cru do Google (inclui links, quotas), e o `/ai/chat` não-stream faz pior, devolvendo isso como `content` com HTTP 200.
  - APP: `chat_viewmodel.dart` marca `terminouLimpo = true` ao ver `DoneEvent` e adiciona `ChatMessage(text: '')`, descartando o `ultimoErro`. Falta tratar `content` vazio como erro.
- Também persiste uma sessão sem resposta no histórico (item 10).

### 4. Indicador de digitando / "Pensando..." / chip de ferramenta - ⚠️ Parcial
- Obtido: pontinhos animados e o subtítulo "Pensando..." aparecem imediatamente (`03-aapl-t1.png`). O botão enviar vira "stop" cinza.
- Chip de ferramenta ("Consultando cotação...") e streaming token a token: NÃO observei na UI com o backend real. Em `03-aapl-t3.png` (13,5 s) e `t4` (28 s) ainda só havia pontinhos, embora o curl mostre eventos `tool` aos ~11 s. Não consegui isolar a causa porque a cota acabou; suspeita: buffering do XHR da web (dio/stream) ou timing. Marcado como indeterminado, vale repetir com cota liberada e com `flutter run -d chrome`.
- Com SSE simulado em uma resposta só (`13-err-tool.png`) o app mostra a resposta final corretamente (tabela inclusa).

### 5. Mensagem vazia / só espaços - ✅ OK
- Passos: botão enviar sem texto e Enter com 5 espaços. Nenhuma requisição `/ai` (rede vazia), nada é adicionado (`06-empty-whitespace.png`).
- Backend: `{"message":""}` -> 422 (`string_too_short`); `"   "` -> 200 (aceita só espaços, mas o app já faz trim).

### 6. Mensagem longa (limite 4000) - ⚠️ Parcial
- Passos: inserir 4500 caracteres no campo (`16-long-input.png`).
- Obtido: o campo trunca em 4000 (corpo da requisição de 4014 bytes) sem aviso. A mensagem de erro "Mensagem longa demais" é inalcançável.
- Backend: 4001 caracteres -> 422 `string_too_long` (10 ms). Comportamento consistente com o contrato.
- Origem: APP (truncamento silencioso, UX menor).

### 7. Caracteres especiais, emoji, HTML - ✅ OK
- Passos: `<script>alert(1)</script> **x** 😀 çãõ "aspas" $$ <b>b</b>`.
- Obtido: bolha do usuário em texto puro (sem executar HTML, sem interpretar markdown), emoji e acentos corretos (`15-special-chars-md.png`). Sem erros de console. (A barra invertida digitada não apareceu; é provável quirk do `keyboard.type` do Playwright, não confirmado.)

### 8. Renderização de markdown da resposta - ⚠️ Parcial
- Resposta simulada com H1/H2, negrito, itálico, código inline, link, bloco de código, lista, blockquote, `---`, tabela de 7 colunas e string longa sem espaços (`15-special-chars-md-top.png`).
- OK: tabelas (cabeçalho e colunas se ajustam), listas, links, negrito, quebra de linha da string longa sem overflow.
- Falhas (APP, `chat_view.dart` `MarkdownStyleSheet` só ajusta p/strong/table): blockquote com fundo azul claro e texto branco; `---` como barra branca grossa; bloco de código sem fundo diferenciado; LaTeX `$$...$$` cru (visto na resposta real: `03-aapl-final.png`, `09-session-aapl-opened.png`).
- BACK: o prompt do agente não deveria emitir LaTeX nem `---` em excesso.

### 9. Scroll - ⚠️ Parcial
- Mensagens longas: a lista rola para o fim ao responder, então o usuário cai no final de uma resposta de ~1 página e não no começo (`03-aapl-final.png`). Ao abrir uma conversa do histórico acontece o mesmo (`09-session-aapl-opened.png`). Funciona, mas é discutível. A AppBar fica esverdeada (scrolled-under tint) com o conteúdo por baixo.

### 10. Botão Stop (cancelar resposta) - ✅ OK
- Passos: resposta simulada com 9 s de atraso, clicar no stop após 1,5 s. Voltou o botão enviar, sumiram os pontinhos, e a resposta tardia não aparece depois (`17-after-stop.png`, `17-after-stop-9s.png`). O servidor não é avisado do cancelamento (só fecha o cliente).

### 11. Enviar segunda mensagem enquanto responde - ✅ OK
- O texto digitado permanece no campo e Enter é ignorado (`state.typing`); o botão vira stop (`17-typing-second-send.png`).

### 12. Erros de rede e HTTP (simulados) - ⚠️ Parcial
| Cenário | Resultado | Evidência |
|---|---|---|
| Conexão recusada | ✅ "Não foi possível falar com o assistente. Verifique sua conexão." | `13-err-abort.png` |
| 401 | ⚠️ "Sua sessão expirou. Entre novamente.", mas fica na tela do chat. O token é apagado e o próximo clique em Início cai no login. `onLogout` é no-op. | `13-err-401.png`, `19-after-401-home.png` |
| 502 | ✅ tratado (`mensagemAmigavel`) | `13-err-502.png` |
| 422 (detail lista) | ✅ "Mensagem inválida: ..." | `13-err-422.png` |
| 500 com corpo HTML | ⚠️ só "Erro 500" | `13-err-500html.png` |
| Stream com token parcial e depois `error` | ✅ preserva o texto parcial, mas o banner mostra JSON cru `{"error":{"code":503,...}}` | `13-err-partial.png` |
| `error` + `done` vazio | ❌ bolha vazia, erro engolido (ver item 3) | `13-err-errdone.png` |
| Sem nenhum evento por 90 s | ❌ o timeout não dispara: o app ficou em "Pensando..." por 145 s, sem erro nem como cancelar automaticamente (stop manual funciona) | `18-timeout-97s.png`, `18b-t145.png` |

- Sobre o timeout: `.timeout(_semEventos)` está no stream, mas o app trava esperando `_dio.post` (cabeçalhos) dentro do gerador `async*`, com `connectTimeout/receiveTimeout` zerados. Resultado: sem limite algum quando o servidor não responde nem os cabeçalhos. Origem: APP.

### 13. Histórico de conversas (lista) - ⚠️ Parcial
- `GET /ai/sessions?limit=50` abre o sheet em ~40 ms (`07-history-sheet.png`). Mostra "N troca(s) • dd/MM HH:mm". Ordem do mais novo ao mais antigo.
- Problemas (BACK): quase todas as conversas aparecem como "Nova conversa" porque `summary` é null; a única com resumo está em inglês ("The user requested the current price and P/E ratio..."). Sessões que falharam por 503/429 aparecem como conversas com 1 troca.

### 14. Abrir conversa do histórico - ❌ Falha (BACK, com mitigação possível no APP)
- Obtido: a bolha do usuário mostra o texto + `<additional context>{ "nome_do_usuario": ..., "perfil_de_investidor": ..., "watchlist": [...] }</additional context>` (`08-session-opened.png`).
- Curl: `GET /ai/sessions/28a11a42-...` -> `user: "Qual a cotação...?\n\n<additional context>\n{...nome_do_usuario...}"`. Também há mensagens `assistant` com content null (tool calls) que o app já filtra (`exibivel`).
- Origem: BACK grava o contexto injetado na mensagem do usuário. O app poderia remover o bloco, mas o correto é o backend não persistir/expor isso.

### 15. Nova conversa - ✅ OK
- O botão limpa a tela, volta a saudação e zera o `sessionId` (a próxima mensagem cria uma sessão nova; confirmado por `session_id` distinto em cada `start`). `10-new-conversation.png`.

### 16. Apagar conversa - ⚠️ Parcial
- `DELETE /ai/sessions/{id}` -> 204 (30 ms), lista recarrega e o item some (`11-after-delete.png`). Sem diálogo de confirmação (toque acidental apaga). DELETE de sessão que não existe: 204 na primeira vez, 404 `"Sessão não encontrada."` depois.
- Limpeza: as sessões criadas durante o QA (~17, ids a1d9c46a, 451847cb, ... e as de curl) NÃO foram removidas. A tentativa de apagar tudo em lote foi bloqueada pelo classificador de permissões; apague pelo app se necessário. Os dados de watchlist da conta não foram alterados.

### 17. Persistência após reload - ❌ Falha (APP)
- Passos: abrir conversa do histórico, `F5`. A rota continua `#/chat` e a tela volta à saudação, sem a conversa (`12-after-reload.png`). O token persiste (não desloga), mas o `sessionId` não. Esperado: retomar a última conversa (ou no mínimo a conversa continuar acessível, o que o histórico permite).

### 18. Contexto entre mensagens (follow-up) - ⏭️ Não testável
- Cota do Gemini esgotada impediu a segunda mensagem na mesma sessão. O app reenvia `session_id` do `StartEvent` (verificado no código). Retestar com cota.

### 19. Ações na watchlist pelo agente (invalidação do Home) - ✅ OK (simulado)
- SSE simulado com `tool: adicionar_a_watchlist` + `done`: ao terminar o app dispara `GET /profile/watchlist` e recarrega ativos/histórico/notícias (rede capturada). A ferramenta real não foi exercitada (cota), nem o efeito no backend.

### 20. Avatar flutuante global (`FloatingIAAvatar`) - ❌ Falha (APP)
- `grep` não encontra nenhum uso do widget fora do próprio arquivo, e o Home (`01-home.png`) não mostra o botão. Código morto (também usa rota `/chat` com `context.go`). Ou remover ou instanciar no shell.

### 21. Autenticação nas rotas `/ai` - ✅ OK
- Sem token: 401 `{"detail":"Not authenticated"}`. Token inválido: 401 `"Token inválido ou expirado"`. Com token: 200.
- Observação: o `session_id` é aceito pelo cliente mesmo inexistente ("nao-existe" criou sessão com contexto). Não testei acesso cruzado entre usuários (só há um usuário); vale uma revisão de autorização por dono da sessão no backend.

### 22. Console / rede gerais - ✅/⚠️
- Nenhum `pageerror` nem exceção Dart no console durante o chat.
- Console do browser (não é do chat, é da Home): `Access to image at 'https://www.google.com/s2/favicons?domain=apple.com&sz=128' ... blocked by CORS` e `ERR_FAILED` (favicons dos ativos). APP, fora do escopo do chat.
- Latências `/ai`: `POST /ai/chat/stream` abre em 12-32 ms (cabeçalho), `GET /ai/sessions` 17-40 ms, `GET /ai/sessions/{id}` 32-38 ms, `DELETE` 30 ms. O gargalo é a geração do LLM (10-60 s).

## Recomendações priorizadas
1. APP: tratar `DoneEvent.content` vazio como erro, exibindo o `ultimoErro` formatado, com botão "Tentar de novo". Traduzir o `detail` (códigos 429/503 -> mensagem amigável).
2. BACK: não emitir `done` após um `error` fatal; mandar `detail` legível (sem JSON do Google); implementar fallback para Groq quando o Gemini falhar; revisar cota/plano do Gemini. Corrigir `/ai/chat` que devolve o erro como `content` 200.
3. APP: timeout real quando o servidor não responde (por exemplo `Future.timeout` no `_dio.post` ou `sendTimeout`/`receiveTimeout` no cabeçalho).
4. BACK: não gravar/expor `<additional context>` no histórico; gerar `summary` em português para todas as sessões.
5. APP: persistir o `sessionId` (storage) e reabrir a última conversa após reload; confirmar antes de apagar; decidir o destino do `FloatingIAAvatar`.
6. APP: estilizar blockquote, `---` e code block; considerar suporte a LaTeX ou instruir o agente a não usar. Mostrar o chip de ferramenta com streaming real (verificar buffering do XHR na web).
