# Reteste QA - aba IA Chat (Fase 2, após correções de APP)

Data: 2026-10-01. Ambiente: Flutter web debug em `localhost:8080` (código corrigido), backend `localhost:8000`, Chromium próprio via Node playwright-core (contexto novo, viewport 929x965), console + `pageerror` + rede capturados. Evidências em `docs/qa/evidence/retest/ia-chat/`.
Backend real respondeu desta vez (Gemini sem erro: "responda apenas ok" voltou `ok`). Cenários de erro/markdown/stop usaram SSE simulado por `page.route` (formato de `docs/qa/evidence/ia-chat/curl-sse-*.txt`).

## Resultado por ID

| ID | Resultado | Evidência |
|---|---|---|
| B05 erro + done vazio | ✅ | `event:error`(503) + `done content:""`: sem bolha vazia; banner "O assistente está indisponível. Tente em alguns instantes." + "Tentar de novo" (`b05-1-erro.png`). Clique reenviou: 2 POSTs (o 2º com `session_id`), uma só bolha do usuário, resposta aparece (`b05-2-retry.png`). |
| B07 timeout de rede pendurada | ✅ | Request nunca respondida: "Pensando..." a 80 s (`b07-t80.png`); erro "O assistente parou de responder. Tente de novo." já a 86 s (`b07-t86.png`, `b07-t92.png`). `pageerror` = [] e nenhum TimeoutException no console (`b07-console.txt`). Não usei `page.clock` (esperei em tempo real); o erro caiu entre 80 e 86 s, coerente com o limite de ~85 s. |
| B08 `<additional context>` no histórico | ✅ | Com GET simulado devolvendo o bloco, a bolha mostra só "Qual a cotação da AAPL?" (`b08-1-open-with-context-mock.png`). O backend real atual já não devolve o bloco (`curl-session-history.json`). |
| B09 persistência da conversa | ✅ | Reload (F5) e nova visita reabrem a última conversa via `GET /ai/sessions/{id}` (`b09-1-restored.png`, `b09-3-after-F5-chat.png`). Botão "nova conversa" + reload: volta à saudação, não reabre (`b09-5-after-nova-reload.png`). Ver N1. |
| B10 avatar flutuante | ✅ | Removido: `grep FloatingIAAvatar lib` sem resultados; Home sem botão (`b10-home-no-avatar.png`). |
| B11 markdown / LaTeX | ✅ | Escuro e claro (alternado em Config): blockquote com fundo verde-escuro/claro e texto legível, `---` linha fina, bloco de código com fundo, código inline, tabela, lista (`b11-md-dark.png`, `b11-md-light.png`). `$$\frac{a}{b}$$`, `\text{}` e `\times` viram texto legível ("(Preço)/(Lucro)", "DY = (D)/(P) × 100"). Limite: LaTeX inline `$E=mc^2$` continua cru (não é tratado; baixo impacto). |
| B12 banner sem JSON cru | ✅ | Erro parcial (token + `error` com JSON do Google): mantém "Texto parcial" e mostra "O assistente está indisponível..." (`b12-1-parcial.png`). HTTP 500 com corpo HTML: "O assistente teve um problema. Tente de novo." (`b12-2-500html.png`). |
| B12 contador 3800/4000 | ✅ | 3790: sem contador; 3805: "3805/4000" (`b12-7-3805.png`); 4000: "Limite de 4000 caracteres atingido" em vermelho + "4000/4000" (`b12-8-limit.png`). |
| B12 confirmação ao apagar | ✅ | Diálogo "Apagar conversa? Esta conversa será apagada e não poderá ser recuperada." Cancelar/Apagar (`b12-3-confirm-dialog.png`). Cancelar: nenhum DELETE na rede. Apagar: `DELETE /ai/sessions/e11cc25b-...` 204, lista recarregada sem o item (`b12-5-after-confirm.png`). |

## Regressão (antes ✅)

| Item | Resultado | Evidência |
|---|---|---|
| Tela inicial | ✅ | `01-chat-empty.png` |
| Mensagem vazia / só espaços | ✅ | Nenhuma chamada `/ai` (rede: 0), nada adicionado (`reg-empty.png`) |
| Caracteres especiais / HTML / emoji | ✅ | Texto puro, sem executar HTML (`reg-special.png`) |
| Nova conversa | ✅ | `b09-4-nova.png` |
| Listar histórico | ✅ | `hist-1-sheet.png` (resumo agora em português: "O usuário pediu que o assistente respondesse apenas "ok"...") |
| Stop | ✅ | Resposta atrasada 9 s, stop em 1,5 s: sem bolha tardia aos 9 s (`reg-stop-2-after9s.png`) |
| Resposta real do backend | ✅ | "ok" renderizado (`real-2-75s.png`) |
| Console | ✅ | `pageerror` vazio em todos os cenários. Só o ruído já conhecido de favicons do google.com (CORS, B22, fora do escopo). |

## Novas regressões / observações

- N1 (BACK, Média): `GET /ai/sessions/{id}` agora devolve a mensagem do usuário DUPLICADA (`curl-session-history.json`: duas entradas `user` iguais, depois `assistant`). Ao reabrir a conversa (histórico ou restauração após F5) a bolha do usuário aparece 2 vezes (`b09-3-after-F5-chat.png`). Provável efeito do contexto injetado ser gravado como mensagem separada do usuário; o app remove o bloco, mas sobra o texto repetido. Sugestão: backend não duplicar ou o app deduplicar mensagens `user` consecutivas idênticas.
- N2 (APP, Baixa): conversa restaurada/aberta do histórico não mostra a saudação do assistente (esperado, só rola ao fim). Sem ação.
- B13 (chip de ferramenta e streaming token a token no browser real) segue ⏭️ não verificado: a resposta real foi trivial e não disparou ferramentas.
- Follow-up com contexto (B18 do relatório anterior): ⏭️ não repetido; retomada via `session_id` confirmada na rede (2º POST do retry leva `session_id`).

## Limpeza

Sessão real criada (`QA-Retest real: responda apenas ok`, `e11cc25b-...`) apagada pela UI com a nova confirmação (204). As demais chamadas usaram SSE simulado e não criaram sessões no backend. Sessões antigas ("Nova conversa", 0 trocas) de testes anteriores não foram tocadas.
