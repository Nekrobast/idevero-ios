# IDEVERO 0.2.3 build 5 — validación responsive real

## Evidencia de origen

- Dispositivo físico informado: iPhone 17 Pro Max.
- Instalación física de 0.2.2: PASS.
- Launch físico: PASS.
- Petición observada: `Quiero crear una app para apicultores`.
- Proveedor mostrado: `Apple Foundation Models`.
- Hallazgo: la ejecución física estaba letterboxed y el layout no aprovechaba el panel completo.

## Causa raíz

La vista combinaba un editor con mínimo fijo, navegación grande, una cabecera horizontal rígida y ausencia de coordinación de foco/scroll. Además, el target no generaba un launch screen moderno, por lo que iOS ejecutaba la app en un viewport de compatibilidad letterboxed.

## Correcciones limitadas a UI

- Launch screen generado para ocupar la pantalla iPhone completa.
- Navegación compacta y editor adaptativo de 96–184 pt.
- Scroll vertical nativo con dismissal interactivo del teclado.
- Cierre de teclado y scroll animado después de insertar el resultado.
- Acción `Crear prompt` disponible en la barra del teclado cuando el botón principal no cabe.
- Cabecera `Prompt generado` estable y proveedor como badge compacto.
- Procedencia, perspectiva, prioridad y estado visibles por discovery.
- `APPLE MODEL INFERENCE` resaltado cuando es provenance directa o fuente fusionada.
- Acciones y metadata adaptativas mediante `ViewThatFits`.

No se modificaron Knowledge, Local Expert, router, Discovery Engine, compilers ni FoundationModelsProvider.

## Validación CI final

- Commit de código: `3469dcc8e2ed7dd94b48031e7c5a7fe5c6211922`.
- GitHub Actions run: `36850667877`.
- Xcode: 26.6; iOS SDK: 26.5.
- iPhone 17 Pro Max: suite completa y UI test con teclado — PASS.
- iPhone 16e: UI test con Dynamic Type Accessibility Large — PASS.
- Unit tests: 21 ejecutados; 20 PASS, 0 FAIL, 1 SKIPPED (runtime Foundation Models requiere dispositivo físico).
- UI test Pro Max: 1 PASS.
- UI test iPhone 16e: 1 PASS.
- iPhoneOS ARM64 build: PASS.
- Foundation Models iPhoneOS compile: PASS.
- IPA integrity: PASS.
- Disposable-copy structural codesign: PASS.

## IPA

- Artifact privado: `idevero-device-build-0.2.3` (`11156101328`).
- Archivo: `Idevero-iOS-0.2.3-DeviceUnsigned.ipa`.
- SHA-256: `d3b52d0d2b4f6e68fa2bcce5467774724b0dd0c08fd08612c2e1d11dae0578cf`.
- Estado: unsigned y listo para re-firma de AltServer.
