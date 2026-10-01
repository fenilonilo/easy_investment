# QA - Aba Perfil (Easy Finance)

Data: 2026-10-01. Ambiente: Flutter web (localhost:8080) + FastAPI (localhost:8000). Chromium headless próprio (Playwright), contexto persistente isolado. Conta de teste compartilhada (a watchlist já continha AAPL e PETR4.SA, alterada por outro agente; foi restaurada a esse estado ao final).
Evidências: `docs/qa/evidence/perfil/`. Código-fonte não foi alterado.

## Funcionalidades mapeadas (profile_view.dart / profile_viewmodel.dart)
1. Exibição dos dados do usuário (nome, nascimento, e-mail, senha mascarada)
2. Edição de e-mail (validação + salvar)
3. Edição de perfil de investidor (dropdown)
4. Botão "Salvar Alterações" (aparece só com diff)
5. Watchlist: listagem (chips), remoção, busca de ativos, adição, persistência
6. Logout (ícone na AppBar)
7. Loading (shimmer) / erro de carga

## Resultados

### 1. Dados do usuário exibidos - ❌ Falha (APP, agravante BACK)
- Passos: login com usuário de teste, abrir aba Perfil.
- Esperado: Nome "Usuario Teste", nascimento 2001-01-01, e-mail do usuário, perfil CONSERVATIVE.
- Obtido: Nome, Data de Nascimento e E-mail aparecem VAZIOS (só hint). O perfil mostra "Conservador" apenas pelo default `'CONSERVATIVE'` do state. Evidência: `03_perfil.png`.
- Rede: após o login só há `POST /auth/login` 200 e `GET /profile/watchlist`; nenhuma chamada de dados do usuário.
- Causa: `ProfileNotifier._init` lê `UserStorageService.readUser()` (secure storage, chave `user_data`). `saveUser` só é chamado em `updateProfile` (profile_viewmodel.dart:170); o login (`auth_repository_impl.dart`) nunca grava o usuário. Logo `user == null`.
- Origem: APP (não persiste/busca o usuário no login). Agravante BACK: o OpenAPI não tem `GET /user/me` (só register/update/delete) e `/auth/login` devolve apenas o token (o `sub` do JWT é o id).

### 2. Edição de e-mail - ❌ Falha (APP)
- 2a. Validação: digitar "abc" e salvar mostra "Email inválido", sem requisição. ✅ OK (`20_invalid_email_save.png`).
- 2b. Caminho feliz: trocar e-mail para `qa-perfil@example.com` e salvar.
  - Esperado: `PUT /user/update/{id}` e snackbar "Perfil atualizado!".
  - Obtido: NENHUM PUT enviado (log de rede vazio) e snackbar verde "Watchlist atualizada!" (`21_valid_email_save_a.png`). Após reload o e-mail volta a vazio.
  - Causa: `updateProfile` faz `if (user == null) return;` silenciosamente (consequência do item 1); depois `saveChanges()` roda sem diffs e mostra sucesso. O usuário acredita ter salvo, mas nada foi enviado.
  - Origem: APP (retorno silencioso + mensagem de sucesso enganosa), dependente do item 1.
- Se `user` existisse, o PUT enviaria `{id,name,email,investor_profile}`, compatível com `UserUpdate` do OpenAPI. Esse caminho não pôde ser exercitado pela UI. Não executei `PUT /user/update` via curl para não alterar o e-mail da conta compartilhada de login.

### 3. Perfil de investidor (dropdown) - ⚠️ Parcial
- O dropdown abre com Conservador / Moderado / Agressivo e o FAB "Salvar Alterações" aparece (`22_dropdown.png`). Salvar sofre do mesmo problema do item 2. Seleção não testada ponta a ponta. Origem: APP (item 1).

### 4. Botão Salvar Alterações - ⚠️ Parcial
- Aparece só com diff (e-mail/perfil alterado ou watchlist diferente) ✅. A mensagem de sucesso é sempre "Watchlist atualizada!", mesmo quando só o perfil mudou. `saveChanges` zera `successMessage`/`error` (via `copyWith`), apagando o resultado de `updateProfile`; se `updateProfile` falhar, o erro some e aparece sucesso (análise de código). Origem: APP.

### 5. Watchlist
- 5a. Listagem/persistência - ✅ OK. `GET /profile/watchlist` 200; chips AAPL e PETR4.SA; permanecem após reload (`03_perfil.png`, `62_reload.png`).
- 5b. Busca - ✅ OK. `GET /assets?search=MSFT` 200, debounce de 400 ms, shimmer durante a busca, resultados com ticker/nome (`31_results.png`). Caracteres especiais (`%&?#`) codificados corretamente, 200. Campo vazio limpa resultados sem requisição.
- 5c. Busca sem resultado - ⚠️ Parcial (APP, UX). "zzzzqq" retorna 200 `[]`; a tela fica em branco, sem "nenhum ativo encontrado" (`32_noresults.png`; `SearchResultsList` devolve `SizedBox.shrink()`). Erro de rede na busca também é engolido (`catch (_)`).
- 5d. Adicionar - ✅ OK. Adicionar MSFT (ícone +); o FAB aparece (`40_added_unsaved.png`); salvar envia `POST /profile/watchlist/add` body `[{"ticker":"MSFT","name":"Microsoft Corporation","icon_url":"..."}]` com 200 e snackbar "Watchlist atualizada!". Persistiu após reload e foi confirmado via curl.
- 5e. Remover - ✅ OK. X no chip MSFT e salvar enviam `POST /profile/watchlist/remove` `[{"ticker":"MSFT"}]` com 200; persistiu após reload (`61_removed_saved.png`, `62_reload.png`).
- 5f. Bordas de backend (curl): add duplicado retorna 400 "Todos os ativos já estão na sua lista."; remover inexistente retorna 404; add com lista vazia retorna 400 (mesma mensagem, semanticamente estranha); sem token retorna 401. Em qualquer erro o app só mostra "Erro ao salvar." (por exemplo, se outro dispositivo já adicionou o ativo, o salvar inteiro falha). Origem: APP (mensagem genérica) / BACK (400 para lista vazia).
- 5g. BACK: `POST /profile/watchlist/add` aceita ticker inexistente (`ZZZZ99X` retorna 200 `added_count:1`), sem validar contra `/assets`. Reproduzido via curl e removido em seguida.
- 5h. Esvaziar a watchlist inteira - ⏭️ Não testado pela UI, para não afetar os outros agentes (conta compartilhada).

### 6. Logout - ✅ OK
- O ícone de sair na AppBar leva a `/login` (`63_logout.png`); abrir `#/profile` depois permanece na tela de login (guard funciona). Não há chamada de rede (logout local). Não verifiquei se o `user_data` é limpo no logout.

### 7. Loading / erro de carga - ⚠️ Parcial
- O shimmer existe no código, mas a carga é rápida e não foi capturado. Se `getWatchlist` falhar, aparece só um snackbar "Erro ao carregar perfil." e a tela segue com campos vazios, sem "tentar novamente" (não simulado; análise de código).

## Console / log
- Nenhuma exceção Dart na aba Perfil; `$TEMP/flutter_web.log` sem erros relevantes.
- Console (aparece ao carregar ativos da watchlist): `Access to image at 'https://www.google.com/s2/favicons?domain=apple.com&sz=128' ... blocked by CORS policy` + `net::ERR_FAILED`. Os chips mostram só a letra do ativo. Origem: APP/web (imagem externa sem CORS), não o backend.
- Aviso do browser na tela de login: `[DOM] Password field is not contained in a form` (cosmético).

## Resumo de bugs
| # | Sev. | Origem | Descrição |
|---|------|--------|-----------|
| 1 | Alta | APP (+BACK sem GET /me) | Nome, nascimento e e-mail vazios no Perfil: usuário nunca gravado no login |
| 2 | Alta | APP | Salvar e-mail/perfil não envia PUT e mostra "Watchlist atualizada!" |
| 3 | Média | APP | `saveChanges` sobrescreve mensagens/erros de `updateProfile` |
| 4 | Baixa | APP | Busca sem resultado/erro sem feedback; erro de salvar genérico |
| 5 | Média | BACK | `watchlist/add` aceita tickers inexistentes |
| 6 | Baixa | APP/web | Ícones favicon bloqueados por CORS |

Limpeza: watchlist final = AAPL, PETR4.SA (como encontrada); MSFT e ZZZZ99X removidos. Dados do usuário não alterados.
