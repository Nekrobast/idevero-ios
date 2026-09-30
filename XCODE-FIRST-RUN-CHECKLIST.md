# Xcode First Run Checklist

```text
MACOS VERSION:
XCODE VERSION:
SWIFT VERSION:
IOS SDK:
DESTINATION (SIMULATOR / DEVICE):
DEVICE MODEL:
DEVICE IOS:
DEPLOYMENT TARGET: 17.0
CONFIGURATION (DEBUG / RELEASE):
BUILD RESULT:
TEST RESULT:
FILE:
LINE:
COMPILER ERROR EXACTO:
FOUNDATION MODELS AVAILABILITY:
INTELLIGENCE MODE SHOWN:
STEPS TO REPRODUCE:
```

- [ ] Los siete JSON de Knowledge, incluido `RegexAudit.json`, están en los recursos del target.
- [ ] El scheme compartido `Idevero` aparece y contiene `IdeveroTests`.
- [ ] `IdeveroTests` tiene host `Idevero`.
- [ ] Tests de inventario: 128 / 54 / 38 / 30.
- [ ] Local Expert funciona sin Foundation Models.
- [ ] Foundation Models solo se usa con SDK/OS compatibles.
- [ ] No hay WebView, backend ni API key.
- [ ] `AppIcon.png` compila; está marcado visualmente como DEVELOPMENT y no es el icono final.
