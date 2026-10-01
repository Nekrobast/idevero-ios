# IDEVERO 0.2.4 build 6 — Xcode CI Build Report

## Resultado definitivo

- Repository: private `Nekrobast/idevero-ios`
- Validated run: [36855967629](https://github.com/Nekrobast/idevero-ios/actions/runs/36855967629)
- Validated commit: `634abd533767ef05b5abe00adab4a7a9f452271f`
- Runner: standard GitHub-hosted `macos-26`
- macOS: 26.6.2 (25G83)
- Xcode: 26.6
- Swift: 6.3.3 (swiftlang-6.3.3.1.3, clang-2100.1.1.101)
- iOS SDK: 26.5; deployment target: iOS 17.0
- Simulators: iPhone 17 Pro Max and iPhone 16e with Accessibility Large Dynamic Type
- Simulator build/test and both UI validations: **PASS**
- Generic iPhoneOS ARM64 build: **PASS**
- Foundation Models simulator/iPhoneOS compile: **PASS**
- Signing: intentionally disabled for CI
- Disposable-copy ad-hoc structural codesign: **PASS**

## Compiler-first corrections

The first Quality V2 run compiled but exposed two test failures. A known one-word canonical alias was incorrectly rejected by the specificity gate; known concepts now bypass only the two-token form check. An explicit app request containing the generic domain word `empresa` was routed as BUSINESS; explicit APPLICATION/WEB format now takes precedence. No sector-specific vocabulary was added.

## Foundation Models

- `SystemLanguageModel`, `LanguageModelSession`, `@Generable`, nested structured output and `@Guide`: **COMPILE PASS**.
- Runtime Quality V2 inference: **AWAITING PHYSICAL RETEST**.
- Physical 0.2.3 baseline: provider, Apple provenance, dedupe and Apple-only discovery **PASS** on iPhone 17 Pro Max.

## IPA

- Artifact: `idevero-device-build-0.2.4` (`11159008330`)
- File: `Idevero-iOS-0.2.4-DeviceUnsigned.ipa`
- SHA-256: `e3f28e6a1417f1b8c1b3baad63496ee0a18db14ad8a0e66362856e186dd85b12`
- Integrity, ARM64, iPhoneOS, version/build, unsigned state and re-signability: **PASS**.
