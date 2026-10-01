# IDEVERO Foundation Models Quality V4

## Physical Quality V3 finding

The physical 0.2.5 build 7 test on iPhone 17 Pro Max confirmed on-device Foundation Models, but exposed three user-facing regressions: the Domain Frame was discarded after filtering, raw model identifiers reached the prompt and discovery UI, and English questions appeared inside a Spanish request. Scope discipline improved while domain depth and final usability regressed. The floating tab bar also continued to cover the final discovery content.

## Root causes

- `ModelDomainFrame` existed only inside the Foundation merge function and was never stored in `PromptAnalysis`.
- `AppleUnknownSelector` interpolated untrusted candidate and concept strings directly into questions.
- Model `lens` values were shown as display labels without an internal/display boundary.
- The previous bottom inset added only symbolic spacing and did not know the actual `UITabBar` height.

## Quality V4 contract

- A Codable, Sendable, optional `DomainContext` survives analysis, history and regeneration.
- Domain context informs the final prompt without becoming confirmed MVP requirements.
- All model-originated display text passes independent machine-token and language validation.
- Invalid primary-job candidates produce a localized, generic high-impact question rather than exposing placeholders.
- Semantic roles remain internal; the UI displays localized human labels.
- The product compiler keeps the domain frame prominent, confirmed requirements separate and generic product scaffolding compressed.
- The root tab container measures the real public `UITabBar` geometry and supplies that clearance to the creation scroll view.

## Authority, privacy and performance

Local Expert still owns routing, user decisions, locks, exclusions, merge, prioritization and final compilation. Foundation Models remains one on-device inference; no translation call, API, backend or network provider was added. Timing instrumentation still covers inference, merge and compile without logging prompt contents.

## Evidence boundary

CI validates the schema, persistence, compiler, display gate, responsive geometry and iPhoneOS build. Physical Quality V4 model output and the physical floating-tab clearance must be retested with the 0.2.6 IPA.
