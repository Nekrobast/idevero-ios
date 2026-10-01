# IDEVERO 0.2.7 build 9 — Xcode CI report

## Validated Quality V5 run

- Repository: `Nekrobast/idevero-ios` (private)
- Pull-request head: `6194ddb580351d2bc2dcaa7d5fd2198a83f8a45c`
- Validated pull-request merge commit: `f0bad0b535d5a80ecfc35c14f8e1e6ec317a9156`
- Main merge commit: `4078021a851e073dd5d768be8e1e6bf554cf8dc2`
- GitHub Actions run: `36933358823`
- Result: PASS

## Environment

- Runner class: standard GitHub-hosted `macos-26`
- macOS: 26.6.2
- Xcode: 26.6
- Swift: 6.3.3
- iOS SDK: 26.5
- Minimum deployment target: iOS 17.0

## Validations

- Complete XCTest suite on iPhone 17 Pro Max Simulator: PASS
- Large-iPhone UI validation: PASS
- iPhone 16e / Accessibility Large validation: PASS
- Generic iPhoneOS ARM64 build: PASS
- Foundation Models Simulator compile: PASS
- Foundation Models iPhoneOS compile: PASS
- Version metadata: `0.2.7` / build `9`
- Unsigned IPA creation and ZIP integrity: PASS
- Disposable-copy ad-hoc codesign structural verification: PASS

## Build iterations

The first two runs exposed four and then two deterministic test failures. One product regression was corrected (`DomainContext.isEmpty` did not consider calibrated items). Three assertions were updated because they encoded pre-V5 question-ordering or conditional-language behavior. The third run passed without compiler or test failures.

## Artifacts

- Xcode results: `idevero-xcode-results-0.2.7` (artifact `11196629837`)
- Device package: `idevero-device-build-0.2.7` (artifact `11197287649`)
- Device IPA SHA-256: `be41b035eaab3fd50a66c9eceacbc637a363e2ec1dda39f97e3bbf5075009185`
- Retention expiry: 2026-10-08 (seven days)

## Runtime boundary

Foundation Models compiles for Simulator and iPhoneOS. Quality V5 semantic behavior has not yet been physically evaluated; the CI result proves deterministic gates, persistence, compilation and UI regressions only.
