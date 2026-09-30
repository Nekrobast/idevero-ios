# Idevero iOS 0.2.2 — Xcode Validated

Aplicación SwiftUI nativa que transforma una idea breve en un prompt profesional. No usa WebView, backend ni API de pago.

## Motor

- Knowledge Schema v3 exportado desde el Local Expert web: 128 conceptos, 54 relaciones, 38 domain packs, 38 intent IDs y 30 estrategias/aliases.
- Task, Intent, Domain y Target se modelan por separado.
- Discovery Control: INCLUDED, LOCKED, OPTIONAL, EXCLUDED y PENDING.
- Provenance: USER EXPLICIT, LOCAL KNOWLEDGE, APPLE MODEL INFERENCE, USER ACCEPTED, USER LOCKED y PLACEHOLDER.
- Compiladores especializados para producto/web, imagen, edición visual, hojas de cálculo, viajes, investigación/compras, email y fallback estructurado.
- Apple Foundation Models es una mejora opcional; Local Expert es el fallback completo.

## Requisitos

- Para el modo local: iOS 17 o posterior.
- Para compilar la rama Foundation Models: Xcode con un SDK que incluya ese framework y un destino compatible.
- No se requiere cuenta, backend, OpenAI API ni Apple Developer Program para ejecutar en Simulator.

`Tools/export-web-knowledge.mjs` exporta desde el source-of-truth web. Los JSON de `Idevero/Knowledge` son recursos runtime versionados, no prompts prefabricados.

History reconstruye snapshots completos y permite regenerar o reanalizar conservando locks y exclusions. La deduplicación local usa IDs, labels ES/EN, aliases y comparación conservadora de tokens.

## Validación real

- Runner estándar GitHub-hosted `macos-26`.
- Xcode 26.6, Swift 6.3.3, iOS SDK 26.5.
- Deployment target local: iOS 17.0.
- Xcode Simulator build: PASS.
- XCTest: 21 total, 20 pass, 0 fail, 1 skipped por requerir un dispositivo físico con Apple Intelligence.
- Regex: 67/67 PASS.
- Simulator launch smoke test: PASS.
- Foundation Models compile: PASS; runtime real pendiente de dispositivo físico compatible.

Consulta `XCODE-CI-BUILD-REPORT.md`, `XCTEST-CI-REPORT.md`, `LEEME-MAC-XCODE.md`, `XCODE-FIRST-RUN-CHECKLIST.md` y `FOUNDATION-MODELS-DEVICE-CHECKLIST.md`.
