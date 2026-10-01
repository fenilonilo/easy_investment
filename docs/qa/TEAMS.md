# Times de correção (APP) — fonte: docs/qa/QA-SINTESE.md
Fora de escopo: itens BACK, B19 (i18n completo), B21 (tela de detalhe = feature nova), B22 (favicons CORS), B13, B23.
| Área | Fix | IDs |
|---|---|---|
| Auth/Config | F1 | B01, B15, B27 (+B10 avatar morto) |
| Perfil | F2 | B02, B03, B04, B26 |
| Chat | F3 | B05, B07, B08(mitigação app), B09, B11, B12 |
| Início | F4 | B16, B17, B18, B20, B28 |
Testes: T1..T4 espelham F1..F4 em test/regression/<area>_regression_test.dart
