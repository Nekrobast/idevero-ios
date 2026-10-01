# IDEVERO 0.2.6 build 8 — Xcode CI report

## Validated Quality V4 run

- Repository: `Nekrobast/idevero-ios` (private)
- Quality V4 implementation commit on `main`: `50ee273685f453e1e513c07ce2a53d812b2bf5f9`
- Validated pull-request merge commit: `f55ea1a291d4c248b27b75039c349404f3fe8328`
- GitHub Actions run: `36897880225`
- Result: PASS

## Environment

- Runner class: standard GitHub-hosted `macos-26`
- macOS: 26.6.2
- Xcode: 26.6
- Swift: 6.3.3
- iOS SDK: 26.5
- Minimum deployment target: iOS 17.0

## Validations

- iPhone Simulator build: PASS
- Complete XCTest suite on iPhone 17 Pro Max Simulator: PASS
- Compact-device UI run with Accessibility Large Dynamic Type: PASS
- Generic iPhoneOS ARM64 build: PASS
- Foundation Models Simulator compile: PASS
- Foundation Models iPhoneOS compile: PASS
- Version metadata: `0.2.6` / build `8`
- Unsigned IPA creation and ZIP integrity: PASS
- Disposable-copy ad-hoc codesign structural verification: PASS

## Build iterations

Quality V4 passed its first real compiler/test/device workflow. No compiler-driven source correction was required after the run began.

## Artifacts

- Xcode results: `idevero-xcode-results-0.2.6` (artifact `11181435796`)
- Device package: `idevero-device-build-0.2.6` (artifact `11180358445`)
- Device IPA SHA-256: `cd92b0435120b8f145d95f3ff121d4df437885a29a6e99e2099c4574f2be1e69`
- Retention expiry: 2026-10-08 (GitHub Actions seven-day retention)

## Runtime boundary

Foundation Models compiles for Simulator and iPhoneOS. Quality V4 model behavior, language consistency, domain-context usefulness and the physical tab clearance still require installation and retest on the iPhone 17 Pro Max; CI does not claim those physical results.
