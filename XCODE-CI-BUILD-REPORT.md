# IDEVERO 0.2.5 build 7 — Xcode CI report

## Validated baseline

- Repository: `Nekrobast/idevero-ios` (private)
- Commit tested: `f9afc273c12a293b0d5d54ea20e86678fa57d4d3`
- GitHub Actions run: `36862684183`
- Result: PASS

## Environment

- Runner class: standard GitHub-hosted macOS runner
- macOS: 26.6.2
- Xcode: 26.6
- Swift: 6.3.3
- iOS SDK: 26.5
- Minimum deployment target: iOS 17.0

## Validations

- iPhone Simulator build: PASS
- Large-device UI run (iPhone 17 Pro Max): PASS
- Compact-device accessibility UI run (iPhone 16e, Accessibility Large): PASS
- Generic iPhoneOS build: PASS
- Device target: `arm64-apple-ios17.0`
- Foundation Models Simulator compile: PASS
- Foundation Models iPhoneOS compile: PASS
- Version metadata: `0.2.5` / build `7`
- Unsigned IPA creation and ZIP integrity: PASS
- Disposable-copy ad-hoc codesign structural verification: PASS

## Build iterations

The first Quality V3 run (`36861724976`) exposed one UI-test selection issue on the compact accessibility configuration: the test attempted the primary create button while the keyboard-specific action was active. The product code and the other build/test paths passed. The test was corrected to select the action actually exposed by the current keyboard state. No product behavior was changed.

Final run `36862684183` passed all build, unit, UI and iPhoneOS jobs.

## Artifacts

- Xcode results: `idevero-xcode-results-0.2.5` (artifact `11162522603`)
- Device package: `idevero-device-build-0.2.5` (artifact `11163107180`)
- Device IPA SHA-256: `120d858fe4757564c3f7d496c4cb3ce09aa0f840504e4e75111bc511f68a3f87`

## Runtime boundary

Foundation Models compiles for Simulator and iPhoneOS. Quality V3 model behavior and latency still require a physical-device retest; CI does not claim that runtime result.
