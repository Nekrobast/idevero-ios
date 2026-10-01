# Idevero iOS 0.2.7 — Foundation Models Quality V5

IDEVERO converts a short idea into a professional prompt using Local Expert and, when available, one on-device Apple Foundation Models inference.

Quality V5 preserves the domain frame while distinguishing established domain knowledge, case-dependent patterns, user-specific unknowns and unsupported speculation. It prioritizes questions by information gain, rejects domain-washed generic augmentation, keeps model metadata out of display text and centralizes visible Spanish/English terminology.

## Runtime boundaries

- iOS 17+ Local Expert path
- Foundation Models conditional on supported Apple hardware/system availability
- One structured on-device inference; no translation call
- No backend, account, analytics, OpenAI API or paid inference
- History, locks, exclusions, regenerate and reanalyze remain local

## Validation

Run `node Tools/prexcode-audit.mjs` for the portable audit. Xcode, XCTest, UI tests, generic iPhoneOS ARM64 and unsigned IPA packaging are validated by `.github/workflows/ios-ci.yml`.

Physical semantic acceptance remains separate from fixture/Simulator evidence and must be repeated on the iPhone 17 Pro Max with the validated 0.2.7 IPA.
