# IDEVERO — AltStore / AltServer sideload preflight

Preflight real: GitHub Actions run `36814673030`, artifact privado `idevero-altstore-preflight`.

## IPA exacto

- Source artifact: `11139991371`
- File: `Idevero-iOS-0.2.2-DeviceUnsigned.ipa`
- SHA-256: `bcc26abf2266f81afa251077507957e453220b81dc9a04be178296221e7aaaad`
- ZIP/Payload integrity: PASS
- Original unsigned: PASS / expected
- Original unchanged after test: PASS

## Device metadata

| Field | Value |
|---|---|
| Payload | `Payload/Idevero.app/` |
| Executable | `Idevero` |
| Architecture | `arm64` |
| Platform | `iPhoneOS` |
| CFBundleIdentifier | `com.aitor93.idevero` |
| CFBundleShortVersionString | `0.2.2` |
| CFBundleVersion | `4` |
| MinimumOSVersion | `17.0` |
| UIDeviceFamily | `1` — iPhone |
| CFBundleSupportedPlatforms | `iPhoneOS` |
| DTPlatformName | `iphoneos` |
| DTSDKName | `iphoneos26.5` |

## Entitlements and capabilities

- `.entitlements` files: NONE
- `CODE_SIGN_ENTITLEMENTS`: NONE
- Xcode `SystemCapabilities`: NONE
- `com.apple.developer.*`: NONE
- `aps-environment`: NONE
- `UIBackgroundModes`: NONE
- Embedded provisioning: NONE
- Existing code signature: NONE

No declarations were found for iCloud, CloudKit, Push Notifications, Associated Domains, App Groups, Keychain Sharing, Sign in with Apple, HealthKit, HomeKit, Network Extensions, DriverKit, VPN, NFC, CarPlay, Wallet, Maps, Background Modes, App Attest, DeviceCheck or managed capabilities.

## Embedded code

- Frameworks: NONE
- Dynamic libraries: NONE
- App extensions: NONE
- Nested executable bundles: NONE
- Main bundle executable: `Idevero`

AltServer only needs to sign the main app bundle; there is no nested code requiring separate profiles or App IDs.

## Structural codesign

A disposable copy of `Idevero.app` was signed ad-hoc with identity `-`; `codesign --verify --deep --strict --verbose=2` returned:

```text
AdHocTest/Idevero.app: valid on disk
AdHocTest/Idevero.app: satisfies its Designated Requirement
```

This proves structural signability only. It is not an Apple development signature and is not used in the delivered IPA.

## Foundation Models and SwiftData

IDEVERO uses the on-device `SystemLanguageModel.default`, not Private Cloud Compute. Apple documents a specific entitlement only for the separate Private Cloud Compute model. No Foundation Models entitlement or special capability is declared or required by IDEVERO's current on-device path. Runtime still depends on compatible hardware, system, Apple Intelligence and model availability.

SwiftData uses `.modelContainer(for: PromptRecord.self)` with local storage. No CloudKit database or iCloud container is configured, so it adds no entitlement or paid-program dependency.

## Result

```text
ENTITLEMENTS: SAFE FOR FREE SIDELOAD
BUNDLE STRUCTURE: PASS
STRUCTURALLY SIGNABLE: PASS
ORIGINAL IPA: UNSIGNED / UNCHANGED
ALTSERVER RESIGN: READY
```

Official references: Apple Foundation Models documentation, Apple supported capabilities, Apple free developer account limits, and AltStore Classic/AltServer documentation.
