# IDEVERO 0.2.6 build 8 — XCTest CI report

## Validated run

- Validated merge commit: `f55ea1a291d4c248b27b75039c349404f3fe8328`
- GitHub Actions run: `36897880225`
- XCTest result: PASS

## Results

- Total tests: 53
- Passed: 52
- Failed: 0
- Skipped: 1
- UI tests: PASS on large iPhone plus PASS on compact accessibility configuration
- Regex validation: 67/67 PASS

The single skipped test is the real Foundation Models runtime test, which intentionally requires a compatible physical device. Foundation Models contract, merge, display validation, domain-context persistence and compiler behavior are tested without pretending that Simulator execution proves on-device inference.

## Quality V4 coverage

- Domain Frame survives into `PromptAnalysis`, history snapshots and regenerate
- Legacy analyses without Domain Context decode successfully
- Spanish and English display contracts remain coherent
- Machine-token candidates, discoveries and unknowns are rejected from user-facing output
- Raw semantic-role enums are not exposed as display lenses
- Natural primary-job fallback is produced when model candidates are invalid
- Domain Context remains useful when Apple requirements are rejected by scope control
- Business opportunities are not auto-included
- Final application prompt remains useful while the primary job is unresolved
- Locks, exclusions, dedupe, regenerate, reanalyze and history regressions pass
- Knowledge inventory and 67/67 regular expressions pass

## Responsive UI coverage

The large and compact accessibility configurations passed. The UI test compares the final discovery action frame with the actual tab-bar frame; the implementation derives clearance from the runtime tab container rather than a device-specific height.

## Physical boundary

Quality V4 physical model output and final bottom-tab clearance are awaiting installation of the 0.2.6 IPA on the iPhone 17 Pro Max.
