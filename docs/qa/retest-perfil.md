# Reteste - Aba Perfil (Fase 2)

Data: 2026-10-01. App http://localhost:8080 (código corrigido), back http://localhost:8000. Chromium próprio (Node Playwright), contexto novo (viewport 430x900), interação por coordenadas, console e rede capturados; erros simulados com `page.route`. `lib/` não foi alterado.
Evidências: `docs/qa/evidence/retest/perfil/`.

Conta criada via Cadastre-se (NÃO salva em CLAUDE.md): **QA-Retest Usuario / qa-retest-b02@example.com / Teste@12345** (nasc. 2001-01-01). Ao longo do teste o e-mail passou a `qa-retest-b02-novo@example.com` e o perfil a MODERATE (PUT real, 200). Watchlist dessa conta: vazia ao final (MSFT adicionado e removido). Conta de teste original: não foi alterada (apenas leituras); conferido por API ao final: AAPL, PETR4.SA.

## Resultado por ID

| ID | Status | Resumo |
|----|--------|--------|
| B02 | ✅ (com ressalva de back) | Caminho 1: aviso. Caminho 2: dados preenchidos. |
| B03 | ✅ | Sem usuário: erro claro, sem PUT, sem "Watchlist atualizada!". Com usuário: PUT enviado, sucesso depois. |
| B04 | ✅ | 400/404/422/500/sem rede mapeados; erro não é sobrescrito. |
| B26 | ✅ | Sem resultado, erro de busca e erro de carga com "Tentar novamente". |
| Regressão | ✅ | Listar/buscar/adicionar/remover/persistência/validação de e-mail. |

### B02 - ✅
- Caminho 1 (login da conta de teste, sem usuário salvo no browser): `POST /auth/login` 200 não traz `user`; Perfil mostra "Dados do usuário indisponíveis. Saia e entre novamente." com Nome/Nascimento/E-mail vazios. Esperado pelo desenho. `b02_login_sem_usuario.png`. Ressalva: continua impossível, só pelo app, ver os dados de uma conta existente enquanto o back não devolver o usuário no login (ou expor GET /me).
- Caminho 2 (conta criada pelo cadastro, `POST /user/register` 201 + login automático): Nome "QA-Retest Usuario", Nascimento "2001-01-01", E-mail e perfil Conservador preenchidos, sem aviso. Persistem após reload. `b02_cadastro_perfil.png`, `b02_cad_reload.png`.

### B03 - ✅
- Sem usuário: digitar e-mail válido e salvar, snackbar "Dados do usuário indisponíveis. Saia e entre novamente."; nenhuma requisição enviada; nenhum "Watchlist atualizada!". `b03_c_sem_usuario_salvar.png`.
- Com usuário: `PUT /user/update/{id}` body `{id,name,email,investor_profile}` 200, snackbar verde "Perfil atualizado!" só depois do 200. `b03_sucesso_perfil.png`. Mudar só o dropdown (Moderado) também envia PUT com `MODERATE` e persiste. `reg_dropdown_salvo.png`, `reg_remover_salvo.png`. Alterando só a watchlist: apenas `POST /profile/watchlist/remove` e "Watchlist atualizada!" (mensagem correta ao tipo de alteração).
- Combinado (e-mail + novo ativo, PUT ok): PUT 200 e `POST /profile/watchlist/add` 200 em sequência. A segunda mensagem ("Watchlist atualizada!") não foi capturada no screenshot (a fila de snackbars ainda mostrava "Perfil atualizado!" aos ~4,3 s); a requisição foi enviada e persistiu. `b03_sucesso_watchlist.png`. ⚠️ observação menor, não bug comprovado.

### B04 - ✅
Erros simulados em `PUT /user/update/*`, cada um com snackbar e sem mensagem de sucesso:
- 400 `{"detail":"E-mail já cadastrado."}` mostra "E-mail já cadastrado." (`b04_400.png`)
- 404 mostra "Usuário não encontrado." (`b04_404.png`)
- 422 mostra "Dados inválidos." (`b04_422.png`)
- 500 mostra "Erro ao atualizar perfil." (`b04_500.png`)
- Sem rede (abort) mostra "Sem conexão com o servidor." (`b04_abort.png`)
- Erro não sobrescrito: com e-mail em 400 + ativo MSFT pendente, aparece só "E-mail já cadastrado."; `saveChanges` não roda (nenhum POST add) e MSFT permanece não salvo. `b04_erro_com_watchlist.png`.

### B26 - ✅
- Busca "zzzzqq" (200 `[]`): "Nenhum ativo encontrado." `b26_sem_resultado.png`.
- Busca com 500 simulado: "Erro ao buscar ativos. Tente novamente." `b26_erro_busca.png`.
- Falha de `GET /profile/watchlist` (abort): tela "Erro ao carregar perfil." + botão "Tentar novamente"; ao restaurar a rede, o clique recarrega o perfil (novo GET 200). `b26_erro_carga.png`, `b26_retry.png`.

### Regressão do que era ✅ - ✅
- Listar watchlist (chips AAPL/PETR4.SA na conta de teste, `GET /profile/watchlist` 200). Buscar "MSFT" (resultados com ticker/nome, `reg_busca.png`). Adicionar MSFT, salvar, `POST /watchlist/add` 200 com body correto. Persistência após reload (`reg_persistencia_reload.png`). Remover MSFT, salvar, `POST /watchlist/remove` 200 `[{"ticker":"MSFT"}]` (`reg_remover_salvo.png`).
- Validação de e-mail: "abc" mostra "Email inválido" e salvar não envia nada (`b03_b_email_invalido.png`).

## Console / rede
- Requisições com status >= 400: apenas as simuladas (PUT 400/404/422/500, GET search 500). Nenhum 4xx/5xx real.
- Console: sem exceções Dart. Persiste o CORS dos favicons do Google (`ERR_FAILED`), fora de escopo (B22).

## Novas regressões
Nenhuma encontrada. Observação: o fluxo de e-mail/dados de conta existente continua dependendo do back (login sem `user`); sem isso o usuário que apenas faz login em outro browser/dispositivo não consegue editar e-mail/perfil pelo app (só vê o aviso).
