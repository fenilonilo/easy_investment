# QA — Aba Config (Easy Finance)

Ambiente: app web `localhost:8080` (debug), backend `localhost:8000`, Chromium headless próprio (Playwright, contexto novo), viewport 929x965, usuário de teste do CLAUDE.md.
Código lido: `config_view.dart`, `theme_service.dart`, `locale_service.dart`, `auth_viewmodel.dart`, `auth_interceptor.dart`, `dio_client.dart`, `app_router.dart`, `secure_storage_service.dart`, `app.dart`.
Evidências: `docs/qa/evidence/config/`. Nada foi alterado no código do app; a conta de teste não foi modificada (browser próprio, nada a reverter).

## Funcionalidades existentes na aba
Modo Escuro (switch), Idioma (dropdown PT-BR/EN-US), Versão (estático "1.0.0"), Privacidade (texto estático), Sair da conta (diálogo de confirmação). Não existem notificações, links ou outras opções.

## Resumo
| # | Funcionalidade | Status | Origem |
|---|---|---|---|
| 1 | Tema escuro/claro: efeito imediato | ✅ | - |
| 2 | Tema: persistência após reload | ✅ | - |
| 3 | Idioma: troca do dropdown | ⚠️ Parcial | APP |
| 4 | Idioma: persistência | ✅ | - |
| 5 | Versão / Privacidade (estáticos) | ✅ (⚠️ texto) | APP |
| 6 | Logout: diálogo Cancelar / Sair | ❌ Falha crítica | APP |
| 7 | Guard de rota sem token | ✅ | - |
| 8 | 401 com token inválido/adulterado | ⚠️ Parcial | APP (backend OK) |

## 1. Modo Escuro — ✅
Passos: Config, clicar no switch (865,141). Esperado: tema claro imediato. Obtido: fundo/cards claros, subtítulo "Inativo" (`03-theme-light.png`; estado inicial `02-config.png`). Cor do tema vale para o app todo (home em `08-home-en.png` está claro).
Nota menor: subtítulo ativo diz "Ativo (OLED)", mas o fundo é cinza `#121212`, não preto OLED.

## 2. Persistência do tema — ✅
`localStorage["flutter.is_dark_theme"]="false"` após o toggle; após `reload` em `#/config` continua claro (`04-theme-light-reload.png`). Default (sem pref) é escuro.

## 3. Idioma — ⚠️ Parcial (APP)
Passos: abrir dropdown (`05-dropdown.png`), escolher EN-US. Esperado: UI em inglês. Obtido: apenas o subtítulo do tile muda para "English (US)" e o dropdown para EN-US (`06-lang-en.png`); todo o resto permanece em português: título "Configurações", seções, abas (Início/Perfil/IA Chat/Config), Home ("Alta"/"Baixa", "Gráficos") em `08-home-en.png`.
Causa (APP): `config_view.dart` usa strings literais em PT; `app.dart` não registra `AppLocalizations.delegate` (só Material/Widgets/Cupertino), embora `lib/l10n/*` exista (gerado) e tenha chave `logout`. Só o locale do Material (datas, tooltips) muda.

## 4. Persistência do idioma — ✅
`localStorage["flutter.locale_code"]="\"en\""`; após reload o dropdown continua EN-US (`07-lang-en-reload.png`).

## 5. Versão / Privacidade — ✅ com ressalvas (APP)
Itens estáticos, sem ação. Versão "1.0.0" hardcoded (não lê pubspec/package_info). Texto "Seus dados ficam apenas neste dispositivo" é impreciso: login, watchlist e chat vão ao backend.

## 6. Logout — ❌ FALHA CRÍTICA (APP)
Passos: Config, clicar "Sair da conta" (diálogo em `10-logout-dialog.png`), clicar "Sair" (ou "Cancelar").
Esperado: token removido, redirecionamento para `/login`; Cancelar apenas fecha o diálogo.
Obtido: ao clicar em QUALQUER botão do diálogo a tela fica totalmente branca (`12-crash-white-screen.png`, `14-cancel.png`), URL continua `#/config`, o token continua no storage (`FlutterSecureStorage.auth_token` presente) e o logout nunca executa. Só um reload recupera (`15-reload-after-crash.png`). Esc fecha o diálogo normalmente (`11-after-escape.png`), mas sem sair.
Evidência (console do browser):
```
EXCEPTION CAUGHT BY GESTURE
Assertion failed: go_router-14.8.1/lib/src/delegate.dart:162:7
currentConfiguration.isNotEmpty
"You have popped the last page off of the stack, there are no pages left to show"
...package:flutter/src/widgets/navigator.dart pop
package:easy_finance/presentation/views/config/config_view.dart 113:52 <fn>
Another exception was thrown: Assertion failed: .../navigator.dart:4081:12
```
(trecho completo salvo em teste; o log do `flutter run` só tem o boot, não repassa o console do browser.)
Causa (APP, certa): em `config_view.dart` o `builder: (_) => AlertDialog(...)` ignora o contexto do diálogo e os botões chamam `Navigator.pop(context, ...)` com o `context` da tela (build do ConfigView, dentro do shell do go_router). O pop remove a rota Config (última página) em vez do diálogo, estourando a assertion do go_router; o Future do `showDialog` nunca completa, então `logout()` + `context.go('/login')` nunca rodam. Correção: usar o contexto do builder (`builder: (ctx) => ... Navigator.pop(ctx, true)`).
Pontos adicionais de logout (por leitura de código; não exercitáveis por causa do bug): `logout()` só limpa `auth_token`; `user_data` (UserStorageService) não é limpo — hoje nunca é gravado, mas fica pendente. Não há endpoint de logout no backend (não necessário com JWT stateless).

## 7. Guard de rota sem token — ✅
Com o token removido do localStorage (simulando logout) e `goto #/home` + reload: redireciona para `#/login` (`20-delete.png`), sem chamadas à API. `#/config` sem token idem (lógica em `app_router.dart` redirect, rotas públicas `/`, `/login`, `/register`). Ressalva: o guard só verifica EXISTÊNCIA do token, não validade.

## 8. 401 / token inválido — ⚠️ Parcial (APP; BACK correto)
Token forjado com a mesma chave AES do storage web (WebCrypto) para testar o app de verdade.
- Token `garbage.invalid.token`, reload em `#/home`: `GET /profile/watchlist -> 401`; a home exibe "Erro ao carregar dados." com "Tentar novamente" (`20-garbage.png`), URL permanece `#/home` (usuário NÃO é levado ao login). O interceptor limpou o token (LS sem `auth_token`); só ao clicar em outra aba o guard redireciona a `#/login`.
- Token real com assinatura adulterada, em `#/config` (que não chama API): nenhuma requisição, token permanece; ao ir para Início: 401, mesma tela de erro genérico, sem redirecionar (`21-tamper-nav.png`).
Backend (curl): `GET /profile/watchlist` com `Bearer garbage.invalid.token` -> `401 {"detail":"Token inválido ou expirado"}`; sem header -> `401` com `www-authenticate: Bearer`. Comportamento correto.
Causa (APP): `AuthInterceptor.onError` chama `onLogout()`, mas `logoutCallbackProvider` (dio_client.dart) nunca é sobrescrito em lugar nenhum do app (default `() {}`), então a sessão expirada não redireciona para o login e a mensagem de erro é genérica (não diz "sessão expirada").

## Outros achados
- Console em login/home: erros de CORS ao carregar favicons `https://www.google.com/s2/favicons?...` (APP/externo, afeta ícones dos ativos; não é da aba Config).
- Rede: todas as chamadas durante os testes foram 200, exceto os 401 provocados acima. A aba Config não faz chamadas de API.
