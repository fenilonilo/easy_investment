# Finance Pro — Plano de Execução

> Base: `finance_pro_sdd.md` + API `127.0.0.1:8000` validada.
> Stack: Flutter (SDK ^3.11) + MVVM + Riverpod + Dio + go_router.

---

## Decisões (confirmadas)

| # | Tópico | Decisão |
|---|--------|---------|
| 1 | State management | **Riverpod** |
| 2 | IA Chat | **Mock local** (sem backend) |
| 3 | Reset Password | **Pular feature** |
| 4 | News Ticker global | **Agregar news da watchlist** |
| 5 | Routing | **go_router** |

---

## API — Resumo validado

**Auth:** `POST /auth/login` (form-urlencoded, OAuth2). Retorna `{access_token, token_type:"bearer"}`. Sem refresh token.

**Endpoints:**
- `POST /user/register` — name, email, password, birth_date, investor_profile (CONSERVATIVE|MODERATE|AGGRESSIVE)
- `PUT /user/update/{id}`, `DELETE /user/delete/{id}`
- `GET /assets?search=` — busca global Yahoo
- `GET /assets/{ticker}` → `{price_usd, direction:"subindo"|"caindo"}` ⚠ mapear PT→up/down
- `GET /assets/{ticker}/history?period=1mo` — periods yfinance: `1d, 5d, 1mo, 3mo, 1y, 5y, max`
- `GET /assets/{ticker}/financials | /dividends | /news`
- `GET /profile/watchlist`, `POST /profile/watchlist/add` (array Asset), `POST /profile/watchlist/remove`

**Mapeamento period UI → API:**
| UI | API |
|----|-----|
| 1D | 1d |
| 1W | 5d |
| 1M | 1mo |
| 1Y | 1y |
| ALL | max |

**Mapeamento direction:** `subindo`→up (verde), `caindo`→down (vermelho).

**401 handler:** clear token + redirect `/login`.

---

## Fase 0 — Setup

**Dependencies (`pubspec.yaml`):**
```yaml
dependencies:
  flutter_riverpod: ^2.5.1
  dio: ^5.7.0
  flutter_secure_storage: ^9.2.2
  go_router: ^14.6.0
  fl_chart: ^0.69.0
  cached_network_image: ^3.4.1
  shimmer: ^3.0.0
  intl: ^0.19.0
  shared_preferences: ^2.3.3
  flutter_markdown: ^0.7.4
  flutter_localizations:
    sdk: flutter

dev_dependencies:
  build_runner: ^2.4.13
  riverpod_generator: ^2.6.3
  json_serializable: ^6.9.0
  json_annotation: ^4.9.0
  freezed: ^2.5.7
  freezed_annotation: ^2.4.4
```

**Estrutura pastas:**
```
lib/
├── main.dart
├── app.dart                    (MaterialApp.router + ProviderScope)
├── core/
│   ├── theme/                  (dark OLED, light, cores gain/loss)
│   ├── router/                 (go_router config + redirect auth)
│   ├── constants/              (api_base, period_map, direction_map)
│   ├── utils/                  (haptics, validators, formatters)
│   └── widgets/                (shimmer, empty_state, error_view)
├── data/
│   ├── models/                 (freezed + json_serializable DTOs)
│   ├── datasources/
│   │   ├── dio_client.dart
│   │   ├── auth_interceptor.dart
│   │   └── api_endpoints.dart
│   └── repositories/           (impl)
├── domain/
│   ├── entities/
│   └── repositories/           (interfaces)
├── presentation/
│   ├── viewmodels/             (StateNotifier/Notifier Riverpod)
│   └── views/
│       ├── splash/
│       ├── auth/               (login, register)
│       ├── home/               (+ widgets/)
│       ├── profile/
│       ├── chat/               (mock IA)
│       ├── config/
│       └── shared/             (FloatingIAAvatar, AppShell)
└── l10n/                       (intl_en.arb, intl_pt.arb)
```

---

## Fase 1 — Core Infra

1. `DioClient` singleton via Riverpod provider. baseUrl `http://127.0.0.1:8000` (configurável).
2. `AuthInterceptor` — injeta `Authorization: Bearer <token>`. onError 401 → SecureStorage.clear + emit logout event.
3. `SecureStorageService` — save/read/clear JWT.
4. `ThemeService` (Riverpod) — dark `#121212` (OLED) + light. Cores: gain `#00C805`, loss `#FF3B30`. Persistido em SharedPreferences.
5. `LocaleService` — PT-BR / EN-US persistido.
6. Models freezed: `Asset`, `AssetQuote`, `HistoryPoint`, `NewsItem`, `Dividend`, `Financials`, `User`, `AuthToken`.

---

## Fase 2 — Auth Flow

1. **SplashView** — checa token via SecureStorage → redireciona Login ou Home.
2. **LoginView + LoginViewModel** — form (email RegEx, pwd), call `/auth/login`, persiste token.
3. **RegisterView + RegisterViewModel** — name, email RegEx, pwd, birth_date (`showDatePicker`), investor_profile dropdown.
4. **AuthRepository** — `login()`, `register()`.
5. go_router redirect guard: sem token + rota protegida → `/login`.

---

## Fase 3 — Home Page (SDD 3.1)

1. **HomeViewModel** — carrega watchlist → fetch quotes em paralelo (`Future.wait`). Estado: `period` global (default 1M).
2. **AssetCardWidget** — `CachedNetworkImage` ícone, ticker bold, preço USD formatado (`NumberFormat.simpleCurrency`), seta verde/vermelha mapeada de `direction`.
3. **ReorderableListView** — `HapticFeedback.mediumImpact` em `onReorderStart`. Ordem persistida local (SharedPreferences key por user).
4. **HistoricalChartCard** — `fl_chart` `LineChart`. Filtro período compartilhado via Riverpod provider. Tooltip touch (`LineTouchData`) exibindo data + close.
5. **News Ticker** — `PageView` horizontal, autoscroll `Timer.periodic(seconds: 4)`, refresh dados a cada 1h. Agregação: para cada ticker watchlist → `/assets/{ticker}/news` → flatten + sort por `provider_publish_time`.
6. **HorizontalNewsCard** — favicon publisher, título 2 linhas max, tempo relativo (`timeago`-style local).
7. **Empty State** — sem ativos → botão central "Adicionar seu primeiro ativo" → `/profile`.
8. **Skeleton Shimmer** — durante load cards + chart.

---

## Fase 4 — Profile (SDD 3.2)

1. **ProfileViewModel** — get user (decode JWT `sub` → fetch ou cache local), update via `PUT /user/update/{id}`.
2. **ProfileForm:**
   - Email editável (RegEx validator).
   - Name + birth_date read-only, `Opacity(0.5)`.
   - Password field oculto + ícone olho toggle.
   - Botão "Redefinir Senha" — **placeholder disabled** (Fase 3 decisão = pular).
3. **AssetSearchBar** — `TextField` + debounce 400ms (`Timer`). Chama `/assets?search=q`.
4. **Resultados** — lista com `+` para adicionar à seleção local.
5. **SelectionChips** — chips dos ativos selecionados, X remove.
6. **FAB "Salvar Alterações"** — diff (atual vs original) → `/watchlist/add` (novos) e `/watchlist/remove` (removidos).

---

## Fase 5 — IA Chat (SDD 3.3) — MOCK

1. **ChatRepository** interface + `MockChatRepository` impl.
   - Respostas canned por keyword match (preço, tendência, dividendo, recomendação).
   - Delay simulado 800–1500ms para "Digitando...".
2. **FloatingIAAvatar** — `Overlay` global via `AppShell` wrapper. Persistente exceto Splash/Login/Register.
3. **ChatView** — bubbles user (right) / IA (left). `flutter_markdown` para tabelas/bold IA.
4. **ChatViewModel** — histórico em memória + persistência opcional SharedPreferences.
5. Indicator "Digitando..." animado (3 dots).

---

## Fase 6 — Config (SDD 3.4)

1. **ThemeSwitcher** — `Switch` dark/light. Bind `themeProvider`.
2. **LocaleDropdown** — PT-BR / EN-US. Bind `localeProvider`.
3. Persistência `SharedPreferences`.
4. ARB files: `intl_en.arb`, `intl_pt.arb`. Geração via `flutter gen-l10n`.
5. Logout button → clear storage → `/login`.

---

## Fase 7 — Polish & UX

- `HapticFeedback.lightImpact()` em todo `onTap` botão.
- Skeleton shimmer todos load states.
- Empty states + error views consistentes.
- AnimatedSwitcher transições.
- Pull-to-refresh Home.

---

## Fase 8 — Testes

- Unit ViewModels (auth, home, profile, chat).
- Repository tests com Dio mock.
- Widget tests AssetCardWidget, HistoricalChartCard.
- Integration test: login → home → adicionar ativo → ver gráfico.

---

## Fase 9 — Design Pass

- Invocar skill `frontend-design` ou `ui-ux-pro-max` para review cada tela.
- Tokens design system: spacing scale, typography scale, motion.

---

## Notas UX (SDD §5)

- Haptic feedback todo clique.
- Empty state Home: CTA "Adicionar seu primeiro ativo".
- Shimmer enquanto carrega.
- Cores fixas: gain `#00C805`, loss `#FF3B30`, bg dark `#121212`.

---

## Riscos / Pendências

- **CORS / network:** `127.0.0.1:8000` — emulador Android requer `10.0.2.2:8000`. iOS sim OK. Físico → IP LAN. Configurar via `--dart-define API_BASE`.
- **Sem refresh token:** sessão expira → forçar relogin.
- **Direction PT→EN:** centralizar mapper em `core/utils`.
- **Watchlist order:** API não persiste ordem → manter local.
- **Mock chat:** marcar TODO claro p/ swap futuro.

---

## Ordem execução

Fase 0 → 1 → 2 → 3 → 4 → 6 → 5 → 7 → 8 → 9.
(Config antes Chat: chat usa theme/locale.)
