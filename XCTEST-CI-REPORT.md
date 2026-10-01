# IDEVERO 0.2.4 build 6 — XCTest CI Report

## Validated execution

- Definitive run: [36855967629](https://github.com/Nekrobast/idevero-ios/actions/runs/36855967629)
- Validated commit: `634abd533767ef05b5abe00adab4a7a9f452271f`
- Unit total: **30**
- Unit passed: **29**
- Failed: **0**
- Skipped: **1**
- UI tests: **2 PASS** (one per simulator profile)
- Result: **PASS**

## Suites

| Suite | Total | Passed | Failed | Skipped |
|---|---:|---:|---:|---:|
| FoundationModelsDeviceTests | 1 | 0 | 0 | 1 |
| FoundationQualityV2Tests | 4 | 4 | 0 | 0 |
| LocalExpertProviderTests | 16 | 16 | 0 | 0 |
| RegexCompatibilityTests | 1 | 1 | 0 | 0 |
| SemanticDeduplicationTests | 8 | 8 | 0 | 0 |

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
- Generic finding rejection, material domain acceptance and scope-risk filtering.
- Preservation of a materially deeper Apple reason without duplicate discoveries.
- Twelve-case cross-domain task-shape holdout and compact simple-email regression.
- Final discovery action scrolls above the bottom tab bar on large and small iPhones.
- **67/67** exported NSRegularExpression vectors compiled and matched their positive/negative controls.
- Ambiguous fragments no longer invent an event domain.

## Skipped test

`testRealFoundationModelOnCompatibleDeviceOnly` remains skipped in Simulator because actual Foundation Models runtime requires a compatible physical device. The 0.2.3 physical baseline passed; Quality V2 awaits reinstall and retest.
