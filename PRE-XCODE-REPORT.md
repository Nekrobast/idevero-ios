# Idevero iOS 0.2.1 — Pre-Xcode Report

## Resultado

`Tools/pre-xcode-check.sh`: **PASS**, con warnings externos de ejecución.

## Inventario

- 128 concepts
- 54 relationships
- 38 domain packs
- 38 intent packs
- 30 strategies/aliases
- 67 regex con vectores positivos y negativos
- 102 casos de paridad
- 4 archivos XCTest

## Cerrado sin Xcode

- History snapshot/reopen.
- Regenerate y Reanalyze desde History.
- Persistencia de locks/exclusions/provenance.
- Dedupe por concept ID, labels, aliases y tokens conservadores.
- Mapping Apple→concepto local y conceptos externos estables.
- Auditoría JS RegExp→ICU sin construcciones incompatibles detectadas.
- AppIcon de desarrollo 1024×1024 sin canal alpha.
- Scheme `Idevero` compartido con el target de tests, apto para ejecución no interactiva.
- Workflow privado de GitHub Actions preparado.
- Comprobación de recursos, IDs, relaciones colgantes, secretos y arquitectura.

## No ejecutado

- Xcode build.
- XCTest.
- iOS Simulator.
- Foundation Models runtime.
- iPhone físico.

La única validación definitiva pendiente es compilar y ejecutar con Xcode, seguida del test de Foundation Models en dispositivo compatible.
