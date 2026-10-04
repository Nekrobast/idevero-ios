# PRE-1.0 Minimal Compliance + Save Reliability

Stage: guardrail proof and FEATURE RED preparation. No production change yet.

PHYSICALLY VALIDATED BASELINE: 61eb2a8490b1bcfcbedbaadfda18b4746035326f.
CONSOLIDATED PRE-1.0 BASELINE: 36b36c2463e00e3ef148f7d8ac7fe8f7a99d6a1d.

## Historical guards and authorized adaptation

- ios-ci.yml equivalence step froze all production/tests/Tools and allowed only Markdown/workflow hygiene. It would reject any new tests, Settings access or save correction before executing XCTest. Replaced for this branch by Authorized Remediation Diff Gate and its tests.
- audit-presentation-remediation.mjs froze build13 outside three presentation files. Settings/save edits legitimately exceed that historical scope.
- audit-human-friendly-ux.mjs froze model/viewmodel/OperationFeedback and History persistence handlers. Save error propagation must change History persist handling, not schema or user decisions.
- audit-physical-v6.mjs protects conservative identity, no fixture hardcodes, no paid APIs and current version/build. It remains executed unchanged.
- All three historical scripts and the prior workflow are immutable at their historical commits; scripts themselves are not edited/deleted. The historical freeze remains evidence, not falsely claimed for a candidate containing authorized edits.

## New guard

Exact filenames only. Every changed/new permitted file (apart from the control-plane policy itself) requires a SHA-256 of reviewed full content. A path match alone NEVER permits content. All other baseline files, including all existing test assertions, intelligence, compiler, schema, knowledge, presentation and concurrency, remain byte-identical.

Full-file seals cover mixed Create/History/Settings files, so an unrelated callback mutation fails even in an otherwise permitted UI path. On later implementation each authorized snapshot must be manually reviewed and recorded; there is no auto-bless mode. The policy and audit implementation are themselves reviewable control-plane code, not a security boundary against someone deliberately rewriting the gate and its policy.

The complete existing XCTest/UI/device/artifact pipeline from Select installed Xcode onward is additionally byte-identical to the baseline. No assertions/skips/holdout counts changed. No version/build change.

Self-tests use in-memory copies read from baseline Git objects: Settings/privacy and save-path authorized samples PASS; semantic engine, compiler, Foundation, PromptRecord schema, Discovery Control, provider selection, concurrency and existing tests mutations FAIL; wrong change inside a sealed mixed file FAIL; deletion/unlisted addition FAIL. No real production mutated.

## Feature RED separation

New MinimalComplianceSaveUITests specify identifiable Privacy/Support access, real Save confirmation, visible accessible save failure with retry and retained Copy/Share/result, and History update save failure. They execute against original production first. No feature production is implemented until behavioral failures are confirmed from native XCTest logs.

DEBUG-only controlled persistence-failure injection will later be scoped to the new feedback boundary, not PromptRecord or provider logic; tests do not inject domains/answers into production. Before implementation launch environment arguments have no effect, making baseline save-failure feedback tests RED rather than pretending errors are already supported.

## Next stages, not claims of completion

After confirmed feature RED: minimal Settings/native system links with centralized optional URLs; nil URLs show an honest unpublished state without broken/fabricated links. ES/EN policy/support drafts use explicit legal-owner/contact placeholders. GitHub Pages files prepared but not activated. Minimal save feedback calls the actual existing save, displays success only after completion, reports errors while preserving result, and offers retry. Native unit/UI targeted GREEN then complete existing regression.

Human input pending: legal responsible party, support contact, approved hosting/public URLs. No publication, account change, purchase or App Store signing.
Current version/build: 0.2.9 / 14. Production has not been changed; no new IPA or GREEN claim.

## Initial targeted harness failure (NOT feature RED)

Run 37226325313 on commit 600ca73922a4e336881cc8489d53b9416469742d allocated macos-26 / GitHub Actions 1000000100. All 13 isolation simulations and actual diff gate PASS. Native XCTest did not execute: Bash rejected empty EXTRA array under nounset. Artifact 11311583356 is harness diagnostics only, not XCTest or IPA validation. Fix only the new workflow command by initializing its testing selector array with the UI target. Do not remove nounset or change any assertions. Feature RED remains unproven until native test assertions actually fail.

## Native feature RED in progress and unpublished pages

Corrected harness commit: 84b6c0979aa2aa9ad9405cd420e5a15e9f394336. Run 37226446216 allocated macos-26 / GitHub Actions 1000000101; isolation simulations and diff gate PASS; native targeted XCTest is running. No feature RED conclusion or production fix before its actual assertion results.

Privacy and Support ES/EN drafts are prepared under docs, with legal-owner/contact/effective-date placeholders. Three static HTML pages parse, have no broken relative links, and contain no scripts/external assets. GitHub Pages is suitable for this public repository, but is NOT activated; technically expected URLs are documented only as provisional, not live/final and not app configuration. No human identity, email or domain fabricated. No production modified, no new IPA generated, no new build number.
