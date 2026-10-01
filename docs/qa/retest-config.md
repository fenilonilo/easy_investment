# Reteste Config / sessão-401 (Fase 2) — Easy Finance

Ambiente: app web `localhost:8080` (código corrigido), backend `localhost:8000`, Chromium próprio (Playwright, contexto novo por cenário, 929x965), usuário de teste do CLAUDE.md. Evidências: `docs/qa/evidence/retest/config/`. Nada em `lib/` alterado; senha/conta intactas; contexto descartável (tema/idioma não persistem fora dele).
Método do 401: o back respondeu 401 de verdade; um `page.route` trocou só o header `Authorization` por `Bearer garbage.invalid.token` (equivale a token expirado/inválido).

## Resultado por ID
| ID | Status | Evidência |
|---|---|---|
| B01 logout | ✅ | Cancelar: diálogo fecha, URL segue `#/config`, token no LS (`13-cancel.png`). Sair: vai a `#/login`, `FlutterSecureStorage.auth_token` removido (`14-logout.png`). Sem tela branca, sem pageerror/"popped the last page", sem chamada de rede. |
| B15 401 → sessão expirada | ✅ | Início (refresh, `GET /profile/watchlist 401`), Config→Início (idem) e IA Chat (`POST /ai/chat/stream 401`): sempre `#/login`, token limpo e snackbar "Sessão expirada. Faça login novamente." (`17-inicio-401-snack.png`, `19-config-to-inicio-snack.png`, `21-chat-401.png`). Config sozinha não chama API: reload em `#/config` com token ruim não faz requisição e permanece (`18`); expira ao ir para Início (esperado, comportamento igual ao anterior). |
| B15b senha errada | ✅ | `POST /auth/login 401` → só "Email ou senha incorretos.", fica em `#/login`, sem "sessão expirada" (`02-wrong-password.png`). |
| B27 logout limpa user_data | ✅ (⚠️ ressalva) | `user_data` só é gravado em cadastro/salvar perfil; não aparece no login normal. Plantei `FlutterSecureStorage.user_data` no LS, fiz logout: sumiu junto com o token; só resta a chave `FlutterSecureStorage` (chave AES) (`16-logout-userdata.png`). |
| B27 texto privacidade | ✅ | "Seu token e perfil ficam salvos de forma segura neste dispositivo" (`04-config.png`). |
| B27 versão | ⚠️ inalterada | Continua "1.0.0" literal (não lê pubspec). Subtítulo "Ativo (OLED)" com fundo `#121212` também inalterado. |
| B10 avatar flutuante | ✅ | Ausente em Início (`03-home.png`), Chat (`20-chat.png`) e Config. |

## Regressão
- Tema escuro/claro: ✅ imediato (`05-theme-toggled.png`), `flutter.is_dark_theme=false/true` no LS; persiste após reload (`06-light-after-reload.png`).
- Idioma: ⚠️ B19 inalterado (fora de escopo): só o subtítulo muda para "English (US)"; resto em PT (`08-lang-en.png`). Persiste: `flutter.locale_code="en"` após reload (`09-lang-en-reload.png`).
- Guard sem token: ✅ pós-logout `#/home` e `#/config` → `#/login`, sem chamadas à API (`15-guard-home.png`).
- Login normal: ✅ `POST /auth/login 200`, watchlist/ativos/histórico/news 200, vai a `#/home`.
- LS pós-login: `FlutterSecureStorage` (chave) + `FlutterSecureStorage.auth_token` (cifrado); após ações aparecem `flutter.is_dark_theme`, `flutter.locale_code`. Pós-logout: só `FlutterSecureStorage`.
- Console: só erros CORS de favicons Google (B22, fora de escopo).

## Novas regressões / achados
- **R1 (baixa, APP)**: se o valor de `FlutterSecureStorage.auth_token` no LS não for um payload cifrado válido (edição manual/corrupção do storage, não é JWT expirado), `readToken()` lança `FormatException: Invalid length, must be multiple of four` (pageerror) e o app fica em tela branca em `#/home`, sem limpar o storage nem ir ao login (`22-corrupted-storage-token.png`). Sugestão: try/catch em `SecureStorageService.readToken` (limpar e devolver null). Cenário improvável fora de teste; token cifrado válido mas inválido para o back (caso real) funciona (B15 ✅).
- Nenhuma outra regressão.
