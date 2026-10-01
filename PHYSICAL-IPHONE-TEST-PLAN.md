# IDEVERO — Physical iPhone Test Plan

Baseline: 0.2.2 build 4. No App Store, TestFlight, remote logging ni API externa.

## Datos permitidos del dispositivo

Registrar solo modelo, iOS, idioma, región, estado de Apple Intelligence y `SystemLanguageModel.default.availability`. No registrar Apple ID, correo, serial ni UDID.

## Orden obligatorio

### A. Local Expert only

1. Ejecutar en cualquier iPhone con iOS 17+.
2. Confirmar launch sin crash y modo `LOCAL EXPERT`.
3. Crear un prompt y verificar resultado.
4. Abrir History.
5. Bloquear un discovery y excluir otro.
6. Ejecutar Regenerate: debe recompilar sin cambiar análisis ni llamar Apple.
7. Ejecutar Reanalyze: debe mantener lock y exclusion.
8. Cerrar y abrir la app para verificar persistencia.

### B. Local + Apple Foundation Models

1. Usar iPhone compatible con iOS 26+, Apple Intelligence activo y modelos listos.
2. Registrar `SystemLanguageModel.default.availability`.
3. Solo si es `.available`, ejecutar inferencia real con `LanguageModelSession`.
4. Confirmar structured generation `@Generable`/`@Guide`.
5. Confirmar que Apple solo añade discoveries; `SpecializedCompiler` local crea el prompt final.
6. Verificar provenance `APPLE MODEL INFERENCE`.
7. Medir Local, Apple, merge, compile y total con reloj monotónico/medición local de Xcode.

### C. Foundation Models unavailable → Local fallback

1. Probar legítimamente con Apple Intelligence desactivado, modelo aún no preparado, idioma/locale no soportado o dispositivo no compatible.
2. Registrar la razón devuelta por availability sin modificar permanentemente ajustes.
3. Confirmar Local Expert, input preservado, prompt generado y ausencia de crash.
4. Si la sesión falla después de estar disponible, confirmar fallback automático y error sanitizado.

## Casos reales

Ejecutar cada caso primero Local only y después Local + Apple cuando esté disponible:

1. `Quiero crear una app para apicultores`
2. `Quiero comprar un móvil por máximo 500 € que haga buenas fotos`
3. `Organízame un viaje a Japón de 7 días`
4. `Quiero crear un marketplace de segunda mano`
5. `Genera una imagen de un samurái bajo la lluvia`
6. `Necesito un Excel para controlar stock`
7. `Mejora mi aplicación existente usando ChatGPT Work`
8. `Necesito organizarlo mejor`
9. `Escribe un email corto de agradecimiento`
10. Holdout long-tail cerrado tras congelar el código: `Necesito un sistema para gestionar un criadero de setas`

## Comparación por caso

Registrar Task, Intent, Domain, discoveries locales, discoveries Apple nuevos, duplicados fusionados, irrelevantes, scope creep, unknowns y forma del prompt final. No generar una puntuación única.

## Dedupe y autoridad

- Caso A: si Apple propone un concepto local, comprobar que se fusionan provenances sin segunda entrada.
- Caso B: si Apple aporta un requisito sectorial nuevo, conservarlo como discovery nuevo con provenance Apple.
- LOCK: bloquear un discovery Apple, reanalizar y verificar que sigue CORE/LOCKED.
- EXCLUDE: excluir otro, reanalizar y verificar que Apple no lo reactiva.
- Un requisito explícito nunca puede desaparecer ni cambiar silenciosamente.

## Rendimiento

Por caso registrar aproximadamente:

| Fase | Medición |
|---|---|
| Local analysis | inicio → resultado local |
| Apple augmentation | inicio sesión → structured response |
| Merge | entrada findings → analysis fusionado |
| Final compile | analysis → prompt |
| End-to-end | submit → prompt visible |

Marcar por separado `FIRST FOUNDATION REQUEST` y la mediana aproximada de solicitudes posteriores si se aprecia diferencia clara.

## Criterio de finalización

Local Expert, structured inference, provenance, dedupe, locks, exclusions y fallback deben pasar. Los resultados solo pueden completarse en un Mac con Xcode y un iPhone físico.

