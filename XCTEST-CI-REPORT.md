# IDEVERO iOS — XCTest CI Report

## Validated execution

- Definitive run: [36759276604](https://github.com/Nekrobast/idevero-ios/actions/runs/36759276604)
- Validated commit: `02e6a00fb4918dd0bdfd0fae28a24d68f99cef72`
- Total: **21**
- Passed: **20**
- Failed: **0**
- Skipped: **1**
- Result: **PASS**

## Suites

| Suite | Total | Passed | Failed | Skipped |
|---|---:|---:|---:|---:|
| FoundationModelsDeviceTests | 1 | 0 | 0 | 1 |
| LocalExpertProviderTests | 14 | 14 | 0 | 0 |
| RegexCompatibilityTests | 1 | 1 | 0 | 0 |
| SemanticDeduplicationTests | 5 | 5 | 0 | 0 |

## Verified areas

- Knowledge inventory: 128 concepts, 54 relationships, 38 domain packs, 38 intent packs and 30 strategies/aliases.
- Required task routing and Task/Intent/Domain/Target separation.
- Local Expert depth and compact email behavior.
- Specialized application, image, image-editing and spreadsheet compilers.
- Work preserved as a target rather than a task.
- Locks and exclusions preserved during reanalysis.
- Regenerate preserves analysis identity and discovery state.
- History round-trip and safe legacy migration.
- Reduced question budget.
- Semantic deduplication and stable external concept IDs.
- **67/67** exported NSRegularExpression vectors compiled and matched their positive/negative controls.
- Ambiguous fragments no longer invent an event domain.

## Skipped test

`testRealFoundationModelOnCompatibleDeviceOnly` is skipped only under `targetEnvironment(simulator)`. On physical hardware it checks actual availability and, when ready, invokes `LanguageModelSession` through `FoundationModelsProvider`, verifies Apple-augmented mode and requires at least one Apple-provenance discovery.

