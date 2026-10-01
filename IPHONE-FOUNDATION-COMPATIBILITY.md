# IDEVERO — Compatibilidad iPhone y Foundation Models

Baseline: IDEVERO 0.2.2 (build 4). Deployment target: iOS 17.0.

La disponibilidad real de la ampliación Apple nunca se infiere solo por el modelo del teléfono: IDEVERO consulta `SystemLanguageModel.default.availability` y utiliza Local Expert si el estado no es `.available`.

| iPhone | IDEVERO Local Expert | Apple Intelligence | Foundation Models | Apple augmentation |
|---|---|---|---|---|
| iPhone XS / XS Max / XR y otros iPhone capaces de ejecutar iOS 17 pero no Apple Intelligence | Sí, con iOS 17+ | No | No | No; fallback Local Expert |
| iPhone SE (2.ª o 3.ª generación), iPhone 11–14 y iPhone 15 / 15 Plus | Sí, con iOS 17+ | No | No | No; fallback Local Expert |
| iPhone 15 Pro / 15 Pro Max | Sí | Sí, con sistema, idioma y región compatibles | Sí, con iOS 26+ y modelo disponible | Sí cuando `availability == .available` |
| iPhone 16 y posteriores, incluidos los modelos Air compatibles | Sí | Sí | Sí, con iOS 26+ y modelo disponible | Sí cuando `availability == .available` |

## Requisitos acumulativos para Apple augmentation

1. Hardware compatible con Apple Intelligence.
2. iOS 26 o posterior para el código Foundation Models utilizado por IDEVERO.
3. Apple Intelligence activado y modelos descargados.
4. Idioma del dispositivo y de Siri compatibles; para Foundation Models debe comprobarse también el locale mediante la API cuando proceda.
5. `SystemLanguageModel.default.availability == .available`.

Un framework presente o una compilación correcta no prueban que el modelo esté disponible. Los estados `.unavailable(...)`, un idioma no soportado o un error de sesión activan Local Expert.

## Fuentes oficiales

- Foundation Models: https://developer.apple.com/documentation/foundationmodels
- SystemLanguageModel: https://developer.apple.com/documentation/foundationmodels/systemlanguagemodel
- Availability: https://developer.apple.com/documentation/foundationmodels/systemlanguagemodel/availability-swift.enum
- Idiomas y locales: https://developer.apple.com/documentation/foundationmodels/supporting-languages-and-locales-with-foundation-models
- Requisitos de Apple Intelligence: https://support.apple.com/121115

