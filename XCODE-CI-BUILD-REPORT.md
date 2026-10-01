# IDEVERO iOS — Xcode CI Build Report

## Result

- Version: 0.2.2 (build 4)
- Repository: private `Nekrobast/idevero-ios`
- Definitive validated run: [36759276604](https://github.com/Nekrobast/idevero-ios/actions/runs/36759276604)
- Validated commit: `02e6a00fb4918dd0bdfd0fae28a24d68f99cef72`
- Runner: standard GitHub-hosted `macos-26` / `macos-26-arm64`
- macOS: 26.6.2 (25G83)
- Xcode: 26.6 (17F113)
- Swift: 6.3.3 (swiftlang-6.3.3.1.3, clang-2100.1.1.101)
- iOS SDK: 26.5
- iOS Simulator SDK: 26.5
- Destination: iPhone 17 Pro simulator, iOS 26.4.1
- Deployment target: iOS 17.0
- Signing: disabled for CI
- Build/test job: **PASS**
- Simulator launch smoke test: **PASS** (`com.aitor93.idevero` launched successfully)

## Compiler-first corrections

1. Declared iPhoneOS and iPhone Simulator as supported target platforms.
2. Added the explicit `IdeveroTests -> Idevero` target dependency.
3. Updated Foundation Models structured-generation helper visibility for `@Generable`.
4. Removed an ambiguous `prefix` inference with explicit `[String]` types.
5. Enabled testability only for the Debug app module.
6. Tightened the general event-domain signal so a bare “organizar” verb does not invent an event domain.

## Foundation Models

- Framework/API compilation with Xcode 26.6: **PASS**
- Structured generation macros: **PASS**
- Runtime inference: **NOT EXECUTED — COMPATIBLE PHYSICAL DEVICE REQUIRED**
- Local Expert fallback and merge logic: covered by simulator XCTest.

## Notes

The definitive run checked out commit `02e6a00`, ran `clean test`, launched the built app in Simulator and uploaded the validated package, build log and `.xcresult`. App Store signing, TestFlight, physical-device execution and Apple Intelligence runtime were intentionally not attempted.

